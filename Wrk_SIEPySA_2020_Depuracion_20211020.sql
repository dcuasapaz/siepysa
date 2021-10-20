-- Crear schema dta_uio
CREATE SCHEMA dta_uio AUTHORIZATION siepysa;
-- Cambiar de schema a la tabla importada
ALTER TABLE public.DATA_2020 SET SCHEMA dta_uio;
-- Consultar tabla movida a nuevo esquema
SELECT * FROM dta_uio.DATA_2020 AS D;
-- Depuracion de datos
--- 1. Creacion de funciones para uso dentro de la depuracion

CREATE OR REPLACE FUNCTION dta_uio.iif_sql(BOOLEAN, numeric, numeric) returns numeric AS
$body$ SELECT case $1 when true then $2 else $3 end $body$
LANGUAGE sql IMMUTABLE;
---2.función que permite cambiar valores nulos
CREATE OR REPLACE FUNCTION dta_uio.sif_sql(BOOLEAN, text, text) returns TEXT AS
$body$ SELECT case $1 when true then $2 else $3 end $body$
LANGUAGE sql IMMUTABLE;

-- semana epidemiologica
CREATE OR REPLACE FUNCTION dta_uio.d1ow(numeric) returns smallint AS 
-- $1=a?o 
$body$ SELECT extract(dow from date (to_char($1,'9999')||'/01/01'))::smallint $body$ 
LANGUAGE sql IMMUTABLE;
 
CREATE OR REPLACE FUNCTION dta_uio.C1(numeric) returns integer AS 
-- $1=a?o 
$body$ SELECT case dta_uio.d1ow($1) when 0 then -1 when 1 then 0 when 2 then 1 when 3 then 2 when 4 then -4 when 5 then -3 when 6 then -2 end $body$ 
LANGUAGE sql IMMUTABLE; 

--4. permite cambiar formato de fecha
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

--- 1. Contando los campos
-- --> 1. sem_epi: Calculo de la semana epidemiologica con fecha de atencion 
-- --> 2. fecha_atencion: Cast de fecha de atencion de text a date conservando el formato
-- --> 3. Brigada_Num: Dejar los registros vacios (null) de numero de brigadas cuando no tengan valor
-- --> 4. PARROQUIA: actualizar los registros con inconsistencias
-- --> 5. nombre: eliminar espacios en blanco, transformar a mayusculas, se deja las cedulas ya que son la unica identificacion del paciente
-- --> 6. ID: eliminar espacios en blanco, transformar a mayusculas, se calcula un campo con el tamano de digitos de la cedula para validacion futura
 
SELECT 
  upper(trim(BOTH FROM "ID")) AS s_prs_idn,
  length(upper(trim(BOTH FROM "ID"))),
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
HAVING length(upper(trim(BOTH FROM "ID"))) < 10
ORDER BY 1,2 ;
-- --> 7. Nacionalidad: eliminar espacios en blanco, transformar a mayusculas, CHAD ?, GUINEA ECUATORIAL?, poniendo null a lo que no tienen registros
SELECT 
  (CASE WHEN upper(trim(BOTH FROM dta_uio.data_2020."Nacionalidad")) = '' THEN NULL ELSE upper(trim(BOTH FROM dta_uio.data_2020."Nacionalidad")) END)::TEXT  AS s_prs_nth,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;
-- --> 8. Sexo: eliminar espacios en blanco, transformar a mayusculas
SELECT 
 upper(trim(BOTH FROM "Sexo"))::text AS s_prs_sex,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 9. Autoidentificación: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Autoidentificación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Autoidentificación")) END)::TEXT  AS s_prs_eth,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 10. Instrucción: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Instrucción")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Instrucción")) END)::TEXT  AS s_prs_ins,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 11. Ocupación: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, falta correccion de palabras repetidas con diferente escritura
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Ocupación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Ocupación")) END)::TEXT  AS s_prs_ocp,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
GROUP BY 1
ORDER BY 1 ;

-- --> 12. Fecha_nac: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, registros con errores de tipeo
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

--->13. permite validar y calcular la edad segun la fecha de nacimiento, toma los valores de lafecha de nacimito que estan escritas de 6,7 y 8 digitos las compara y toma el año en formato de 2 digitos y las completa con el 19 o 20 según el caso 1999 o 2001
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


-->14. toma los valores de lafecha de nacimito que estan escritas de 6 digitos las compara y toma el año en foemato de 2 digitos y las completa con el 19 o 20 según el caso 1999 o 2001
SELECT 
  "Fecha_nac",
  CASE 
     WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
     WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
  END 
FROM dta_uio.data_2020 AS d WHERE length("Fecha_nac") = 6
ORDER BY 1;

UPDATE dta_uio.data_2020 SET "PARROQUIA" = 'SAN BLAS' WHERE "PARROQUIA" = 'SAN BLAS ';

SELECT * FROM dta_uio.data_2020 LIMIT 10;



--15. valida espacios en blaclo /, 0, n, no, sn, en el campo de presion arterial los cambia por null o corrige /
SELECT  
  presion_art, 
  CASE WHEN presion_art = '' THEN NULL
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
  ELSE 
      presion_art
 END, SPLIT_PART(presion_art, '/', 2), count(*) 
FROM dta_uio.data_2020 GROUP BY 1 ORDER BY 1;

--- 2. Construyendo la vista, 
CREATE OR REPLACE VIEW tst_ptt AS 
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
  (CASE WHEN upper(trim(BOTH FROM "Autoidentificación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Autoidentificación")) END)::TEXT  AS s_prs_eth,
  (CASE WHEN upper(trim(BOTH FROM "Instrucción")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Instrucción")) END)::TEXT  AS s_prs_ins,
  (CASE WHEN upper(trim(BOTH FROM "Ocupación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Ocupación")) END)::TEXT  AS s_prs_ocp,
  SPLIT_PART(presion_art, '/', 1) AS r_sgn_prs_stl, --dst
  "Frec_card"::numeric AS r_sgn_frc_crd,
  "Frec_resp"::numeric AS r_sgn_frc_rsp,
  (CASE WHEN "Sat_O2" = '' THEN NULL ELSE round("Sat_O2"::NUMERIC,2)::NUMERIC END) AS r_sgn_str_oxg,
  (CASE WHEN "Temp" = '#NULL!' THEN NULL WHEN "Temp" = '' THEN NULL WHEN "Temp" = ' ' THEN NULL ELSE round("Temp"::NUMERIC,2)::NUMERIC END) AS r_sgn_tpr
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL 
ORDER BY 1,2,3;

--16. crecion de tablas para validacion en la dinardap, segmentado si las cedulas son validas y si permitio compltar los digitos de cedulas comenzadas en 0  
CREATE TABLE dta_tbl_prs(
  s_prs_idn TEXT
)

CREATE TABLE dta_tbl_prs_10(
  s_prs_idn TEXT
)

CREATE TABLE dta_tbl_prs_09(
  s_prs_idn TEXT
)

CREATE TABLE dta_tbl_prs_all(
  s_prs_idn TEXT
)

--17. eliminacion de tablas para la busqueda en la dinardap de cedulas
DELETE FROM dta_tbl_prs;
DELETE FROM dta_tbl_prs_10;
DELETE FROM dta_tbl_prs_09;
DELETE FROM dta_tbl_prs_all;
--17.1 consultas de talbas creadas apara validación de informacion generada.
SELECT * FROM dta_tbl_prs;

SELECT length(trim(BOTH s_prs_idn)), count(*) FROM tst_ptt group BY 1 ORDER BY 1; 
SELECT s_prs_idn FROM tst_ptt WHERE length(trim(BOTH s_prs_idn)) = 9 group BY 1 ORDER BY 1; 
SELECT length(trim(BOTH s_prs_idn)), count(8) FROM dta_tbl_prs_10 group BY 1 ORDER BY 1; 
SELECT length(trim(BOTH s_prs_idn)), count(8) FROM dta_tbl_prs_09 group BY 1 ORDER BY 1; 
SELECT length(trim(BOTH s_prs_idn)), count(8) FROM dta_tbl_prs_all group BY 1 ORDER BY 1; 

SELECT * FROM dta_tbl_prs_10;

--17.2 creacion de la nueva tabla persona dinardap
CREATE SEQUENCE dta_sqn_prs_dnr;

ALTER SEQUENCE dta_sqn_prs_dnr
OWNED BY dta_tbl_prs_dnr.i_prs_id;
DROP TABLE dta_tbl_prs_dnr;

DELETE FROM dta_tbl_prs_dnr;
DROP TABLE dta_tbl_prs_dnr;
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

--DELETE FROM dta_tbl_prs_dnr;

SELECT s_prs_idn, count(1) FROM dta_tbl_prs_dnr GROUP BY 1 HAVING count(*) > 1 ORDER BY 1;

SELECT s_prs_idn, count(1)  FROM dta_tbl_prs WHERE i_prs_id BETWEEN 1 AND 4000  GROUP BY 1 HAVING count(*) > 1 ORDER BY 1;

SELECT * FROM dta_tbl_prs_dnr ORDER BY 1;

SELECT * FROM dta_tbl_prs AS dtp WHERE i_prs_id BETWEEN 1 AND 1000 ORDER BY 1;

ALTER TABLE dta_tbl_prs ADD COLUMN i_prs_id serial NOT NULL PRIMARY KEY;

SELECT * FROM dta_tbl_prs AS dtp WHERE i_prs_id BETWEEN 1 AND 2000 ORDER BY 2;

select * from dta_tbl_prs_dnr order by 1 desc ;
