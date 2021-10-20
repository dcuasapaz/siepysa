-- 1. Cambio de esquema de la tabla
ALTER TABLE public.data_20210627 SET SCHEMA dta_uio;
-- 2. Verificacion de numero de registros 
SELECT * FROM dta_uio.data_20210627;
-- 3. Cambio de esquema de la tabla
ALTER TABLE public.data_20211008 SET SCHEMA dta_uio;
-- 4. Verificacion de numero de registros 
SELECT * FROM dta_uio.data_20211008 WHERE "fec_Aten" NOTNULL;
-- 5. Unir las dos tablas para depuracion 
CREATE MATERIALIZED VIEW dta_uio.data_2021 AS 
SELECT * FROM dta_uio.data_20210627 WHERE "fec_aten" NOTNULL
UNION 
SELECT * FROM dta_uio.data_20211008 WHERE "fec_Aten" NOTNULL;
-- 6. Vista para consumo DINARDAP, limpieza de datos del campo cedula
SELECT * FROM dta_uio.data_2021;
DROP VIEW dta_uio.data_2021_id;
CREATE OR REPLACE VIEW data_2021_id AS
SELECT 
  "ID1" AS i_prs_idn,
  CASE 
      WHEN fec_aten ilike '%/%' THEN to_date(fec_aten, 'dd/MM/yyyy')
      WHEN LEFT(fec_aten,3) ilike '%-%' THEN to_date(fec_aten, 'dd-MM-yyyy')
  ELSE 
      to_date(fec_aten, 'yyyy-MM-dd')
  END AS  d_prs_dte_att,
  fec_aten AS s_prs_dte_att,
  CASE WHEN upper(trim(BOTH FROM "ID")) = '#REF!' THEN NULL
  ELSE
  upper(trim(BOTH FROM "ID"))
  END s_prs_idn, 
  length(upper(trim(BOTH FROM "ID"))) AS i_prs_idn_lng 
FROM dta_uio.data_2021 ORDER BY 1 ASC ; 

SELECT s_prs_idn, count(*) FROM dta_uio.data_2021_id GROUP BY 1 ORDER  BY 1 DESC ;
---> Verificar las fechas depuradas 
SELECT d_prs_dte_att, count(*) FROM dta_uio.data_2021_id GROUP BY 1 ORDER BY 1;
DROP TABLE dta_uio.dta_tbl_prs_idn_2021;
DROP TABLE dta_uio.dta_tbl_prs_idn_2021_10;
DROP TABLE dta_uio.dta_tbl_prs_idn_2021_09;
DROP TABLE dta_uio.dta_tbl_prs_idn_2021_all;

---> CREATE: Tabla para almacenar las identificaciones validas
CREATE TABLE dta_uio.dta_tbl_prs_idn_2021(i_prs_id serial PRIMARY KEY,s_prs_idn TEXT);
---> CREATE: Identificaciones incorrectas con size = 10
CREATE TABLE dta_uio.dta_tbl_prs_idn_2021_10(i_prs_id serial PRIMARY KEY,i_prs_idn integer, s_prs_idn TEXT,d_prs_dte_att TEXT);
---> CREATE: Identificaciones incorrectas con size = 09
CREATE TABLE dta_uio.dta_tbl_prs_idn_2021_09(i_prs_id serial PRIMARY KEY,i_prs_idn integer, s_prs_idn TEXT,d_prs_dte_att TEXT);
---> CREATE: Identificaciones incorrectas extranjeras, erroneas, etc.
CREATE TABLE dta_uio.dta_tbl_prs_idn_2021_all(i_prs_id serial PRIMARY KEY,i_prs_idn integer, s_prs_idn TEXT,d_prs_dte_att TEXT);
--> CREATE: Crear la tabla dentro de la base de datos para 2021
CREATE TABLE dta_tbl_prs_dnr_2021(
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

SELECT * FROM dta_tbl_prs_dnr_2021 ORDER BY 1 DESC ;
-- Mover al esquema dta_uio.
SELECT * FROM dta_uio.dta_tbl_prs_idn_2021 where s_prs_idn = '1713808069';


