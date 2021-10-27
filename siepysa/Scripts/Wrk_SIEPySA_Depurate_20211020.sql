-----------------------------------------------------------------------------------------------------------------------------------------------
-- DATA - 2020
-----------------------------------------------------------------------------------------------------------------------------------------------
--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date--> 2021-10-19
-- Comment --> Inicio de depuracion de datos
--*******************************************************************************************************************************************--

---> READ: Consulta para obtener los registros depurados por campo de 2020
-----------------------------------------------------------------------------------------------------------------------------------------------
-- SQL --> Limpieza de datos
-----------------------------------------------------------------------------------------------------------------------------------------------
--> 1. sem_epi: Calculo de la semana epidemiologica con fecha de atencion 
--> 2. fecha_atencion: Cast de fecha de atencion de text a date conservando el formato
--> 3. Brigada_Num: Dejar los registros vacios (null) de numero de brigadas cuando no tengan valor
--> 4. PARROQUIA: actualizar los registros con inconsistencias
--> 5. nombre: eliminar espacios en blanco, transformar a mayusculas, se deja las cedulas ya que son la unica identificacion del paciente
--> 6. ID: eliminar espacios en blanco, transformar a mayusculas, se calcula un campo con el tamano de digitos de la cedula para validacion futura
SELECT 
  upper(trim(BOTH FROM "ID")) AS s_prs_idn,
  length(upper(trim(BOTH FROM "ID"))),
  Count(*)
FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL GROUP BY 1 HAVING length(upper(trim(BOTH FROM "ID"))) < 10 ORDER BY 1,2 ;
--> 7. Nacionalidad: eliminar espacios en blanco, transformar a mayusculas, CHAD ?, GUINEA ECUATORIAL?, poniendo null a lo que no tienen registros
SELECT 
  (CASE WHEN upper(trim(BOTH FROM dta_uio.data_2020."Nacionalidad")) = '' THEN NULL ELSE upper(trim(BOTH FROM dta_uio.data_2020."Nacionalidad")) END)::TEXT  AS s_prs_nth,
  Count(*)
FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL GROUP BY 1 ORDER BY 1 ;
--> 8. Sexo: eliminar espacios en blanco, transformar a mayusculas
SELECT 
 upper(trim(BOTH FROM "Sexo"))::text AS s_prs_sex,
  Count(*)
FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL GROUP BY 1 ORDER BY 1 ;
--> 9. Autoidentificación: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Autoidentificación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Autoidentificación")) END)::TEXT  AS s_prs_eth,
  Count(*)
FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL GROUP BY 1 ORDER BY 1 ;
--> 10. Instrucción: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Instrucción")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Instrucción")) END)::TEXT  AS s_prs_ins,
  Count(*)
FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL GROUP BY 1 ORDER BY 1 ;
--> 11. Ocupación: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, falta correccion de palabras repetidas con diferente escritura
SELECT
  (CASE WHEN upper(trim(BOTH FROM "Ocupación")) = '' THEN NULL ELSE upper(trim(BOTH FROM "Ocupación")) END)::TEXT  AS s_prs_ocp,
  Count(*)
FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL GROUP BY 1 ORDER BY 1 ;
--> 12. Fecha_nac: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, registros con errores de tipeo
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
   END) AS d_prs_dte_brt,
  Count(*)
FROM dta_uio.data_2020
WHERE fecha_atencion NOTNULL AND "Fecha_nac" NOTNULL
GROUP BY 1,2,3
ORDER BY 1;
---> READ: Consulta para verificar el calculo de la edad con la fecha de nacimiento
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
---> READ: Verificar ciertos casos de la fecha de nacimiento, cuando el formato esta dd/mm/yy
SELECT 
  "Fecha_nac",
  CASE 
     WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT > 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '19' || RIGHT("Fecha_nac",2)),'dd/MM/yyyy')
     WHEN length("Fecha_nac") = 6 AND RIGHT("Fecha_nac",2)::SMALLINT <= 20 THEN to_date(REPLACE("Fecha_nac", RIGHT("Fecha_nac",2), '20' || RIGHT("Fecha_nac",2) ),'dd/MM/yyyy')
  END 
FROM dta_uio.data_2020 AS d WHERE length("Fecha_nac") = 6
ORDER BY 1;
--> 13. PARROQUIA: Actualizar cierto valores de este campo
UPDATE dta_uio.data_2020 SET "PARROQUIA" = 'SAN BLAS' WHERE "PARROQUIA" = 'SAN BLAS ';
--> 14 presion_art: depurar este campo
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

--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date --> 2021-10-19; 2021-10-20
-- Comment --> Vista consolidada de los datos 2020
--*******************************************************************************************************************************************--
---> CREATE: Crear la vista con los campos depurados anteriormente
DROP MATERIALIZED VIEW dta_uio.data_2020_fnt;
CREATE MATERIALIZED VIEW dta_uio.data_2020_fnt AS 
SELECT "right"(dta_uio.smn_epd(date_part('year'::text, data_2020.fecha_atencion::date)::numeric, date_part('month'::text, data_2020.fecha_atencion::date)::numeric, date_part('day'::text, data_2020.fecha_atencion::date)::numeric)::text, 2)::smallint AS i_fnt_epi_wk,
    data_2020.fecha_atencion::date AS d_fnt_uio_dte_att,
        CASE
            WHEN data_2020."Brigada_Num"::text = ''::text THEN NULL::character varying
            WHEN data_2020."Brigada_Num"::text = ' '::text THEN NULL::character varying
            ELSE data_2020."Brigada_Num"
        END::text AS s_fnt_brg_nmb,
    data_2020."RED_GRUP"::text AS s_fnt_brg_att_grp,
    data_2020."Grupoa_atencion"::text AS s_fnt_brg_att_grp_sub,
    data_2020."PARROQUIA"::text AS s_fnt_prq_att,
    upper(btrim(data_2020."ID"::text)) AS s_fnt_prs_idn,
    length(upper(btrim(data_2020."ID"::text)))::smallint AS i_fnt_prs_idn_lng,
    upper(btrim(data_2020.nombre::text)) AS s_fnt_prs_nme,
        CASE
            WHEN upper(btrim(data_2020."Nacionalidad"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Nacionalidad"::text))
        END AS s_fnt_prs_nth,
    upper(btrim(data_2020."Sexo"::text)) AS s_fnt_prs_sex,
        CASE
            WHEN data_2020."Fecha_nac"::text ~~* '%jan%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'jan'::text, '01'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%feb%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'feb'::text, '02'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%mar%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'mar'::text, '03'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%apr%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'apr'::text, '04'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%may%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'may'::text, '05'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%jun%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'jun'::text, '06'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%jul%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'jul'::text, '07'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%aug%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'aug'::text, '08'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%sep%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'sep'::text, '09'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%oct%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'oct'::text, '10'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%nov%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'nov'::text, '11'::text), 'ddMMyyyy'::text)
            WHEN data_2020."Fecha_nac"::text ~~* '%dec%'::text THEN to_date(replace(data_2020."Fecha_nac"::text, 'dec'::text, '12'::text), 'ddMMyyyy'::text)
            WHEN length(data_2020."Fecha_nac"::text) = 6 AND "right"(data_2020."Fecha_nac"::text, 2)::smallint > 20 THEN to_date(replace(data_2020."Fecha_nac"::text, "right"(data_2020."Fecha_nac"::text, 2), '19'::text || "right"(data_2020."Fecha_nac"::text, 2)), 'dd/MM/yyyy'::text)
            WHEN length(data_2020."Fecha_nac"::text) = 6 AND "right"(data_2020."Fecha_nac"::text, 2)::smallint <= 20 THEN to_date(replace(data_2020."Fecha_nac"::text, "right"(data_2020."Fecha_nac"::text, 2), '20'::text || "right"(data_2020."Fecha_nac"::text, 2)), 'dd/MM/yyyy'::text)
            WHEN length(data_2020."Fecha_nac"::text) = 7 AND "right"(data_2020."Fecha_nac"::text, 2)::smallint > 20 THEN to_date(replace(data_2020."Fecha_nac"::text, "right"(data_2020."Fecha_nac"::text, 2), '19'::text || "right"(data_2020."Fecha_nac"::text, 2)), 'dd/MM/yyyy'::text)
            WHEN length(data_2020."Fecha_nac"::text) = 7 AND "right"(data_2020."Fecha_nac"::text, 2)::smallint <= 20 THEN to_date(replace(data_2020."Fecha_nac"::text, "right"(data_2020."Fecha_nac"::text, 2), '20'::text || "right"(data_2020."Fecha_nac"::text, 2)), 'dd/MM/yyyy'::text)
            WHEN length(data_2020."Fecha_nac"::text) = 8 AND "right"(data_2020."Fecha_nac"::text, 2)::smallint > 20 THEN to_date(replace(data_2020."Fecha_nac"::text, "right"(data_2020."Fecha_nac"::text, 2), '19'::text || "right"(data_2020."Fecha_nac"::text, 2)), 'dd/MM/yyyy'::text)
            WHEN length(data_2020."Fecha_nac"::text) = 8 AND "right"(data_2020."Fecha_nac"::text, 2)::smallint <= 20 THEN to_date(replace(data_2020."Fecha_nac"::text, "right"(data_2020."Fecha_nac"::text, 2), '20'::text || "right"(data_2020."Fecha_nac"::text, 2)), 'dd/MM/yyyy'::text)
            ELSE
            CASE
                WHEN data_2020."Fecha_nac"::text ~~* '%/%'::text THEN to_date(data_2020."Fecha_nac"::text, 'dd/MM/yyyy'::text)
                WHEN data_2020."Fecha_nac"::text ~~* '%-%'::text THEN to_date(data_2020."Fecha_nac"::text, 'yyyy-MM-dd'::text)
                ELSE NULL::date
            END
        END AS d_fnt_prs_dte_brt,
    data_2020."Edad"::smallint AS i_fnt_prs_dte_brt_yr,
    data_2020.grup_edad::text AS s_fnt_prs_age_grp,
        CASE
            WHEN upper(btrim(data_2020."Autoidentificación"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Autoidentificación"::text))
        END AS s_fnt_prs_eth,
        CASE
            WHEN upper(btrim(data_2020."Instrucción"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Instrucción"::text))
        END AS s_fnt_prs_ins,
        CASE
            WHEN upper(btrim(data_2020."Ocupación"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Ocupación"::text))
        END AS s_fnt_prs_ocp,
        CASE
            WHEN upper(btrim(data_2020."Provinciaresidencia"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Provinciaresidencia"::text))
        END AS s_fnt_prs_rsd_prv_nme,
        CASE
            WHEN upper(btrim(data_2020."Parroquiaresidencia"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Parroquiaresidencia"::text))
        END AS s_fnt_prs_rsd_prq_nme,
        CASE
            WHEN upper(btrim(data_2020."Barrioresidencia"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Barrioresidencia"::text))
        END AS s_fnt_prs_rsd_brr_nme,
        CASE
            WHEN upper(btrim(data_2020."Dirección"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Dirección"::text))
        END AS s_fnt_prs_rsd_adr,
        CASE
            WHEN upper(btrim(data_2020."Viaje_fuera"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Viaje_fuera"::text))
        END AS s_fnt_prs_trv,
    data_2020.ult_fecha_viaje AS d_fnt_prs_trv_dte,
    data_2020."Lugarviaje"::text AS s_fnt_prs_trv_ste,
    split_part(
        CASE
            WHEN data_2020.presion_art::text = ''::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '-'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '.'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '0'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '1'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'Nn'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'No aplica'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'No se valora'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'Sn'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text ~~* '%-%'::text THEN replace(data_2020.presion_art::text, '-'::text, '/'::text)::character varying
            WHEN data_2020.presion_art::text ~~* '%%%'::text THEN replace(data_2020.presion_art::text, '%'::text, '/'::text)::character varying
            WHEN data_2020.presion_art::text ~~* 'Q%'::text THEN replace(data_2020.presion_art::text, 'Q'::text, '-'::text)::character varying
            ELSE data_2020.presion_art
        END::text, '/'::text, 1) AS r_fnt_sgn_prs_stl,
    split_part(
        CASE
            WHEN data_2020.presion_art::text = ''::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '-'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '.'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '0'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = '1'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'Nn'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'No aplica'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'No se valora'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text = 'Sn'::text THEN NULL::character varying
            WHEN data_2020.presion_art::text ~~* '%-%'::text THEN replace(data_2020.presion_art::text, '-'::text, '/'::text)::character varying
            WHEN data_2020.presion_art::text ~~* '%%%'::text THEN replace(data_2020.presion_art::text, '%'::text, '/'::text)::character varying
            WHEN data_2020.presion_art::text ~~* 'Q%'::text THEN replace(data_2020.presion_art::text, 'Q'::text, '-'::text)::character varying
            ELSE data_2020.presion_art
        END::text, '/'::text, 2) AS r_fnt_sgn_prs_dst,
    data_2020."Frec_card"::numeric AS r_fnt_sgn_frc_crd,
    data_2020."Frec_resp"::numeric AS r_fnt_sgn_frc_rsp,
        CASE
            WHEN data_2020."Sat_O2"::text = ''::text THEN NULL::numeric
            ELSE round(data_2020."Sat_O2"::numeric, 2)
        END AS r_fnt_sgn_str_oxg,
        CASE
            WHEN data_2020."Temp"::text = '#NULL!'::text THEN NULL::numeric
            WHEN data_2020."Temp"::text = ''::text THEN NULL::numeric
            WHEN data_2020."Temp"::text = ' '::text THEN NULL::numeric
            ELSE round(data_2020."Temp"::numeric, 2)
        END AS r_fnt_sgn_tpr,
    data_2020.discapacidad::text AS s_fnt_prs_qst_dsc,
    data_2020."Hatenidocontactoconuncasoc"::text AS s_fnt_prs_qst_cse,
    data_2020."DG_inicial"::text AS s_fnt_prs_qst_dgn,
    data_2020."Lugar_proB_infecc"::text AS s_fnt_prs_qst_ifc,
        CASE
            WHEN data_2020."Sintomatoloía"::text = ''::text THEN NULL::text
            ELSE upper(data_2020."Sintomatoloía"::text)
        END AS s_fnt_prs_qst_snt,
        CASE
            WHEN
            CASE
                WHEN split_part(data_2020."Feca_inic_síntomas"::text, '/'::text, 2) = ''::text THEN NULL::text
                ELSE split_part(data_2020."Feca_inic_síntomas"::text, '/'::text, 2)
            END::smallint > 12 THEN to_date(data_2020."Feca_inic_síntomas"::text, 'MM/dd/yyyy'::text)
            WHEN
            CASE
                WHEN split_part(data_2020."Feca_inic_síntomas"::text, '/'::text, 2) = ''::text THEN NULL::text
                ELSE split_part(data_2020."Feca_inic_síntomas"::text, '/'::text, 2)
            END::smallint IS NULL THEN NULL::date
            ELSE to_date(data_2020."Feca_inic_síntomas"::text, 'dd/MM/yyyy'::text)
        END AS d_fnt_prs_qst_dte_snt,
    CASE WHEN data_2020."Fiebre"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Fiebre"::text)) END AS s_fnt_prs_snt_fbr,
    CASE WHEN data_2020."Perdida_gusto_olfato"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Perdida_gusto_olfato"::text)) END AS s_fnt_prs_snt_gst_olf,
    CASE WHEN data_2020."Tos"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Tos"::text)) END AS s_fnt_prs_snt_tos,
    CASE WHEN data_2020."Disnea"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Disnea"::text)) END AS s_fnt_prs_snt_dsn,
    CASE WHEN data_2020."Dolorenlagarganta"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Dolorenlagarganta"::text)) END AS s_fnt_prs_snt_dlr_grg,
    CASE WHEN data_2020."Náuseaovómito"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Náuseaovómito"::text)) END AS s_fnt_prs_snt_dlr_nse_vmt,
    CASE WHEN data_2020."Diarrea"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Diarrea"::text)) END AS s_fnt_prs_snt_drr,
    CASE WHEN data_2020."Escalofrios"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Escalofrios"::text)) END AS s_fnt_prs_snt_esc,
    CASE WHEN data_2020."Confusiónodificultadparaesta"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Confusiónodificultadparaesta"::text)) END AS s_fnt_prs_snt_cnf,
    CASE WHEN data_2020."Doloropresiónpersistenteene"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Doloropresiónpersistenteene"::text)) END AS s_fnt_prs_snt_dlr,
    CASE WHEN data_2020."Cianosis"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Cianosis"::TEXT)) END AS s_fnt_prs_snt_cns,
    CASE WHEN data_2020."Comorbilidad"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Comorbilidad"::text)) END AS s_fnt_prs_qst_cmb,
    CASE WHEN data_2020."Enfermedadescardiovascularesa"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadescardiovascularesa"::text)) END AS s_fnt_prs_cmb_enf_crd_vsc,
    CASE WHEN data_2020."Diabetes"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Diabetes"::text)) END AS s_fnt_prs_cmb_dbt,
    CASE WHEN data_2020."Hipertensión"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Hipertensión"::text)) END AS s_fnt_prs_cmb_hpr,
    CASE WHEN data_2020."Obesidadsevera"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Obesidadsevera"::text)) END AS s_fnt_prs_cmb_obs_svr,
    CASE WHEN data_2020."Enfermedadesrenalesinsuficien"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadesrenalesinsuficien"::text)) END AS s_fnt_prs_cmb_enf_rnl_isf,
    CASE WHEN data_2020."Enfermedadeshepáticasinsufici"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadeshepáticasinsufici"::text)) END AS s_fnt_prs_cmb_enf_hpt_isf,
    CASE WHEN data_2020."Enfermedadespulmonaresasma"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadespulmonaresasma"::text)) END AS s_fnt_prs_cmb_enf_plm_asm,
    CASE WHEN data_2020."Unidadnotifica"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Unidadnotifica"::text)) END AS s_fnt_unt_ntf,
    CASE WHEN data_2020."Embarazada"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Embarazada"::TEXT)) END AS s_fnt_prs_emb,
    CASE WHEN data_2020."Semanasgestación"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Semanasgestación"::TEXT)) END AS s_fnt_prs_emb_nmb,
    CASE WHEN data_2020."Laboratorio"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Laboratorio"::TEXT)) END AS s_fnt_lbr_nme,
    CASE WHEN data_2020."Tipomuestra"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Tipomuestra"::TEXT)) END AS s_fnt_smp_tpe,
    CASE WHEN data_2020."Fechatoma"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Fechatoma"::TEXT)) END AS d_fnt_smp_dte_tke,
    CASE WHEN data_2020."Parámetro"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Parámetro"::TEXT)) END AS s_fnt_smp_prm,
    CASE WHEN data_2020."Resultado"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Resultado"::TEXT)) END AS s_fnt_smp_rsl,
    CASE WHEN data_2020."Correo"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Correo"::TEXT)) END AS s_fnt_prs_eml,
    CASE WHEN data_2020."Hanotadounestadodetristeza"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Hanotadounestadodetristeza"::TEXT)) END AS s_fnt_prs_enc_01,
    CASE WHEN data_2020."Enlasúltimassemanassehase"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlasúltimassemanassehase"::TEXT)) END AS s_fnt_prs_enc_02,
    CASE WHEN data_2020."Enlasúltimassemanashaprese"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlasúltimassemanashaprese"::TEXT)) END AS s_fnt_prs_enc_03,
    CASE WHEN data_2020."Enlasúltimassemanasustedy"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlasúltimassemanasustedy"::TEXT)) END AS s_fnt_prs_enc_04,
    CASE WHEN data_2020."Hanotadounaumentoenelcons"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Hanotadounaumentoenelcons"::TEXT)) END AS s_fnt_prs_enc_05,
    CASE WHEN data_2020."Enlosúltimos4meseshapensa"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlosúltimos4meseshapensa"::TEXT)) END AS s_fnt_prs_enc_06,
    CASE WHEN data_2020."Tienesuficientesingresoseconó"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Tienesuficientesingresoseconó"::TEXT))END AS s_fnt_prs_enc_07,
    CASE WHEN data_2020."Requiere_aislamiento"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Requiere_aislamiento"::TEXT)) END AS s_fnt_prs_asl,
    CASE WHEN data_2020."Resp_llenado"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Resp_llenado"::TEXT)) END AS s_fnt_prs_rsp_lnd,
    CASE WHEN data_2020."Detalle"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Detalle"::TEXT)) END AS s_fnt_prs_dtl
   FROM dta_uio.data_2020
  WHERE data_2020.fecha_atencion IS NOT NULL
  ORDER BY ("right"(dta_uio.smn_epd(date_part('year'::text, data_2020.fecha_atencion::date)::numeric, date_part('month'::text, data_2020.fecha_atencion::date)::numeric, date_part('day'::text, data_2020.fecha_atencion::date)::numeric)::text, 2)::smallint), (data_2020.fecha_atencion::date), (
        CASE
            WHEN data_2020."Brigada_Num"::text = ''::text THEN NULL::character varying
            WHEN data_2020."Brigada_Num"::text = ' '::text THEN NULL::character varying
            ELSE data_2020."Brigada_Num"
        END::text);
--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date --> 2021-10-20
-- Comment --> Vista depurada de los datos 2020
--*******************************************************************************************************************************************--
-- READ: Consultar datos obtenidos de la dinardap y comparar con la tabla de cedulas validadas como OK, agrupando para quitar duplicados 
DROP VIEW dta_uio.data_2020_gnr;
CREATE OR REPLACE VIEW dta_uio.data_2020_gnr AS 
WITH tmp01 AS (
SELECT
  i_prs_id AS i_dnr_prs_id,
  d_prs_rgs_dte AS d_dnr_prs_rgs_dte,
  s_prs_rgs_tme AS s_dnr_prs_rgs_tme,
  s_prs_idn AS s_dnr_prs_idn,
  s_prs_nme AS s_dnr_prs_nme,
  to_date(s_prs_dte_brt, 'dd/MM/yyyy') AS d_dnr_prs_dte_brt,
  to_date((CASE WHEN s_prs_dte_dfn = '' THEN NULL ELSE s_prs_dte_dfn END),'dd/MM/yyyy') AS d_dnr_prs_dte_dfn,
  s_prs_stt AS s_dnr_prs_stt,
  s_prs_cyg AS s_dnr_prs_cyg,
  s_prs_prf AS s_dnr_prs_prf,
  split_part(s_prs_adr, '/',1) AS s_dnr_prs_prv_nme,
  split_part(s_prs_adr, '/',2) AS s_dnr_prs_cnt_nme,
  split_part(s_prs_adr, '/',3) AS s_dnr_prs_prq_nme
FROM dta_tbl_prs_dnr prs_dnr ORDER BY 1)
SELECT
  date_part('year', prs.d_fnt_uio_dte_att)::SMALLINT AS i_fnt_yr,
  prs.i_fnt_epi_wk,
  prs.d_fnt_uio_dte_att AS d_fnt_prs_dte_att,
  prs.s_fnt_brg_att_grp,
  prs.s_fnt_brg_att_grp_sub,
  prs.s_fnt_prq_att,
  prs.s_fnt_brg_nmb,
  prs.s_fnt_prs_idn,
  tmp01.s_dnr_prs_idn,
  prs.s_fnt_prs_nme,
  tmp01.s_dnr_prs_nme,
  prs.s_fnt_prs_sex,
  prs.s_fnt_prs_nth,
  prs.s_fnt_prs_eth,
  prs.s_fnt_prs_ins,
  prs.s_fnt_prs_ocp,
  tmp01.s_dnr_prs_prf,
  prs.d_fnt_prs_dte_brt::TEXT AS s_fnt_prs_dte_brt,
  tmp01.d_dnr_prs_dte_brt,  
  prs.i_fnt_prs_dte_brt_yr::TEXT AS s_fnt_prs_dte_brt_yr,
  date_part('year', age(prs.d_fnt_uio_dte_att , prs.d_fnt_prs_dte_brt))::SMALLINT AS i_fnt_prs_brt_yr,
  date_part('month', age(prs.d_fnt_uio_dte_att, prs.d_fnt_prs_dte_brt))::SMALLINT AS i_fnt_prs_brt_mth,
  date_part('day', age(prs.d_fnt_uio_dte_att, prs.d_fnt_prs_dte_brt))::SMALLINT AS i_fnt_prs_brt_day,
  prs.s_fnt_prs_age_grp,
  dta_uio.age_grp(prs.d_fnt_uio_dte_att, prs.d_fnt_prs_dte_brt) AS s_fnt_prs_age_grp_clc,
  date_part('year', age(prs.d_fnt_uio_dte_att, tmp01.d_dnr_prs_dte_brt))::SMALLINT AS i_dnr_prs_brt_yr,
  date_part('month', age(prs.d_fnt_uio_dte_att, tmp01.d_dnr_prs_dte_brt))::SMALLINT AS i_dnr_prs_brt_mth,
  date_part('day', age(prs.d_fnt_uio_dte_att, tmp01.d_dnr_prs_dte_brt))::SMALLINT AS i_dnr_prs_brt_day,
  dta_uio.age_grp(prs.d_fnt_uio_dte_att, tmp01.d_dnr_prs_dte_brt) AS s_dnr_prs_age_grp_clc,
  tmp01.d_dnr_prs_dte_dfn,
  tmp01.s_dnr_prs_stt,
  tmp01.s_dnr_prs_cyg,
  prs.s_fnt_prs_rsd_prv_nme,
  prs.s_fnt_prs_rsd_prq_nme,
  prs.s_fnt_prs_rsd_brr_nme,
  prs.s_fnt_prs_rsd_adr,
  tmp01.s_dnr_prs_prv_nme,
  tmp01.s_dnr_prs_cnt_nme,
  tmp01.s_dnr_prs_prq_nme,
  dta_uio.sif_sql(prs.s_fnt_prs_rsd_prv_nme ISNULL, tmp01.s_dnr_prs_prv_nme,  prs.s_fnt_prs_rsd_prv_nme) AS s_gnr_prs_rsd_prv_nme,
  dta_uio.sif_sql(prs.s_fnt_prs_rsd_prq_nme ISNULL, tmp01.s_dnr_prs_prq_nme,  prs.s_fnt_prs_rsd_prq_nme) AS s_gnr_prs_rsd_prq_nme,
  prs.s_fnt_prs_trv,
  prs.d_fnt_prs_trv_dte::TEXT AS s_fnt_prs_trv_dte,
  prs.s_fnt_prs_trv_ste,
  prs.r_fnt_sgn_prs_stl::text AS s_fnt_sgn_prs_stl,
  prs.r_fnt_sgn_prs_dst::text AS s_fnt_sgn_prs_dst,
  prs.r_fnt_sgn_frc_crd::smallint AS i_fnt_sgn_frc_crd,
  prs.r_fnt_sgn_frc_rsp::smallint AS i_fnt_sgn_frc_rsp,
  prs.r_fnt_sgn_str_oxg::smallint AS i_fnt_sgn_str_oxg,
  prs.r_fnt_sgn_tpr::NUMERIC AS r_fnt_sgn_tpr,
  prs.s_fnt_prs_qst_dsc,
  prs.s_fnt_prs_qst_cse,
  prs.s_fnt_prs_qst_snt,
  prs.s_fnt_prs_qst_dgn,
  prs.s_fnt_prs_qst_ifc,
  prs.s_fnt_prs_snt_fbr,
  prs.s_fnt_prs_snt_gst_olf,
  prs.s_fnt_prs_snt_tos,
    prs.s_fnt_prs_snt_dsn,
    prs.s_fnt_prs_snt_dlr_grg,
    prs.s_fnt_prs_snt_dlr_nse_vmt,
    prs.s_fnt_prs_snt_drr,
    prs.s_fnt_prs_snt_esc,
    prs.s_fnt_prs_snt_cnf,
    prs.s_fnt_prs_snt_dlr,
    prs.s_fnt_prs_snt_cns,
    prs.s_fnt_prs_qst_cmb,
    prs.s_fnt_prs_cmb_enf_crd_vsc,
    prs.s_fnt_prs_cmb_dbt,
    prs.s_fnt_prs_cmb_hpr,
    prs.s_fnt_prs_cmb_obs_svr,
    prs.s_fnt_prs_cmb_enf_rnl_isf,
    prs.s_fnt_prs_cmb_enf_hpt_isf,
    prs.s_fnt_prs_cmb_enf_plm_asm,
    prs.s_fnt_unt_ntf,
    prs.s_fnt_prs_emb,
    prs.s_fnt_prs_emb_nmb,
    prs.s_fnt_lbr_nme,
    prs.s_fnt_smp_tpe,
    prs.d_fnt_smp_dte_tke::text AS s_fnt_smp_dte_tke,
    prs.s_fnt_smp_prm,
    btrim(CASE WHEN prs.s_fnt_smp_rsl = '' THEN NULL ELSE prs.s_fnt_smp_rsl END) AS s_fnt_smp_rsl,
    NULL AS s_fnt_smp_igm,
    NULL AS s_fnt_smp_igg,
    prs.s_fnt_prs_eml,
    prs.s_fnt_prs_enc_01,
    prs.s_fnt_prs_enc_02,
    prs.s_fnt_prs_enc_03,
    prs.s_fnt_prs_enc_04,
    prs.s_fnt_prs_enc_05,
    prs.s_fnt_prs_enc_06,
    prs.s_fnt_prs_enc_07,
    prs.s_fnt_prs_asl,
    prs.s_fnt_prs_rsp_lnd,
    prs.s_fnt_prs_dtl,
    Count(*)::SMALLINT AS i_ttl_dpl
FROM dta_uio.data_2020_fnt prs
FULL JOIN tmp01 ON tmp01.s_dnr_prs_idn = prs.s_fnt_prs_idn
GROUP BY 
  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
  21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
  41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
  61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
  81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,prs.s_fnt_smp_rsl
 ORDER BY 1,2,prs.s_fnt_smp_rsl DESC;

--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date --> 2021-10-21
-- Comment --> Consultas que ayuden a la presentacion
--*******************************************************************************************************************************************--
---> READ: Consulta que me permite ver la temporalidad de la data en 2020
SELECT date_part('year',d_fnt_prs_dte_att) AS i_yr, 
       min(d_fnt_prs_dte_att) AS d_prs_dte_min_att, 
       max(d_fnt_prs_dte_att) AS d_prs_dte_max_att 
FROM dta_uio.data_2020_gnr GROUP BY 1 HAVING min(d_fnt_prs_dte_att) NOTNULL;
---> READ: Consulta que me permite ver el resumen de datos obtenidos de la data 2020
SELECT 
2020::SMALLINT AS i_yr, -- Anio
(SELECT count(*) FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL) AS i_ttl_ptt, -- Total pacientes (registros) 
(SELECT count(*) FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL) - (SELECT count(*) FROM dta_uio.data_2020_gnr) AS i_ttl_ptt_dpl, -- Total pacientes (registros) duplicados
(SELECT count(*) FROM dta_uio.data_2020_gnr) AS i_ttl_ptt_dpl_no, -- Total pacientes (registros), no duplicados, registros para trabajar 
(SELECT Count(*) FROM dta_tbl_prs) AS i_ttl_ptt_idn_vld, -- Total pacientes (registros) validados con algoritmo para validar cedula ecuatoriana
(SELECT count(*) FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL) - (SELECT Count(*) FROM dta_tbl_prs) AS i_ttl_ptt_idn_oth, -- Total pacientes (registros) otras identificaciones
(SELECT Count(*) FROM dta_tbl_prs_dnr) AS i_ttl_ptt_idn_dnr_ok, -- Total pacientes (registros), validados con la dinardap (datos correctos, usando la cedula)
(SELECT Count(*) FROM dta_tbl_prs) - (SELECT Count(*) FROM dta_tbl_prs_dnr)  AS i_ttl_ptt_idn_dnr_error, -- Total pacientes (registros), no se encontraron en dinardap 
(SELECT count(*) FROM dta_uio.data_2020 WHERE fecha_atencion NOTNULL) - (SELECT Count(*) FROM dta_tbl_prs) + (SELECT Count(*) FROM dta_tbl_prs) - (SELECT Count(*) FROM dta_tbl_prs_dnr) AS i_ttl_ptt_idn_vrf, -- Total pacientes (registros), para verificar
(SELECT count(*) FROM dta_uio.data_2020_gnr WHERE s_dnr_prs_idn ISNULL) AS i_ttl_ptt_vrf -- Total pacientes (registros), pacientes que no tienen registro en dinardap (no se validaron), pueden estar duplicados;
(SELECT s_dnr_prs_idn, count(*) FROM dta_uio.data_2020_gnr WHERE s_dnr_prs_idn ISNULL GROUP BY 1);




