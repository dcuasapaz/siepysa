---------------------------------------------------------------------------------------------------------
-- CREATE: Creacion de objetos
---------------------------------------------------------------------------------------------------------
--> CREATE: Crear schema dta_uio
CREATE SCHEMA dta_uio AUTHORIZATION siepysa;
--> ALTER: Cambiar de schema a la tabla importada
ALTER TABLE public.DATA_2020 SET SCHEMA dta_uio;
--> READ: Consultar tabla movida a nuevo esquema
SELECT * FROM dta_uio.DATA_2020 AS D;
---------------------------------------------------------------------------------------------------------
-- CLEAN: Depuracion y limpieza de datos
---------------------------------------------------------------------------------------------------------

---> 1. Creacion de funciones para uso dentro de la depuracion

--> CREATE: Funcion para reemplazos
CREATE OR REPLACE FUNCTION dta_uio.iif_sql(BOOLEAN, numeric, numeric) returns numeric AS
$body$ SELECT case $1 when true then $2 else $3 end $body$
LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION dta_uio.sif_sql(BOOLEAN, text, text) returns TEXT AS
$body$ SELECT case $1 when true then $2 else $3 end $body$
LANGUAGE sql IMMUTABLE;

--> CREATE: Funcion para el calculo de la semana epidemiologica
CREATE OR REPLACE FUNCTION dta_uio.d1ow(numeric) returns smallint AS 
-- $1=a?o 
$body$ SELECT extract(dow from date (to_char($1,'9999')||'/01/01'))::smallint $body$ 
LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION dta_uio.C1(numeric) returns integer AS 
-- $1=a?o 
$body$ SELECT case dta_uio.d1ow($1) when 0 then -1 when 1 then 0 when 2 then 1 when 3 then 2 when 4 then -4 when 5 then -3 when 6 then -2 end $body$ 
LANGUAGE sql IMMUTABLE; 

CREATE OR REPLACE FUNCTION dta_uio.smn(numeric, numeric, numeric) returns numeric AS 
-- $1=a?o, $2=mes, $3=dia 
$body$ SELECT floor(((extract(doy from to_date((to_char($1, '9999')||to_char($2,'00')||to_char($3,'00')),'YYYYMMDD'))::integer+dta_uio.C1($1))::numeric/7::numeric))+1 $body$ 
LANGUAGE sql IMMUTABLE; 

CREATE OR REPLACE FUNCTION dta_uio.smn_epd(numeric, numeric, numeric) returns numeric AS 
-- $1=a?o, $2=mes, $3=dia 
$body$ SELECT dta_uio.iif_sql(($2>=2 and $2<=11) or ($2=1 and $3>=4) or ($2=12 and $3<=28), 
($1*100)+dta_uio.smn($1,$2,$3),  
dta_uio.iif_sql( 
(($3=29) and ($2=12) and dta_uio.d1ow($1+1)=3) or  
(($3=30) and ($2=12) and (dta_uio.d1ow($1+1)=2 or dta_uio.d1ow($1+1)=3)) 
or (($3=31) and ($2=12) and (dta_uio.d1ow($1+1)=1 or dta_uio.d1ow($1+1)=2 or dta_uio.d1ow($1+1)=3)), 
(($1+1)*100)+1, 
dta_uio.iif_sql( 
(($3=3) and ($2=1) and dta_uio.d1ow($1)=4) or  
(($3=2) and ($2=1) and (dta_uio.d1ow($1)=4 or dta_uio.d1ow($1)=5)) or  
(($3=1) and ($2=1) and (dta_uio.d1ow($1)=4 or dta_uio.d1ow($1)=5 or dta_uio.d1ow($1)=6)), 
(($1-1)*100)+dta_uio.smn($1-1,12,31), 
($1*100)+dta_uio.smn($1,$2,$3)))) $body$ 
LANGUAGE sql IMMUTABLE; 

--> CREATE: Funcion para el calculo del grupo de edad
CREATE OR REPLACE FUNCTION dta_uio.age_grp(d_prs_dte_str date, d_prs_dte_brt date) returns text language plpgsql AS $$
DECLARE 
  yr integer;
  mth integer;
  days integer;
  vle TEXT;
BEGIN 
 yr =  date_part('year', age(d_prs_dte_str, d_prs_dte_brt));
 mth = date_part('month', age(d_prs_dte_str, d_prs_dte_brt)) months;
 days = date_part('day', age(d_prs_dte_str, d_prs_dte_brt)) days;
 vle = 
 (SELECT 
  CASE WHEN yr = 0 AND mth = 0 THEN '<1'
       WHEN yr = 0 THEN '<1'
       WHEN yr > 0 THEN (SELECT '['||r_age_grp_min ||'-'|| r_age_grp_max ||']' FROM dta_uio.hlt_tlb_age_grp WHERE yr BETWEEN r_age_grp_min AND r_age_grp_max LIMIT 1)  
  END);
 RETURN vle;
END ;
$$; 

SELECT dta_uio.age_grp('2021-10-20', '2020-09-19');

---> 2. Verificacion de campo por campo

-- --> 2.1. sem_epi: Calculo de la semana epidemiologica con fecha de atencion 
-- --> 2.2. fecha_atencion: Cast de fecha de atencion de text a date conservando el formato
-- --> 2.3. Brigada_Num: Dejar los registros vacios (null) de numero de brigadas cuando no tengan valor
-- --> 2.4. PARROQUIA: actualizar los registros con inconsistencias
-- --> 2.5. nombre: eliminar espacios en blanco, transformar a mayusculas, se deja las cedulas ya que son la unica identificacion del paciente
-- --> 2.6. ID: eliminar espacios en blanco, transformar a mayusculas, se calcula un campo con el tamano de digitos de la cedula para validacion futura
SELECT 
  upper(trim(BOTH FROM "ID")) AS s_prs_idn,
  length(upper(trim(BOTH FROM "ID"))),
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
HAVING length(upper(trim(BOTH FROM "ID"))) < 10
ORDER BY 1,2 ;
-- --> 2.7. Nacionalidad: eliminar espacios en blanco, transformar a mayusculas, CHAD ?, GUINEA ECUATORIAL?, poniendo null a lo que no tienen registros
SELECT 
  (CASE WHEN upper(trim(BOTH FROM dta_uio.data_2020."Nacionalidad")) = '' THEN NULL ELSE upper(trim(BOTH FROM dta_uio.data_2020."Nacionalidad")) END)::TEXT  AS s_prs_nth,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;
-- --> 2.8. Sexo: eliminar espacios en blanco, transformar a mayusculas
SELECT 
 upper(trim(BOTH FROM "Sexo"))::text AS s_prs_sex,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 2.9. Autoidentificación: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Autoidentificación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Autoidentificación")) END)::TEXT  AS s_prs_eth,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 2.10. Instrucción: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Instrucción")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Instrucción")) END)::TEXT  AS s_prs_ins,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 2.11. Ocupación: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, falta correccion de palabras repetidas con diferente escritura
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Ocupación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Ocupación")) END)::TEXT  AS s_prs_ocp,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 2.12. Fecha_nac: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, registros con errores de tipeo
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Fecha_nac")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Fecha_nac")) END)::TEXT,
  "Edad",
  (CASE 
      WHEN "Fecha_nac" ilike '%jan%' THEN to_date(REPLACE("Fecha_nac", 'jan', '01')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%feb%' THEN to_date(REPLACE("Fecha_nac", 'feb', '02')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%mar%' THEN to_date(REPLACE("Fecha_nac", 'mar', '03')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%apr%' THEN to_date(REPLACE("Fecha_nac", 'apr', '04')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%may%' THEN to_date(REPLACE("Fecha_nac", 'may', '05')::text, 'ddMMyyyy')      
      WHEN "Fecha_nac" ilike '%jun%' THEN to_date(REPLACE("Fecha_nac", 'jun', '06')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%jul%' THEN to_date(REPLACE("Fecha_nac", 'jul', '07')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%aug%' THEN to_date(REPLACE("Fecha_nac", 'aug', '08')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%sep%' THEN to_date(REPLACE("Fecha_nac", 'sep', '09')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%oct%' THEN to_date(REPLACE("Fecha_nac", 'oct', '10')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%nov%' THEN to_date(REPLACE("Fecha_nac", 'nov', '11')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%dec%' THEN to_date(REPLACE("Fecha_nac", 'dec', '12')::text, 'ddMMyyyy')
      -- Condicion para personas que tienen 100 anios
      WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 7 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 7 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 8 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 8 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy') 
   ELSE 
      CASE WHEN "Fecha_nac" ilike '%/%' THEN to_date("Fecha_nac", 'dd/MM/yyyy') 
           WHEN "Fecha_nac" ilike '%-%' THEN to_date("Fecha_nac", 'yyyy-MM-dd')      
      END 
   END) AS d_prs_dte_brt
--  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL AND "Fecha_nac" NOTNULL AND "Fecha_nac" = '10/10/20'
--GROUP BY 1,2
ORDER BY 1 DESC ;
--> READ: Consulta para verificar el calculo de la edad y otros aspectos
WITH 
tmp01 AS (
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Fecha_nac")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Fecha_nac")) END)::TEXT AS s_prs_dte_brt,
  "Edad",
  (CASE 
      WHEN "Fecha_nac" ilike '%jan%' THEN to_date(REPLACE("Fecha_nac", 'jan', '01')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%feb%' THEN to_date(REPLACE("Fecha_nac", 'feb', '02')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%mar%' THEN to_date(REPLACE("Fecha_nac", 'mar', '03')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%apr%' THEN to_date(REPLACE("Fecha_nac", 'apr', '04')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%may%' THEN to_date(REPLACE("Fecha_nac", 'may', '05')::text, 'ddMMyyyy')      
      WHEN "Fecha_nac" ilike '%jun%' THEN to_date(REPLACE("Fecha_nac", 'jun', '06')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%jul%' THEN to_date(REPLACE("Fecha_nac", 'jul', '07')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%aug%' THEN to_date(REPLACE("Fecha_nac", 'aug', '08')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%sep%' THEN to_date(REPLACE("Fecha_nac", 'sep', '09')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%oct%' THEN to_date(REPLACE("Fecha_nac", 'oct', '10')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%nov%' THEN to_date(REPLACE("Fecha_nac", 'nov', '11')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%dec%' THEN to_date(REPLACE("Fecha_nac", 'dec', '12')::text, 'ddMMyyyy')
      -- Condicion para personas que tienen 100 anios
      WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 7 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 7 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 8 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 8 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy') 
   ELSE 
      CASE WHEN "Fecha_nac" ilike '%/%' THEN to_date("Fecha_nac", 'dd/MM/yyyy') 
           WHEN "Fecha_nac" ilike '%-%' THEN to_date("Fecha_nac", 'yyyy-MM-dd')      
      END 
   END) AS d_prs_dte_brt
--  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL AND "Fecha_nac" NOTNULL
ORDER BY 1 DESC)
SELECT
s_prs_dte_brt,
d_prs_dte_brt,
"Edad",
age(d_prs_dte_brt), 
-- calculo al 2020
date_part('year', age(to_date('2020-12-31', 'yyyy-MM-dd'), d_prs_dte_brt))-100,
date_part('year', age(to_date('2020-12-31', 'yyyy-MM-dd'), d_prs_dte_brt)),
date_part('month', age(to_date('2020-12-31', 'yyyy-MM-dd'), d_prs_dte_brt)),
date_part('day', age(to_date('2020-12-31', 'yyyy-MM-dd'), d_prs_dte_brt)) 
FROM tmp01
WHERE date_part('year', age(to_date('2020-12-31', 'yyyy-MM-dd'), d_prs_dte_brt)) > 100
ORDER BY 2;

--> READ: Consulta para validar casos de la Fecha de nacimiento

SELECT 
  "Fecha_nac",
  CASE 
     WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
     WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
  END 
FROM dta_uio.data_2020 AS d WHERE length("Fecha_nac") = 6
ORDER BY 1;
-- --> 2.13. presion_art: quitar valores incorrectos
SELECT  
  presion_art, 
  SPLIT_PART(CASE WHEN presion_art = '' THEN NULL
       WHEN presion_art = '-' THEN NULL
       WHEN presion_art = '.' THEN NULL
       WHEN presion_art = '0' THEN NULL
       WHEN presion_art = '1' THEN NULL
       WHEN presion_art = 'Nn' THEN NULL
       WHEN presion_art = 'No aplica' THEN NULL
       WHEN presion_art = 'No se valora' THEN NULL
       WHEN presion_art = 'Sn' THEN NULL
       WHEN presion_art ilike '%-%' THEN REPLACE(presion_art, '-', '/')
       WHEN presion_art ilike '%%%' THEN REPLACE(presion_art, '%', '/')
       WHEN presion_art ilike 'Q%' THEN REPLACE(presion_art, 'Q', '-')
  ELSE presion_art END,'/',1)
 , SPLIT_PART(presion_art, '/', 2), count(*) 
FROM dta_uio.data_2020 GROUP BY 1 ORDER BY 1;
-- --> 2.14. grup_edad: agrupar
SELECT grup_edad, count(*) FROM dta_uio.data_2020 GROUP BY 1 ORDER BY 1;
--> CREATE: tabla de grupos de edades
CREATE TABLE dta_uio.hlt_tlb_age_grp (
  i_age_grp_id serial PRIMARY KEY,
  d_age_grp_rgs_dte date DEFAULT current_date,
  s_age_grp_rgs_tme TEXT,
  s_age_grp_nme TEXT,
  r_age_grp_min double PRECISION,
  r_age_grp_max double PRECISION
);
--> INSERT: registros de los grupos de edad
INSERT INTO dta_uio.hlt_tlb_age_grp
(d_age_grp_rgs_dte, s_age_grp_rgs_tme, s_age_grp_nme, r_age_grp_min, r_age_grp_max)
VALUES(CURRENT_DATE, '11:45:02', 'Year', 0, 9);
INSERT INTO dta_uio.hlt_tlb_age_grp
(d_age_grp_rgs_dte, s_age_grp_rgs_tme, s_age_grp_nme, r_age_grp_min, r_age_grp_max)
VALUES(CURRENT_DATE, '11:45:02', 'Year', 1, 4);
INSERT INTO dta_uio.hlt_tlb_age_grp
(d_age_grp_rgs_dte, s_age_grp_rgs_tme, s_age_grp_nme, r_age_grp_min, r_age_grp_max)
VALUES(CURRENT_DATE, '11:45:02', 'Year', 5, 9);
INSERT INTO dta_uio.hlt_tlb_age_grp
(d_age_grp_rgs_dte, s_age_grp_rgs_tme, s_age_grp_nme, r_age_grp_min, r_age_grp_max)
VALUES(CURRENT_DATE, '11:45:02', 'Year', 10, 19);
INSERT INTO dta_uio.hlt_tlb_age_grp
(d_age_grp_rgs_dte, s_age_grp_rgs_tme, s_age_grp_nme, r_age_grp_min, r_age_grp_max)
VALUES(CURRENT_DATE, '11:45:02', 'Year', 20, 64);
INSERT INTO dta_uio.hlt_tlb_age_grp
(d_age_grp_rgs_dte, s_age_grp_rgs_tme, s_age_grp_nme, r_age_grp_min, r_age_grp_max)
VALUES(CURRENT_DATE, '11:45:02', 'Year', 65, 200);

SELECT * FROM dta_uio.hlt_tlb_age_grp;

-- --> 2.15. Sintomatoloía: agrupar
SELECT 
  CASE WHEN "Sintomatoloía"='' THEN NULL ELSE upper("Sintomatoloía")::TEXT END AS s_prs_snt, count(*) 
FROM dta_uio.data_2020 GROUP BY 1;

-- * Se puede completar este campo si existe algunos de los sintomas se pondria sintomatico

-- --> 2.16. Feca_inic_síntomas: depurar
SELECT
"Feca_inic_síntomas",
  (CASE WHEN (CASE WHEN SPLIT_PART("Feca_inic_síntomas", '/', 2) = '' THEN NULL ELSE SPLIT_PART("Feca_inic_síntomas", '/', 2) END)::smallint > 12 THEN to_date("Feca_inic_síntomas", 'MM/dd/yyyy')
       WHEN (CASE WHEN SPLIT_PART("Feca_inic_síntomas", '/', 2) = '' THEN NULL ELSE SPLIT_PART("Feca_inic_síntomas", '/', 2) END)::SMALLINT ISNULL THEN NULL 
       ELSE to_date("Feca_inic_síntomas", 'dd/MM/yyyy') END) 
FROM dta_uio.data_2020 GROUP BY 1;


SELECT 
  (CASE WHEN SPLIT_PART("Feca_inic_síntomas", '/', 2) = '' THEN NULL END)::NUMERIC  
FROM dta_uio.data_2020 GROUP BY 1 ORDER by 1;

-- --> 2.17. ult_fecha_viaje: depurar
SELECT 
  ult_fecha_viaje, 
  to_date(ult_fecha_viaje, 'dd/MM/yyyy'),
  count(*) 
FROM dta_uio.data_2020 GROUP BY 1 ORDER by 1;


--> CREATE: Crear la vista inicial
DROP MATERIALIZED VIEW dta_uio.data_2020_str;
CREATE MATERIALIZED VIEW dta_uio.data_2020_str AS 
SELECT 
  RIGHT(dta_uio.smn_epd(date_part('year'::text, fecha_atencion::date)::numeric, date_part('month'::text, fecha_atencion::date)::numeric, date_part('day'::text, fecha_atencion::date)::numeric)::text, 2)::smallint AS i_epi_wk,
  fecha_atencion::date AS d_uio_dte_att,
  (CASE WHEN "Brigada_Num" = '' THEN NULL WHEN "Brigada_Num" = ' ' THEN NULL ELSE "Brigada_Num" END)::text AS s_brg_nmb,
  "PARROQUIA"::text AS s_brg_prq_nme,
  "RED_GRUP"::TEXT AS s_brg_att_grp,
  "Grupoa_atencion"::TEXT AS s_brg_att_grp_sub,
  upper(trim(BOTH FROM "ID"))::TEXT  AS s_prs_idn,
  length(upper(trim(BOTH FROM "ID")))::SMALLINT AS  i_prs_idn_lng,
  upper(trim(BOTH FROM nombre))::TEXT  AS s_prs_nme,
  (CASE WHEN upper(trim(BOTH FROM "Nacionalidad")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Nacionalidad")) END)::TEXT  AS s_prs_nth,
  upper(trim(BOTH FROM "Sexo"))::text AS s_prs_sex,
  (CASE 
      WHEN "Fecha_nac" ilike '%jan%' THEN to_date(REPLACE("Fecha_nac", 'jan', '01')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%feb%' THEN to_date(REPLACE("Fecha_nac", 'feb', '02')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%mar%' THEN to_date(REPLACE("Fecha_nac", 'mar', '03')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%apr%' THEN to_date(REPLACE("Fecha_nac", 'apr', '04')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%may%' THEN to_date(REPLACE("Fecha_nac", 'may', '05')::text, 'ddMMyyyy')      
      WHEN "Fecha_nac" ilike '%jun%' THEN to_date(REPLACE("Fecha_nac", 'jun', '06')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%jul%' THEN to_date(REPLACE("Fecha_nac", 'jul', '07')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%aug%' THEN to_date(REPLACE("Fecha_nac", 'aug', '08')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%sep%' THEN to_date(REPLACE("Fecha_nac", 'sep', '09')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%oct%' THEN to_date(REPLACE("Fecha_nac", 'oct', '10')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%nov%' THEN to_date(REPLACE("Fecha_nac", 'nov', '11')::text, 'ddMMyyyy')
      WHEN "Fecha_nac" ilike '%dec%' THEN to_date(REPLACE("Fecha_nac", 'dec', '12')::text, 'ddMMyyyy')
      -- Condicion para personas que tienen 100 anios
      WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 7 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 7 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 8 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
      WHEN length("Fecha_nac") = 8 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy') 
   ELSE 
      CASE WHEN "Fecha_nac" ilike '%/%' THEN to_date("Fecha_nac", 'dd/MM/yyyy') 
           WHEN "Fecha_nac" ilike '%-%' THEN to_date("Fecha_nac", 'yyyy-MM-dd')      
      END 
   END) AS d_prs_dte_brt,
   "Edad"::SMALLINT AS i_prs_dte_brt_yr,
   grup_edad::TEXT AS s_prs_age_grp,
  (CASE WHEN upper(trim(BOTH FROM "Autoidentificación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Autoidentificación")) END)::TEXT  AS s_prs_eth,
  (CASE WHEN upper(trim(BOTH FROM "Instrucción")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Instrucción")) END)::TEXT  AS s_prs_ins,
  (CASE WHEN upper(trim(BOTH FROM "Ocupación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Ocupación")) END)::TEXT  AS s_prs_ocp,
  (CASE WHEN upper(trim(BOTH FROM "Provinciaresidencia"::TEXT)) = '' THEN NULL ELSE upper(trim(BOTH FROM "Provinciaresidencia"::TEXT)) END) AS s_prs_rsd_prv_nme,
  (CASE WHEN upper(trim(BOTH FROM "Parroquiaresidencia"::TEXT)) = '' THEN NULL ELSE upper(trim(BOTH FROM "Parroquiaresidencia"::TEXT)) END) AS s_prs_rsd_prq_nme,
  (CASE WHEN upper(trim(BOTH FROM "Barrioresidencia"::TEXT)) = '' THEN NULL ELSE upper(trim(BOTH FROM "Barrioresidencia"::TEXT)) END) AS s_prs_rsd_brr_nme,
  (CASE WHEN upper(trim(BOTH FROM "Dirección"::TEXT)) = '' THEN NULL ELSE upper(trim(BOTH FROM "Dirección"::TEXT)) END) AS s_prs_rsd_adr,
  (CASE WHEN upper(trim(BOTH FROM "Viaje_fuera"::TEXT)) = '' THEN NULL ELSE upper(trim(BOTH FROM "Viaje_fuera"::TEXT)) END) AS s_prs_trv,
  ult_fecha_viaje AS d_prs_trv_dte,
  "Lugarviaje"::TEXT AS s_prs_trv_ste,
  SPLIT_PART(CASE WHEN presion_art = '' THEN NULL
       WHEN presion_art = '-' THEN NULL
       WHEN presion_art = '.' THEN NULL
       WHEN presion_art = '0' THEN NULL
       WHEN presion_art = '1' THEN NULL
       WHEN presion_art = 'Nn' THEN NULL
       WHEN presion_art = 'No aplica' THEN NULL
       WHEN presion_art = 'No se valora' THEN NULL
       WHEN presion_art = 'Sn' THEN NULL
       WHEN presion_art ilike '%-%' THEN REPLACE(presion_art, '-', '/')
       WHEN presion_art ilike '%%%' THEN REPLACE(presion_art, '%', '/')
       WHEN presion_art ilike 'Q%' THEN REPLACE(presion_art, 'Q', '-')
  ELSE presion_art END,'/',1) AS r_sgn_prs_stl, --dst
  SPLIT_PART(CASE WHEN presion_art = '' THEN NULL
       WHEN presion_art = '-' THEN NULL
       WHEN presion_art = '.' THEN NULL
       WHEN presion_art = '0' THEN NULL
       WHEN presion_art = '1' THEN NULL
       WHEN presion_art = 'Nn' THEN NULL
       WHEN presion_art = 'No aplica' THEN NULL
       WHEN presion_art = 'No se valora' THEN NULL
       WHEN presion_art = 'Sn' THEN NULL
       WHEN presion_art ilike '%-%' THEN REPLACE(presion_art, '-', '/')
       WHEN presion_art ilike '%%%' THEN REPLACE(presion_art, '%', '/')
       WHEN presion_art ilike 'Q%' THEN REPLACE(presion_art, 'Q', '-')
  ELSE presion_art END,'/',2) AS r_sgn_prs_dst,
  "Frec_card"::numeric AS r_sgn_frc_crd,
  "Frec_resp"::numeric AS r_sgn_frc_rsp,
  (CASE WHEN "Sat_O2" = '' THEN NULL ELSE round("Sat_O2"::NUMERIC,2)::NUMERIC END) AS r_sgn_str_oxg,
  (CASE WHEN "Temp" = '#NULL!' THEN NULL WHEN "Temp" = '' THEN NULL WHEN "Temp" = ' ' THEN NULL ELSE round("Temp"::NUMERIC,2)::NUMERIC END) AS r_sgn_tpr,
  discapacidad::TEXT AS s_prs_qst_dsc,
  "Hatenidocontactoconuncasoc":: TEXT AS s_prs_qst_cse,
  "DG_inicial"::TEXT AS s_prs_qst_dgn,
  "Lugar_proB_infecc"::TEXT AS s_prs_qst_ifc,
  CASE WHEN "Sintomatoloía"='' THEN NULL ELSE upper("Sintomatoloía")::TEXT END AS s_prs_qst_snt,
  (CASE WHEN (CASE WHEN SPLIT_PART("Feca_inic_síntomas", '/', 2) = '' THEN NULL ELSE SPLIT_PART("Feca_inic_síntomas", '/', 2) END)::smallint > 12 THEN to_date("Feca_inic_síntomas", 'MM/dd/yyyy')
       WHEN (CASE WHEN SPLIT_PART("Feca_inic_síntomas", '/', 2) = '' THEN NULL ELSE SPLIT_PART("Feca_inic_síntomas", '/', 2) END)::SMALLINT ISNULL THEN NULL 
       ELSE to_date("Feca_inic_síntomas", 'dd/MM/yyyy') END) AS d_prs_qst_dte_snt,
  "Fiebre"::TEXT AS s_prs_snt_fbr,
  "Perdida_gusto_olfato"::TEXT AS  s_prs_snt_gst_olf,
  "Tos"::TEXT AS s_prs_snt_tos,
  "Disnea"::TEXT AS s_prs_snt_dsn,
  "Dolorenlagarganta"::text AS s_prs_snt_dlr_grg,
  "Náuseaovómito"::TEXT AS s_prs_snt_dlr_nse_vmt,
  "Diarrea"::TEXT AS s_prs_snt_drr,
  "Escalofrios"::TEXT AS s_prs_snt_esc,
  "Confusiónodificultadparaesta"::TEXT AS s_prs_snt_cnf,
  "Doloropresiónpersistenteene"::TEXT AS s_prs_snt_dlr,
  "Cianosis"::TEXT AS s_prs_snt_cns,
  "Comorbilidad"::TEXT AS s_prs_qst_cmb,
  "Enfermedadescardiovascularesa"::TEXT AS s_prs_cmb_enf_crd_vsc,
  "Diabetes"::TEXT AS s_prs_cmb_dbt,
  "Hipertensión"::TEXT AS s_prs_cmb_hpr,
  "Obesidadsevera"::TEXT AS s_prs_cmb_obs_svr,
  "Enfermedadesrenalesinsuficien"::TEXT AS s_prs_cmb_enf_rnl_isf,
  "Enfermedadeshepáticasinsufici"::TEXT AS s_prs_cmb_enf_hpt_isf,
  "Enfermedadespulmonaresasma"::TEXT AS s_prs_cmb_enf_plm_asm,
  "Unidadnotifica"::TEXT AS s_unt_ntf  
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
ORDER BY 1,2,3;

-- * Correjir los sintomas poner null 

SELECT * FROM dta_uio.data_2020;

--> READ: Vista para consumo DINARDAP, limpieza de datos del campo cedula
DROP VIEW dta_uio.data_2020_id;
CREATE OR REPLACE VIEW dta_uio.data_2020_id AS 
SELECT
  "ID1" AS i_prs_idn,
  fecha_atencion::date AS d_prs_dte_att,
  fecha_atencion::text AS s_prs_dte_att,
  upper(trim(BOTH FROM "ID"))::TEXT  AS s_prs_idn,
  length(upper(trim(BOTH FROM "ID")))::SMALLINT AS  i_prs_idn_lng,
  upper(trim(BOTH FROM nombre))::TEXT  AS s_prs_nme,
  
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
ORDER BY 1;
--> READ: Leer vista creada
SELECT * FROM dta_uio.data_2020_id;
--> SAVE: Identificaciones correctas
CREATE TABLE dta_tbl_prs(s_prs_idn TEXT);
--> SAVE: Identificaciones incorrectas con size = 10
CREATE TABLE dta_tbl_prs_10(s_prs_idn TEXT);
--> SAVE: Identificaciones incorrectas con size = 09
CREATE TABLE dta_tbl_prs_09(s_prs_idn TEXT);
--> SAVE: Identificaciones incorrectas extranjeras, erroneas, etc.
CREATE TABLE dta_tbl_prs_all(s_prs_idn TEXT);
--> DELETE: Para correr algoritmo
DELETE FROM dta_tbl_prs;
DELETE FROM dta_tbl_prs_10;
DELETE FROM dta_tbl_prs_09;
DELETE FROM dta_tbl_prs_all;
--> READ: Consultar identificaciones correctas despues de correr el algoritmo de limpieza
SELECT * FROM dta_tbl_prs;
--> READ: Contar por size de identificaciones
SELECT length(trim(BOTH s_prs_idn)), count(*) FROM dta_uio.data_2020_id group BY 1 ORDER BY 1; 
--> READ: Agrupar identificaciones si size = 9 
SELECT s_prs_idn FROM dta_uio.data_2020_id WHERE length(trim(BOTH s_prs_idn)) = 9 group BY 1 ORDER BY 1; 
--> READ: Contar identificaciones erroneas si size = 10 
SELECT length(trim(BOTH s_prs_idn)), count(*) FROM dta_tbl_prs_10 group BY 1 ORDER BY 1; 
--> READ: Contar identificaciones erroneas si size = 09 
SELECT length(trim(BOTH s_prs_idn)), count(*) FROM dta_tbl_prs_09 group BY 1 ORDER BY 1; 
--> READ: Contar identificaciones erroneas 
SELECT length(trim(BOTH s_prs_idn)), count(*) FROM dta_tbl_prs_all group BY 1 ORDER BY 1; 
--> READ: Consultar identificaciones con size = 10 
SELECT * FROM dta_tbl_prs_10;
--> DELETE: Eliminar datos
DELETE FROM dta_tbl_prs_dnr;
--> DROP: Eliminar la tabla dentro de la base de datos
DROP TABLE dta_tbl_prs_dnr;
--> CREATE: Crear la tabla dentro de la base de datos
CREATE TABLE dta_tbl_prs_dnr(
  i_prs_id serial PRIMARY KEY ,
  s_prs_idn TEXT,
  s_prs_cyg TEXT,
  s_prs_stt TEXT,
  s_prs_dte_dfn TEXT,
  s_prs_dte_brt TEXT,
  s_prs_adr TEXT,
  s_prs_nme TEXT,
  s_prs_prf TEXT,
  d_prs_rgs_dte date DEFAULT current_date,
  s_prs_rgs_tme text
);
--> READ: Consultar cuantas veces se repiten las identificaciones 
SELECT s_prs_idn, count(1) FROM dta_tbl_prs_dnr GROUP BY 1 HAVING count(*) > 1 ORDER BY 1;
--> READ: Consultar los datos encontrados en la DINARDAP de las identificaciones correctas 
SELECT * FROM dta_tbl_prs_dnr ORDER BY 1 DESC;

--> READ: Consultar la ultima identificacion consultada
SELECT * FROM dta_tbl_prs where s_prs_idn = '1708442320';
SELECT * FROM dta_tbl_prs ORDER BY 2 DESC;


--> READ: UNIR LA TABLA DINARDAP CON LA TABLA DE CEDULAS TOTALES
SELECT * 
FROM dta_uio.data_2020_id; -- 67923
SELECT * FROM dta_tbl_prs; -- 63565
SELECT * FROM dta_tbl_prs_dnr; --63536
-- DIFERENCIA ~~ 35
WITH 
tmp01 AS (
SELECT
  prs.i_prs_id AS i_fnt_prs_id,
  prs.s_prs_idn AS s_fnt_prs_idn,
  prs_dnr.s_prs_idn AS s_dnr_prs_idn,
  prs_dnr.s_prs_nme AS s_dnr_prs_nme,
  to_date(prs_dnr.s_prs_dte_brt,'dd/MM/yyyy') AS d_dnr_prs_dte_brt,
  to_date((CASE WHEN prs_dnr.s_prs_dte_dfn='' THEN NULL ELSE prs_dnr.s_prs_dte_dfn END),'dd/MM/yyyy') AS d_dnr_prs_dte_dfn,  
  prs_dnr.s_prs_prf AS s_dnr_prs_prf,
  CASE WHEN prs_dnr.s_prs_cyg = '' THEN NULL ELSE prs_dnr.s_prs_cyg END AS s_dnr_prs_cyg,
  prs_dnr.s_prs_stt AS s_dnr_prs_stt,
  SPLIT_PART(prs_dnr.s_prs_adr, '/', 1) AS s_dnr_prv_brt_nme,
  SPLIT_PART(prs_dnr.s_prs_adr, '/', 2) AS s_dnr_cnt_brt_nme,
  SPLIT_PART(prs_dnr.s_prs_adr, '/', 3) AS s_dnr_prq_brt_nme
FROM dta_tbl_prs prs
LEFT JOIN dta_tbl_prs_dnr prs_dnr ON prs_dnr.s_prs_idn = prs.s_prs_idn
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
ORDER BY 1)
SELECT
  dta.i_epi_wk, 
  dta.d_uio_dte_att,
  dta.s_brg_att_grp,
  dta.s_brg_att_grp_sub,
  dta.s_brg_prq_nme,
  dta.s_brg_nmb,
  dta.s_prs_idn AS s_fnt_prs_idn,
  tmp01.s_dnr_prs_idn,
  dta.s_prs_nme AS s_fnt_prs_nme,
  tmp01.s_dnr_prs_nme,
  dta.s_prs_sex AS s_fnt_prs_sex,
  dta.s_prs_nth AS s_fnt_prs_nth,
  dta.d_prs_dte_brt AS d_fnt_prs_dte_brt,
  tmp01.d_dnr_prs_dte_brt,
  dta.i_prs_dte_brt_yr AS i_fnt_prs_dte_brt_yr,
  date_part('year', age(dta.d_uio_dte_att, dta.d_prs_dte_brt)) AS i_fnt_prs_brt_yr,
  date_part('month', age(dta.d_uio_dte_att, dta.d_prs_dte_brt)) AS i_fnt_prs_brt_mth,
  date_part('day', age(dta.d_uio_dte_att, dta.d_prs_dte_brt)) AS i_fnt_prs_brt_day,
  date_part('year', age(dta.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt)) AS i_dnr_prs_brt_yr,
  date_part('month', age(dta.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt)) AS i_dnr_prs_brt_mth,
  date_part('day', age(dta.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt)) AS i_dnr_prs_brt_day,
  dta.s_prs_age_grp AS s_fnt_prs_age_grp,
  dta_uio.age_grp(dta.d_uio_dte_att, dta.d_prs_dte_brt) AS s_fnt_prs_age_grp_clc,
  dta_uio.age_grp(dta.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt) AS s_dnr_prs_age_grp_clc,
  dta.s_prs_eth AS s_fnt_prs_eth,
  dta.s_prs_ins AS s_fnt_prs_ins,
  dta.s_prs_ocp AS s_fnt_prs_ocp,
  tmp01.s_dnr_prs_prf,
  dta.r_sgn_prs_stl AS r_fnt_sgn_prs_stl,
  dta.r_sgn_prs_dst AS r_fnt_sgn_prs_dst,
  dta.r_sgn_frc_crd AS r_fnt_sgn_frc_crd,
  dta.r_sgn_frc_rsp AS r_fnt_sgn_frc_rsp,
  dta.r_sgn_str_oxg AS r_fnt_sgn_str_oxg,
  dta.r_sgn_tpr AS r_fnt_sgn_tpr,
  dta.s_prs_rsd_prv_nme AS s_fnt_prs_rsd_prv_nme,
  dta.s_prs_rsd_prq_nme AS s_fnt_prs_rsd_prq_nme,
  tmp01.s_dnr_prv_brt_nme AS s_dnr_prv_brt_nme,
  tmp01.s_dnr_cnt_brt_nme AS s_dnr_cnt_brt_nme,
  tmp01.s_dnr_prq_brt_nme AS s_dnr_prq_brt_nme,
  dta_uio.sif_sql(dta.s_prs_rsd_prv_nme ISNULL, tmp01.s_dnr_prv_brt_nme, dta.s_prs_rsd_prv_nme) AS s_gnr_prs_rsd_prv_nme,
  dta_uio.sif_sql(dta.s_prs_rsd_prq_nme ISNULL, tmp01.s_dnr_prq_brt_nme, dta.s_prs_rsd_prq_nme) AS s_gnr_prs_rsd_prq_nme,
  dta.s_prs_rsd_brr_nme AS s_fnt_prs_rsd_brr_nme,
  dta.s_prs_rsd_adr AS s_fnt_prs_rsd_adr,
  dta.s_prs_trv AS s_fnt_prs_trv,
  dta.d_prs_trv_dte AS d_fnt_prs_trv_dte,
  dta.s_prs_trv_ste AS s_fnt_prs_trv_ste
FROM dta_uio.data_2020_str dta
FULL JOIN tmp01 ON tmp01.s_fnt_prs_idn = dta.s_prs_idn
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
         31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46
ORDER BY 1,2;




