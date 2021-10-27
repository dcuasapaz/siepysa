--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date --> 2021-10-22
-- Comment --> Consultas que ayuden a la presentacion 
--*******************************************************************************************************************************************--

---> CREATE: Vista que une las dos vistas de 2020 y 2021
DROP VIEW dta_uio.data_gnr;
CREATE OR REPLACE VIEW dta_uio.data_gnr AS 
SELECT * FROM dta_uio.data_2020_gnr
UNION
SELECT * FROM dta_uio.data_2021_gnr
ORDER BY 1,2,3;

---> READ: Consultas generales para revisar los datos unidos
SELECT * FROM dta_uio.data_2020_gnr;
---> READ: Registros que se repitan mas de una ves en 2020
SELECT * FROM dta_uio.data_gnr WHERE i_ttl_dpl > 1 AND i_fnt_yr = 2020;


---> READ: Retorna las atenciones, pacientes sin resultados
SELECT * FROM dta_uio.data_gnr dg WHERE s_dnr_prs_idn ISNULL;
---> READ: Registros por verificar
SELECT s_dnr_prs_idn, Count(*) FROM dta_uio.data_gnr WHERE s_dnr_prs_idn ISNULL GROUP BY 1;

SELECT Count(*) FROM dta_uio.data_gnr WHERE s_fnt_smp_rsl ISNULL;
---> READ: Todas las atenciones por unidad y anio
SELECT i_fnt_yr, i_fnt_epi_wk, s_fnt_unt_ntf, Count(*) FROM dta_uio.data_gnr WHERE s_fnt_smp_rsl ISNULL GROUP BY 1,2,3 ORDER BY 1,2;
---> READ: Revision de resultados
SELECT s_fnt_smp_rsl, Count(*) FROM dta_uio.data_gnr GROUP BY 1;
SELECT "Res", Count(*) FROM dta_uio.data_2021 GROUP BY 1;


---> READ: Verificar los atributos y su tipo de tabla o vista
SELECT
    t1.COLUMN_NAME AS s_tbl_atr,
    t1.COLUMN_DEFAULT AS s_tbl_dlf,
    t1.IS_NULLABLE AS s_tbl_nll,
    t1.DATA_TYPE AS s_tbl_tpe,
    COALESCE(t1.NUMERIC_PRECISION,
    t1.CHARACTER_MAXIMUM_LENGTH) AS i_tbl_lgt,
    PG_CATALOG.COL_DESCRIPTION(t2.OID,
    t1.DTD_IDENTIFIER::int) AS i_tbl_dsc
FROM 
    INFORMATION_SCHEMA.COLUMNS t1
    INNER JOIN PG_CLASS t2 ON (t2.RELNAME = t1.TABLE_NAME)
WHERE 
    t1.TABLE_SCHEMA = 'dta_uio' AND
    t1.TABLE_NAME = 'data_2020_gnr'
ORDER BY
t1.ORDINAL_POSITION;

---> CREATE: Extension de PostGIS para datos vectoriales
CREATE EXTENSION postgis;
DROP MATERIALIZED VIEW dta_uio.dpa_qry_prq_uio;
CREATE MATERIALIZED VIEW dta_uio.dpa_qry_prq_uio AS 
SELECT 
  gid,
  upper(btrim(clave_parr::TEXT)) AS s_prq_cde,
  upper(btrim(nombre_par::TEXT)) AS s_prq_nme,
  upper(btrim(zonadminis::TEXT)) AS s_prq_zne_adm,
  upper(btrim(delegacion::TEXT)) AS s_prq_dlg,
  geom
FROM dta_uio.dpa_tbl_prq_uio dtpu;

DROP MATERIALIZED VIEW dta_uio.uio_qry_prq_pst_2021;
CREATE MATERIALIZED VIEW dta_uio.uio_qry_prq_pst_2021 AS
WITH tmp01 AS (
SELECT s_fnt_prq_att, count(*) AS i_ttl_pos FROM dta_uio.data_gnr WHERE s_fnt_smp_rsl = 'POSITIVO' AND i_fnt_yr = 2021 GROUP BY 1 ORDER BY 1)
SELECT 
  uio.gid,
  uio.s_prq_cde,
  uio.s_prq_nme,
  uio.s_prq_zne_adm,
  uio.s_prq_dlg,
  dta_uio.iif_sql(tmp01.i_ttl_pos ISNULL, 0, tmp01.i_ttl_pos::integer) AS i_ttl_pos,
  uio.geom
FROM dta_uio.dpa_qry_prq_uio uio
LEFT JOIN tmp01 ON tmp01.s_fnt_prq_att = uio.s_prq_nme
ORDER BY 1,2,3;

SELECT * FROM dta_uio.data_gnr ORDER BY 1 DESC;



--> READ: Reunion 2021-10-25 
SELECT i_fnt_yr, s_fnt_smp_rsl, Count(*) FROM dta_uio.data_gnr GROUP BY 1, 2 ORDER BY 1;

SELECT i_fnt_yr, LEFT(d_fnt_prs_dte_att::TEXT,7), s_fnt_lbr_nme, s_fnt_smp_rsl, Count(*) FROM dta_uio.data_gnr GROUP BY 1, 2, 3, d_fnt_prs_dte_att, s_fnt_smp_rsl ORDER BY 1;

SELECT s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, s_fnt_prs_dte_brt_yr, Count(*) FROM dta_uio.data_gnr WHERE s_fnt_prs_dte_brt_yr ISNULL GROUP BY 1, 2, 3 ORDER BY 1;
--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date --> 2021-10-26
-- Comment --> Consultas para revision campo por campo de la DATA obtenida 
--*******************************************************************************************************************************************--
---> CREATE: Vista que une las dos vistas de 2020 y 2021
DROP VIEW dta_uio.data_gnr;
CREATE MATERIALIZED VIEW dta_uio.data_gnr AS 
SELECT * FROM dta_uio.data_2020_gnr
UNION
SELECT * FROM dta_uio.data_2021_gnr
ORDER BY 1,2,3;
---> READ: Grupos de atencion 
SELECT * FROM dta_uio.data_2021 WHERE "RED_GRUP" = 'TRIAJE UEM SUCRE';

UPDATE dta_uio.data_20210627 SET "RED_GRUP" = 'TRIAJE UEM SUCRE' WHERE "RED_GRUP" = 'TRIAJE TRIAJE UEM SUCRE';
UPDATE dta_uio.data_20211008 SET "RED_GRUP" = 'TRIAJE UEM SUCRE' WHERE "RED_GRUP" = 'TRIAJE TRIAJE UEM SUCRE';

REFRESH MATERIALIZED VIEW dta_uio.data_2021;
REFRESH MATERIALIZED VIEW dta_uio.data_2021_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_gnr;
SELECT i_fnt_yr, s_fnt_brg_att_grp, count (*) FROM dta_uio.data_gnr GROUP BY 1,2  ORDER BY 1,2;

---> READ: Sub-Grupos de atencion
SELECT * FROM dta_uio.data_2021 WHERE "Grup_aten" = 'BRIGADA EÑ TRANSITO';
UPDATE dta_uio.data_20210627 SET "Grup_aten" = 'BRIGADA EL TRANSITO' WHERE "Grup_aten" = 'BRIGADA EÑ TRANSITO';
UPDATE dta_uio.data_20211008 SET "Grup_Aten" = 'BRIGADA EL TRANSITO' WHERE "Grup_Aten" = 'BRIGADA EÑ TRANSITO';
REFRESH MATERIALIZED VIEW dta_uio.data_2021;
REFRESH MATERIALIZED VIEW dta_uio.data_2021_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_gnr;
SELECT i_fnt_yr, s_fnt_brg_att_grp_sub, count (*) FROM dta_uio.data_gnr GROUP BY 1,2  ORDER BY 1,2;
 
---> READ: Brigadas
SELECT * FROM dta_uio.data_gnr;
SELECT i_fnt_yr, s_fnt_brg_nmb, count (*) FROM dta_uio.data_gnr GROUP BY 1,2  ORDER BY 1,2;

---> READ: Parroquias
SELECT * FROM dta_uio.data_gnr;
SELECT i_fnt_yr, s_fnt_prq_att, count (*) FROM dta_uio.data_gnr GROUP BY 1,2  ORDER BY 1,2;

---> READ: Identificaciones fuente
SELECT * FROM dta_uio.data_gnr;
SELECT 
  s_fnt_prs_idn, 
  s_dnr_prs_idn,  
  CASE WHEN s_fnt_prs_idn = '' THEN 'SE DESCONOCE' 
       WHEN s_fnt_prs_idn = '0' THEN 'SE DESCONOCE' 
       WHEN s_fnt_prs_idn = 'Y' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '000000000' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '0000000000' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '99999999999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '99999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '9999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '99999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '9999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'LUIS AUGUSTO PAVON ROJAS' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'N/A' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NNNN' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO RECUERDA' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO REFIERE' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO SABE' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO TIENE' THEN 'SE DESCONOCE'     
       WHEN s_fnt_prs_idn = 'DESCONOCE' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'G' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn ISNULL AND s_dnr_prs_idn ISNULL THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn ISNULL AND s_dnr_prs_idn NOTNULL THEN s_dnr_prs_idn
  ELSE 
      s_fnt_prs_idn
  END AS s_gnr_prs_idn,
  count (*) 
FROM dta_uio.data_gnr GROUP BY 1,2,s_dnr_prs_nme  ORDER BY 1 DESC;

---> READ: Apellidos nombres
SELECT * FROM dta_uio.data_gnr;
SELECT * FROM dta_uio.data_2020 WHERE nombre = '2100266747';
SELECT * FROM dta_uio.data_20210627 WHERE nom = '2100266747';
SELECT * FROM dta_uio.data_20211008 WHERE nom = '2100266747';
UPDATE dta_uio.data_20210627 SET nom = 'BENAVIDES SACA BERTHA MARINA' WHERE nom = '2100266747';
UPDATE dta_uio.data_20211008 SET nom = 'POZO CAICEDO PIEDAD MERCEDES' WHERE nom = '2100266747';
REFRESH MATERIALIZED VIEW dta_uio.data_2021;
REFRESH MATERIALIZED VIEW dta_uio.data_2021_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_gnr;
SELECT 
  s_fnt_prs_idn,
  s_dnr_prs_idn,
  s_fnt_prs_nme, 
  s_dnr_prs_nme, 
  CASE WHEN s_fnt_prs_nme = '#NULL!' AND s_dnr_prs_idn ISNULL THEN 'SE DESCONOCE'
  	   WHEN s_dnr_prs_idn NOTNULL THEN  s_dnr_prs_nme
  	   WHEN s_fnt_prs_nme = '7434053' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '6875977' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '175901093' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '089714782' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '19972476' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '1755916649' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '1707667502' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme ISNULL AND s_dnr_prs_idn ISNULL AND s_dnr_prs_nme ISNULL AND s_fnt_prs_idn NOTNULL THEN 'SE DESCONOCE'
  ELSE 
          s_fnt_prs_nme
  END AS s_gnr_prs_nme,
  count (*) 
FROM dta_uio.data_gnr
GROUP BY 1,2,3,4  ORDER BY 5 DESC;


---> READ: Nacionalidad
SELECT * FROM dta_uio.data_gnr;
SELECT
  s_dnr_prs_idn,
  s_fnt_prs_nth,
  CASE WHEN s_fnt_prs_nth = 'VENEZOLANO' THEN 'VENEZUELA'
       WHEN s_fnt_prs_nth = 'VENEZOLANA' THEN 'VENEZUELA'
       WHEN s_fnt_prs_nth = 'COLOMBIANA' THEN 'COLOMBIA'
       WHEN s_fnt_prs_nth = 'COLOMBIANO' THEN 'COLOMBIA'
       WHEN s_fnt_prs_nth = 'ECUARORIANA' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ECUATORIANA' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ECUATORIANA NO DISPONE' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ECUATORIANO' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ESPAÑOLA' THEN 'ESPAÑA'
       WHEN s_fnt_prs_nth = 'ESTADOUNIDENSE' THEN 'ESTADOS UNIDOS'
       WHEN s_fnt_prs_nth = 'DOMÍNICA' THEN 'DOMINICA'
       WHEN s_fnt_prs_nth = 'CAMERÚN' THEN 'CAMERUN'
       WHEN s_fnt_prs_nth = 'CANADÁ' THEN 'CANADA'
       WHEN s_fnt_prs_nth = 'HAITÍ' THEN 'HAITI'
       WHEN s_fnt_prs_nth = 'IRÁN' THEN 'IRAN'
       WHEN s_fnt_prs_nth = 'PAKISTÁN' THEN 'PAKISTAN'
       WHEN s_fnt_prs_nth = 'PERÚ' THEN 'PERU'
       WHEN s_fnt_prs_nth = 'PERUANA' THEN 'PERU'
       WHEN s_fnt_prs_nth = 'REPÚBLICA DOMINICANA' THEN 'REPUBLICA DOMINICANA'
       WHEN s_dnr_prs_idn NOTNULL THEN 'ECUADOR'
       WHEN s_dnr_prs_idn ISNULL AND s_fnt_prs_nth ISNULL THEN 'SE DESCONOCE' 
  ELSE
           s_fnt_prs_nth
  END AS s_gnr_prs_nth,
  count(*) 
FROM dta_uio.data_gnr
GROUP BY 1,2
ORDER BY 3 DESC ;
---> READ: Ethnia
SELECT * FROM dta_uio.data_gnr;
SELECT 
  s_fnt_prs_eth,
  CASE WHEN s_fnt_prs_eth = '' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_eth = 'AFROAMERICANA' THEN 'AFROAMERICANO'
       WHEN s_fnt_prs_eth = 'AFROFESENDIENTE' THEN 'AFRODESCENDIENTE'
       WHEN s_fnt_prs_eth = 'INDÍGENA' THEN 'INDIGENA'
       WHEN s_fnt_prs_eth = 'MESTIZA' THEN 'MESTIZO'
       WHEN s_fnt_prs_eth = 'MONTUBIA' THEN 'MONTUBIO'
       WHEN s_fnt_prs_eth = 'MULATA' THEN 'MULATO'
       WHEN s_fnt_prs_eth = 'NEGRA' THEN 'NEGRO'
       WHEN s_fnt_prs_eth = 'OTROS' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_eth ISNULL THEN 'SE DESCONOCE'
  ELSE 
    s_fnt_prs_eth
  END AS s_gnr_prs_eth,
  Count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

---> READ: Instruccion
SELECT * FROM dta_uio.data_gnr;
SELECT 
  s_fnt_prs_ins,
  CASE WHEN s_fnt_prs_ins = '' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ISNULL THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='BACHILLER' THEN 'BACHILLERATO'
       WHEN s_fnt_prs_ins ='BACHILERATO' THEN 'BACHILLERATO'
       WHEN s_fnt_prs_ins ='ANALFABETA' THEN 'ANALFABETO'
       WHEN s_fnt_prs_ins ='BACHILLERTO' THEN 'BACHILLERATO'
       WHEN s_fnt_prs_ins ='BÁSICA' THEN 'BASICO'
       WHEN s_fnt_prs_ins ='BASICA' THEN 'BASICO'
       WHEN s_fnt_prs_ins ='FEMENINO' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='MASCULINO' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='MDQ' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='NINGUNA' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='SECUANDARIA' THEN 'SECUNDARIA'
       WHEN s_fnt_prs_ins ='BACHILLERATO IMCOMPLETO' THEN 'BACHILLERATO INCOMPLETO'
       WHEN s_fnt_prs_ins ='SUPERIOR INCOMPLETA' THEN 'SUPERIOR INCOMPLETO'
       WHEN s_fnt_prs_ins ='TECNICO' THEN 'TECNOLOGO'
       WHEN s_fnt_prs_ins ='TEGNOLOGA' THEN 'TECNOLOGO'
       WHEN s_fnt_prs_ins ='TECNOLOGICO' THEN 'TECNOLOGO'
       WHEN s_fnt_prs_ins ='UNIVERSITARIA' THEN 'UNIVERSITARIO'
  ELSE
      s_fnt_prs_ins
  END AS s_gnr_prs_ins,
  count(*) 
FROM dta_uio.data_gnr GROUP BY 1 ORDER BY 1 DESC ;

---> READ: Ocupacion
-- Esta variable deben depurar los brigadistas
SELECT * FROM dta_uio.data_gnr;
SELECT 
  s_fnt_prs_ocp,
  CASE WHEN s_fnt_prs_ocp ISNULL THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ocp = 'ZAPATERÍA' THEN 'ZAPATERO'
       WHEN s_fnt_prs_ocp = 'ZAPATERIA' THEN 'ZAPATERO'
       WHEN s_fnt_prs_ocp = 'ZAPATERA' THEN 'ZAPATERO'
       WHEN s_fnt_prs_ocp = 'ABIGADO' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADA' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADO.' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADS' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADA ANALISTA DE PROMOCION DE DERECHOS' THEN 'ABOGADO ANALISTA DE PROMOCION DE DERECHOS'
       WHEN s_fnt_prs_ocp = 'ABOGADA COMERCIANTE' THEN 'ABOGADO COMERCIANTE'
       WHEN s_fnt_prs_ocp = 'ABOGADA DE DESPACHO' THEN 'ABOGADO DE DESPACHO'
       WHEN s_fnt_prs_ocp = 'ABOGADA DIRECTORA DE GESTION' THEN 'ABOGADO DIRECTOR DE GESTION'
       WHEN s_fnt_prs_ocp = 'ABOGADA EMPLEADA PUBLICA' THEN 'ABOGADO EMPLEADO PUBLICO'
       WHEN s_fnt_prs_ocp = 'ABOGADA MÉDICA ANDINA' THEN 'ABOGADO MEDICO ANDINO'
       WHEN s_fnt_prs_ocp = 'ABOGADA, COMERCIANTE' THEN 'ABOGADO COMERCIANTE'
       WHEN s_fnt_prs_ocp = 'ABOGADA. EMPLEADA MUNICIPAL' THEN 'ABOGADO EMPLEADO MUNICIPAL'
       WHEN s_fnt_prs_ocp = 'ABOGADO DEL  ESTADO' THEN 'ABOGADO DEL ESTADO'
       WHEN s_fnt_prs_ocp = 'ABOGADO EN MINISTERIO' THEN 'ABOGADO DEL MINISTERIO'
       WHEN s_fnt_prs_ocp = 'ACABADOS DE CONSTRUCCIÓN' THEN 'ACABADOS DE CONSTRUCCION'
       WHEN s_fnt_prs_ocp = 'ACCCESOR DE VENTAS' THEN 'ASESOR DE VENTAS'
       WHEN s_fnt_prs_ocp = 'ACCESOR COMERCIAL' THEN 'ASESOR COMERCIAL'
       WHEN s_fnt_prs_ocp = 'ACCESOR DE PROYECTOS' THEN 'ASESOR DE PROYECTOS'
       WHEN s_fnt_prs_ocp = 'ACCESOR EN VENTAS' THEN 'ASESOR DE VENTAS'
       WHEN s_fnt_prs_ocp = 'ACCESORIA COMERCIAL' THEN 'ASESOR COMERCIAL'
       WHEN s_fnt_prs_ocp = 'ACCESORIA DE CAMPO' THEN 'ASESOR DE CAMPO'
       WHEN s_fnt_prs_ocp = 'ACCIÓN Y PRODUCCIÓN' THEN 'ACCION Y PRODUCCION'
       WHEN s_fnt_prs_ocp = 'ACESESOR COMERCIAL' THEN 'ASESOR COMERCIAL'
       WHEN s_fnt_prs_ocp = 'ACESOR' THEN 'ASESOR'
       WHEN s_fnt_prs_ocp = '.MILITARR' THEN 'MILITAR'
       WHEN s_fnt_prs_ocp = '3MPKEADO EN FABRICA' THEN 'EMPLEADO DE FABRICA'
       WHEN s_fnt_prs_ocp = '3STUDIANTE' THEN 'ESTUDIANTE'
       WHEN s_fnt_prs_ocp = 'A,MA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AAMA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'ABAOGADO' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL D ETRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL D TRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL DE TRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL DE TRÁNSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL TRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CVIL DE TRÁNSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE DE TRÁNSITO' THEN 'AGENTE DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE DE. SEGURIDAD' THEN 'AGENTE DE SEGURIDAD'
       WHEN s_fnt_prs_ocp = 'AGENTE MEROPOLITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METOPOLITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPILITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPILOTANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPOLITANA' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPOLTANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE TRANSITO' THEN 'AGENTE DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE TRÁNSITO' THEN 'AGENTE DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGOGADA' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'AGRICILTURA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AGRICOLA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AGRÍCOLA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AGRICULTORA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AISTENTE' THEN 'ASISTENTE'
       WHEN s_fnt_prs_ocp = 'AGUA POTABEL' THEN 'AGUA POTABLE'
       WHEN s_fnt_prs_ocp = 'AISTENTE' THEN 'ASISTENTE'
       WHEN s_fnt_prs_ocp = 'AISTENTE DE TALLER' THEN 'ASISTENTE DE TALLER'
       WHEN s_fnt_prs_ocp = 'AISTENTE TECNICO' THEN 'ASISTENTE TECNICO'
       WHEN s_fnt_prs_ocp = 'AJENTE DE VIAJES' THEN 'AGENTE DE VIAJES'
       WHEN s_fnt_prs_ocp = 'AJUBILADO' THEN 'JUBILADO'
       WHEN s_fnt_prs_ocp = 'ALABAÑIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑEL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑIEL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBANIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑILERIA' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑILERÍA' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑILES' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑLIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAOÑIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALMA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'ALVANIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'AM ADE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AM DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA  DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA D CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DDE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE  CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE 6' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE ACASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE C ASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CAA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CADA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CADO' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CAS' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA A' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DÉ CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA.' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA|' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA1' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASAA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASAS' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASQ' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASS' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASSA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CCASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CSA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CSSA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE XASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE. CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DECASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DR CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA E CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA SE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA. DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA.DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMADE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMAN DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMAÑA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMBIENTALISTA' THEN 'ASAMBLEISTA'
       WHEN s_fnt_prs_ocp = 'AMO DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMS DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'ANA DE CASA' THEN 'AMA DE CASA'
  ELSE
    s_fnt_prs_ocp
  END,
  count(*)
FROM dta_uio.data_gnr GROUP BY 1 ORDER BY 1;

---> READ: Profesion
SELECT * FROM dta_uio.data_gnr;

SELECT 
  s_dnr_prs_prf,
  CASE WHEN s_dnr_prs_prf = '' THEN 'SE DESCONOCE'
       WHEN s_dnr_prs_prf ISNULL THEN 'SE DESCONOCE'
  ELSE 
      s_dnr_prs_prf
  END,
  count(*)
FROM dta_uio.data_gnr GROUP BY 1 ORDER BY 1;

---> READ: Fecha de nacimiento
SELECT * FROM dta_uio.data_gnr;
SELECT * FROM dta_uio.data_2020 WHERE "Fecha_nac" = '19-09-1896';
SELECT * FROM dta_uio.data_20210627 WHERE "Fecha_nac" = '19/09/1896';
SELECT * FROM dta_uio.data_20211008 WHERE "Fecha_nac" = '19/09/1896';

CREATE FUNCTION dta_uio.isValidDate(CHAR) RETURNS bool LANGUAGE plpgsql
AS $function$ 
DECLARE
result BOOL;
validFormat TEXT := 'yyyy-MM-dd';
BEGIN
SELECT TO_CHAR(TO_DATE($1,validFormat),validFormat) = $1
INTO result;
RETURN result;
END;
$function$;


SELECT TO_CHAR(TO_DATE('01-02-2021','dd-MM-yyyy'),'yyyy-MM-dd') = '01-02-2021';



SELECT 
  s_fnt_prs_dte_brt,
  length(s_fnt_prs_dte_brt),
  split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT,
  split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT,
  split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT,
  CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT > 1000 THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END i_yr,
  CASE WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12 THEN split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT 
  ELSE split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  END i_mth,
  CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT < 1000  THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
       WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12 THEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END AS i_day,
  ((CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT > 1000 AND d_dnr_prs_dte_brt ISNULL THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12 AND d_dnr_prs_dte_brt ISNULL THEN split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT 
  ELSE split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT < 1000 AND d_dnr_prs_dte_brt ISNULL THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
       WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12 AND d_dnr_prs_dte_brt ISNULL THEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END))::date,
  count(*)
FROM dta_uio.data_gnr
WHERE d_dnr_prs_dte_brt ISNULL
GROUP BY 1,d_dnr_prs_dte_brt
ORDER BY 7,8 DESC;

SELECT * FROM dta_uio.data_2020 WHERE "Fecha_nac" ilike '%1885%';
SELECT * FROM dta_uio.data_20210627 WHERE "Fecha_nac" ilike '%1876%';
SELECT * FROM dta_uio.data_20211008 WHERE "Fecha_nac" ilike '%1876%';
REFRESH MATERIALIZED VIEW dta_uio.data_2020_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_2021;
REFRESH MATERIALIZED VIEW dta_uio.data_2021_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_gnr;
SELECT 
  s_fnt_prs_dte_brt, 
  d_dnr_prs_dte_brt,
  CASE WHEN s_fnt_prs_dte_brt ISNULL AND d_dnr_prs_dte_brt ISNULL THEN to_date('1900-01-01','yyyy-MM-dd') 
  WHEN d_dnr_prs_dte_brt ISNULL THEN 
  ((CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT > 1000  THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12  THEN split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT 
  ELSE split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT < 1000 THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
       WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12 THEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END))::date
  ELSE 
  d_dnr_prs_dte_brt 
  END AS d_gnr_prs_dte_brt,  
  count(*) 
FROM dta_uio.data_gnr GROUP BY 1,2 ORDER BY 3 ASC ;


---> READ: edad
SELECT * FROM dta_uio.data_gnr;

---> CREATE: Funcion para calcular la fecha de nacimiento con las condiciones de la data original
DROP FUNCTION dta_uio.d_dte_brt(s_fnt_prs_dte_brt TEXT, d_dnr_prs_dte_brt date);
CREATE OR REPLACE FUNCTION dta_uio.d_dte_brt(s_fnt_prs_dte_brt TEXT, d_dnr_prs_dte_brt date) RETURNS date LANGUAGE plpgsql
AS $function$ 
DECLARE
d_dte date;
validFormat TEXT := 'yyyy-MM-dd';
dfl date := '1900-01-01';
BEGIN
d_dte := (SELECT
  CASE WHEN s_fnt_prs_dte_brt ISNULL AND d_dnr_prs_dte_brt ISNULL THEN to_date('1900-01-01','yyyy-MM-dd') 
  WHEN d_dnr_prs_dte_brt ISNULL THEN 
  ((CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT > 1000  THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12  THEN split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT 
  ELSE split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT < 1000 THEN split_part(s_fnt_prs_dte_brt,'-',3)::SMALLINT
       WHEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT > 12 THEN split_part(s_fnt_prs_dte_brt,'-',2)::SMALLINT
  ELSE split_part(s_fnt_prs_dte_brt,'-',1)::SMALLINT
  END))::date
  ELSE 
  d_dnr_prs_dte_brt 
  END); 
RETURN d_dte;
END;
$function$;

SELECT s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt) FROM dta_uio.data_gnr ORDER BY 1 DESC;

---> CREATE: Funcion para calcular la edad
DROP FUNCTION dta_uio.i_age_brt(d_fnt_prs_dte_att TEXT, d_dnr_prs_dte_brt date, s_age TEXT);
CREATE OR REPLACE FUNCTION dta_uio.i_age_brt(d_fnt_prs_dte_att date, s_fnt_prs_dte_brt TEXT, d_dnr_prs_dte_brt date, s_age TEXT) RETURNS smallint LANGUAGE plpgsql
AS $function$ 
DECLARE
i_vle_yr smallint;
i_vle smallint;
BEGIN
	i_vle_yr := (SELECT
  				 CASE WHEN d_dnr_prs_dte_brt ISNULL THEN date_part('year', age(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))::SMALLINT
  				 ELSE date_part('year', age(d_fnt_prs_dte_att, d_dnr_prs_dte_brt))::SMALLINT  
  				 END); 
    IF (i_vle_yr >= 120) THEN
    	i_vle:= -99;
    ELSE
    	i_vle := (SELECT
  				 CASE WHEN d_dnr_prs_dte_brt ISNULL THEN date_part(s_age, age(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))::SMALLINT
  				 ELSE date_part(s_age, age(d_fnt_prs_dte_att, d_dnr_prs_dte_brt))::SMALLINT  
  				 END);
    END IF;
RETURN i_vle;
END;
$function$;

SELECT
  s_fnt_prs_dte_brt_yr, 
  d_dnr_prs_dte_brt,
  dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt) AS d_gnr_prs_dte_brt,
  CASE WHEN d_dnr_prs_dte_brt ISNULL THEN date_part('year'::text, age(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))::SMALLINT
  ELSE 
  date_part('year'::text, age(d_fnt_prs_dte_att, d_dnr_prs_dte_brt))::SMALLINT  
  END,
  CASE WHEN d_dnr_prs_dte_brt ISNULL THEN date_part('month'::text, age(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))::SMALLINT
  ELSE 
  date_part('month'::text, age(d_fnt_prs_dte_att, d_dnr_prs_dte_brt))::SMALLINT  
  END,
  CASE WHEN d_dnr_prs_dte_brt ISNULL THEN date_part('day'::text, age(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))::SMALLINT
  ELSE 
  date_part('day'::text, age(d_fnt_prs_dte_att, d_dnr_prs_dte_brt))::SMALLINT  
  END,
  dta_uio.i_age_brt(d_fnt_prs_dte_att, s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, 'year') AS i_gnr_prs_brt_yr,
  dta_uio.i_age_brt(d_fnt_prs_dte_att, s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, 'month') AS i_gnr_prs_brt_mth,
  dta_uio.i_age_brt(d_fnt_prs_dte_att, s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, 'day') AS i_gnr_prs_brt_day,
  count(*) 
FROM dta_uio.data_gnr GROUP BY 1,2,3,d_fnt_prs_dte_att, s_fnt_prs_dte_brt  ORDER BY 3;


---> READ: Grupo de edad
SELECT * FROM dta_uio.data_gnr;
SELECT 
dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt) AS d_gnr_prs_dte_brt,
dta_uio.sif_sql(dta_uio.age_grp(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)) ISNULL, 'SE DESCONOCE',dta_uio.age_grp(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))  AS s_dnr_prs_age_grp
FROM dta_uio.data_gnr
ORDER BY 2 DESC ;


---> READ: Provincia
SELECT * FROM dta_uio.data_gnr;
SELECT 
  s_fnt_prs_rsd_prv_nme,
  CASE WHEN s_fnt_prs_rsd_prv_nme = 'LOS RÍOS' THEN 'LOS RIOS'
       WHEN s_fnt_prs_rsd_prv_nme = 'CHILLOGALLO' THEN 'PICHINCHA'
       WHEN s_fnt_prs_rsd_prv_nme = 'BOLÍVAR' THEN 'BOLIVAR'
       WHEN s_fnt_prs_rsd_prv_nme = 'MANABÍ' THEN 'MANABI'
       WHEN s_fnt_prs_rsd_prv_nme = 'SANTO DOMINGO DE LOS TSÁCHILAS' THEN 'SANTO DOMINGO DE LOS TSACHILAS'
       WHEN s_fnt_prs_rsd_prv_nme = 'SUCUMBÍOS' THEN 'SUCUMBIOS'
       WHEN s_fnt_prs_rsd_prv_nme ISNULL AND s_dnr_prs_prv_nme NOTNULL THEN (CASE WHEN s_dnr_prs_prv_nme = '' THEN 'SE DESCONOCE'
                                                                                  WHEN s_dnr_prs_prv_nme = 'STO DGO TSACHIL' THEN 'SANTO DOMINGO DE LOS TSACHILAS'
                                                                                  WHEN s_dnr_prs_prv_nme = 'REP. DOMINICANA' THEN 'REPUBLICA DOMINICANA'
                                                                                  WHEN s_dnr_prs_prv_nme = 'PERÚ' THEN 'PERU'
                                                                                  WHEN s_dnr_prs_prv_nme = 'PAÍSES BAJOS' THEN 'PAISES BAJOS'
                                                                                  WHEN s_dnr_prs_prv_nme = 'MÉXICO' THEN 'MEXICO'
                                                                                  WHEN s_dnr_prs_prv_nme = 'IRÁN' THEN 'IRAN'
                                                                                  WHEN s_dnr_prs_prv_nme = 'HAITÍ' THEN 'HAITI'
                                                                                  WHEN s_dnr_prs_prv_nme = 'ESTADOS UNIDOS DE AMÉRICA' THEN 'ESTADOS UNIDOS'
                                                                                  WHEN s_dnr_prs_prv_nme = 'CANADÁ' THEN 'CANADA'
                                                                                  WHEN s_dnr_prs_prv_nme = 'BÉLGICA' THEN 'BELGICA'
                                                                                  WHEN s_dnr_prs_prv_nme = 'AFGANISTÁN' THEN 'AFGANISTAN'
                                                                             ELSE s_dnr_prs_prv_nme END)
       WHEN s_fnt_prs_rsd_prv_nme ISNULL THEN 'SE DESCONOCE'
  ELSE
    s_fnt_prs_rsd_prv_nme
  END AS s_gnr_prs_rsd_prv_nme,
  count(*) 
FROM dta_uio.data_gnr GROUP BY 1, s_dnr_prs_prv_nme ORDER BY 1 DESC;

SELECT 
s_fnt_prs_rsd_prv_nme,
CASE WHEN s_fnt_prs_rsd_prv_nme = 'LOS RÍOS' THEN 'LOS RIOS'
       WHEN s_fnt_prs_rsd_prv_nme = 'CHILLOGALLO' THEN 'PICHINCHA'
       WHEN s_fnt_prs_rsd_prv_nme = 'BOLÍVAR' THEN 'BOLIVAR'
       WHEN s_fnt_prs_rsd_prv_nme = 'MANABÍ' THEN 'MANABI'
       WHEN s_fnt_prs_rsd_prv_nme = 'SANTO DOMINGO DE LOS TSÁCHILAS' THEN 'SANTO DOMINGO DE LOS TSACHILAS'
       WHEN s_fnt_prs_rsd_prv_nme = 'SUCUMBÍOS' THEN 'SUCUMBIOS'
       WHEN s_fnt_prs_rsd_prv_nme ISNULL THEN 'SE DESCONOCE'
 ELSE s_fnt_prs_rsd_prv_nme
 END,
count(*) 
FROM dta_uio.data_gnr GROUP BY 1 ORDER BY 1 DESC;

---> READ: Parroquia
--> pedir que corrijan los brigadistas
SELECT * FROM dta_uio.data_gnr;
SELECT 
  s_fnt_prs_rsd_prq_nme,
  CASE WHEN s_fnt_prs_rsd_prq_nme ISNULL THEN 'SE DESCONOCE' 
       WHEN s_fnt_prs_rsd_prq_nme = 'ALANGASÍ' THEN 'ALANGASI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ALÓAG' THEN 'ALOAG'
       WHEN s_fnt_prs_rsd_prq_nme = 'ALOASÍ' THEN 'ALOASI'
       WHEN s_fnt_prs_rsd_prq_nme = 'AMBUQUÍ' THEN 'AMBUQUI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ASCÁZUBI' THEN 'ASCAZUBI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ATHUALPA' THEN 'ATAHUALPA'
       WHEN s_fnt_prs_rsd_prq_nme = 'BOMBOLÍ' THEN 'BOMBOLI'
       WHEN s_fnt_prs_rsd_prq_nme = 'CALACALÍ' THEN 'CALACALI'
       WHEN s_fnt_prs_rsd_prq_nme = 'CARCELÉN' THEN 'CARCELEN'
       WHEN s_fnt_prs_rsd_prq_nme = 'CENTRO HISTÓRICO' THEN 'CENTRO HISTORICO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHAUPICUS' THEN 'CHAUPICRUZ'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHILLOGALO' THEN 'CHILLOGALLO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHIMBACALÑR' THEN 'CHIMBACALLE'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHMBACALLE' THEN 'CHIMBACALLE'
       WHEN s_fnt_prs_rsd_prq_nme = 'COMITE DEL PUEBLO' THEN 'COMITE DEL PUEBLO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CONCEPCIÓN' THEN 'CONCEPCION'
       WHEN s_fnt_prs_rsd_prq_nme = 'COTOCOLLLAO' THEN 'COTOCOLLAO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CPTOCOLLAO' THEN 'COTOCOLLAO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUBIJÍES' THEN 'CUBIJIES'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUMBAYÁ' THEN 'CUMBAYA'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUTULAGUA' THEN 'CUTUGLAGUA'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUTULAGHUA' THEN 'CUTUGLAGUA'
       WHEN s_fnt_prs_rsd_prq_nme = 'CONDADO' THEN 'EL CONDADO'
       WHEN s_fnt_prs_rsd_prq_nme = 'GUAMANANI' THEN 'GUAMANI'
       WHEN s_fnt_prs_rsd_prq_nme = 'GUAMANÍ' THEN 'GUAMANI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ICHIMBIA' THEN 'ITCHIMBIA'
       WHEN s_fnt_prs_rsd_prq_nme = 'ITCHIMBÍA' THEN 'ITCHIMBIA'
       WHEN s_fnt_prs_rsd_prq_nme = 'ITCHIBIA' THEN 'ITCHIMBIA'
  ELSE s_fnt_prs_rsd_prq_nme
  END,
  count(*) 
FROM dta_uio.data_gnr GROUP BY 1 ORDER BY 1;


---> READ: Barrios
SELECT * FROM dta_uio.data_gnr;
SELECT 
s_fnt_prs_rsd_brr_nme,
count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1;

---> READ: Canton
SELECT * FROM dta_uio.data_gnr;
SELECT 
CASE WHEN s_fnt_prs_rsd_prv_nme = 'LOS RÍOS' THEN 'LOS RIOS'
       WHEN s_fnt_prs_rsd_prv_nme = 'CHILLOGALLO' THEN 'PICHINCHA'
       WHEN s_fnt_prs_rsd_prv_nme = 'BOLÍVAR' THEN 'BOLIVAR'
       WHEN s_fnt_prs_rsd_prv_nme = 'MANABÍ' THEN 'MANABI'
       WHEN s_fnt_prs_rsd_prv_nme = 'SANTO DOMINGO DE LOS TSÁCHILAS' THEN 'SANTO DOMINGO DE LOS TSACHILAS'
       WHEN s_fnt_prs_rsd_prv_nme = 'SUCUMBÍOS' THEN 'SUCUMBIOS'
       WHEN s_fnt_prs_rsd_prv_nme ISNULL AND s_dnr_prs_prv_nme NOTNULL THEN (CASE WHEN s_dnr_prs_prv_nme = '' THEN 'SE DESCONOCE'
                                                                                  WHEN s_dnr_prs_prv_nme = 'STO DGO TSACHIL' THEN 'SANTO DOMINGO DE LOS TSACHILAS'
                                                                                  WHEN s_dnr_prs_prv_nme = 'REP. DOMINICANA' THEN 'REPUBLICA DOMINICANA'
                                                                                  WHEN s_dnr_prs_prv_nme = 'PERÚ' THEN 'PERU'
                                                                                  WHEN s_dnr_prs_prv_nme = 'PAÍSES BAJOS' THEN 'PAISES BAJOS'
                                                                                  WHEN s_dnr_prs_prv_nme = 'MÉXICO' THEN 'MEXICO'
                                                                                  WHEN s_dnr_prs_prv_nme = 'IRÁN' THEN 'IRAN'
                                                                                  WHEN s_dnr_prs_prv_nme = 'HAITÍ' THEN 'HAITI'
                                                                                  WHEN s_dnr_prs_prv_nme = 'ESTADOS UNIDOS DE AMÉRICA' THEN 'ESTADOS UNIDOS'
                                                                                  WHEN s_dnr_prs_prv_nme = 'CANADÁ' THEN 'CANADA'
                                                                                  WHEN s_dnr_prs_prv_nme = 'BÉLGICA' THEN 'BELGICA'
                                                                                  WHEN s_dnr_prs_prv_nme = 'AFGANISTÁN' THEN 'AFGANISTAN'
                                                                             ELSE s_dnr_prs_prv_nme END)
       WHEN s_fnt_prs_rsd_prv_nme ISNULL THEN 'SE DESCONOCE'
  ELSE
    s_fnt_prs_rsd_prv_nme
  END AS s_gnr_prs_rsd_prv_nme,
  s_dnr_prs_cnt_nme,
  CASE WHEN s_dnr_prs_cnt_nme = '' OR s_dnr_prs_cnt_nme ISNULL THEN 'SE DESCONOCE'
       WHEN s_dnr_prs_cnt_nme = '' OR s_dnr_prs_cnt_nme ISNULL THEN 'SE DESCONOCE'
  ELSE s_dnr_prs_cnt_nme
  END, 
 count(*) FROM dta_uio.data_gnr GROUP BY 1,2 ORDER BY 1;


---> READ: Viaje
SELECT * FROM dta_uio.data_gnr;

SELECT 
s_fnt_prs_trv,
CASE WHEN s_fnt_prs_trv = '44379' THEN 'SI'
     WHEN s_fnt_prs_trv = '44383' THEN 'SI'
     WHEN s_fnt_prs_trv = 'ASMA BRONQUIAL' THEN 'SI'
     WHEN s_fnt_prs_trv = 'DENTRO PAÍS' THEN 'DENTRO PAIS'
     WHEN s_fnt_prs_trv = 'FUERA PAÍS' THEN 'FUERA PAIS'
     WHEN s_fnt_prs_trv = 'NO APLICA' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv = 'NO REFIERE' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv = 'S' THEN 'SI'
     WHEN s_fnt_prs_trv = 'X' THEN 'SI'
     WHEN s_fnt_prs_trv = 'SU' THEN 'SI'
     WHEN s_fnt_prs_trv ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv = 'DIABETES' THEN 'NO'
     WHEN s_fnt_prs_trv = 'ESMERALDAS' THEN 'SI'
     WHEN s_fnt_prs_trv = 'GUAYAQUIL' THEN 'SI'
     WHEN s_fnt_prs_trv = 'GUAYAQUIL MACHALA SANTO DOMINGO' THEN 'SI'
     WHEN s_fnt_prs_trv = 'NINGUNA' THEN 'SI'
     WHEN s_fnt_prs_trv = 'NINGUNO' THEN 'SI'
     WHEN s_fnt_prs_trv = 'DENTRO DEL PAIS' THEN 'DENTRO PAIS'
ELSE s_fnt_prs_trv
END,
count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_trv,
s_fnt_prs_trv_dte,
s_fnt_prs_trv_ste,
CASE WHEN s_fnt_prs_trv = '44379' THEN 'SI'
     WHEN s_fnt_prs_trv = '44383' THEN 'SI'
     WHEN s_fnt_prs_trv = 'ASMA BRONQUIAL' THEN 'SI'
     WHEN s_fnt_prs_trv = 'DENTRO PAÍS' THEN 'DENTRO PAIS'
     WHEN s_fnt_prs_trv = 'FUERA PAÍS' THEN 'FUERA PAIS'
     WHEN s_fnt_prs_trv = 'NO APLICA' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv = 'NO REFIERE' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv = 'S' THEN 'SI'
     WHEN s_fnt_prs_trv = 'X' THEN 'SI'
     WHEN s_fnt_prs_trv = 'SU' THEN 'SI'
     WHEN s_fnt_prs_trv ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv = 'DIABETES' THEN 'NO'
     WHEN s_fnt_prs_trv = 'ESMERALDAS' THEN 'SI'
     WHEN s_fnt_prs_trv = 'GUAYAQUIL' THEN 'SI'
     WHEN s_fnt_prs_trv = 'GUAYAQUIL MACHALA SANTO DOMINGO' THEN 'SI'
     WHEN s_fnt_prs_trv = 'NINGUNA' THEN 'SI'
     WHEN s_fnt_prs_trv = 'NINGUNO' THEN 'SI'
     WHEN s_fnt_prs_trv = 'DENTRO DEL PAIS' THEN 'DENTRO PAIS'
ELSE s_fnt_prs_trv
END,
CASE WHEN s_fnt_prs_trv_dte ISNULL THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'X' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'SI                      10/07/2021' THEN RIGHT(s_fnt_prs_trv_dte,10)
     WHEN s_fnt_prs_trv_dte = ' ' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = '-' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = '' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = '44381' THEN s_fnt_prs_trv_ste
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = '44378' THEN s_fnt_prs_trv_ste
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = '03/052021' THEN s_fnt_prs_trv_ste
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = '44377' THEN s_fnt_prs_trv_ste
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = 'NINGUNO' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = 'GUARANDA' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = '44372' THEN s_fnt_prs_trv_ste
     WHEN s_fnt_prs_trv_dte = 'SI' AND s_fnt_prs_trv_ste = '44380' THEN s_fnt_prs_trv_ste
     WHEN s_fnt_prs_trv_dte = 'SANTO DOMINGO' AND s_fnt_prs_trv_ste = '#######' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO APLICA' AND s_fnt_prs_trv_ste = 'NO APLICA' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO APLICA' AND s_fnt_prs_trv_ste = 'NO APLICA' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO' AND s_fnt_prs_trv_ste = 'NO' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO' AND s_fnt_prs_trv_ste = 'NO' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO' AND s_fnt_prs_trv_ste = 'NINGUNO' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO' AND s_fnt_prs_trv_ste = 'NP' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO' AND s_fnt_prs_trv_ste ISNULL THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NO' AND s_fnt_prs_trv_ste = 'X' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NINGUNO' AND s_fnt_prs_trv_ste = 'NINGUNO' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'NINGUNA' AND s_fnt_prs_trv_ste = 'NINGUNA' THEN '1900-01-01'
     WHEN s_fnt_prs_trv_dte = 'GUAYAQUIL' AND s_fnt_prs_trv_ste ISNULL THEN '1900-01-01'
ELSE s_fnt_prs_trv_dte
END,
count(*)
FROM dta_uio.data_gnr
GROUP BY 1,2,3
ORDER BY 2 DESC;
---> READ: Construir consulta actualizada
SELECT 
 i_fnt_yr,
 i_fnt_epi_wk,
 d_fnt_prs_dte_att,
 s_fnt_brg_att_grp,
 s_fnt_brg_att_grp_sub,
 s_fnt_prq_att,
 CASE WHEN s_fnt_brg_nmb ISNULL THEN 'SE DESCONOCE' ELSE s_fnt_brg_nmb END AS s_gnr_brg_nmb,
 CASE WHEN s_fnt_prs_idn = '' THEN 'SE DESCONOCE' 
       WHEN s_fnt_prs_idn = '0' THEN 'SE DESCONOCE' 
       WHEN s_fnt_prs_idn = 'Y' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '000000000' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '0000000000' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '99999999999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '99999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '9999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '999999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '999999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '99999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '9999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = '999' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'LUIS AUGUSTO PAVON ROJAS' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'N/A' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NNNN' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO RECUERDA' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO REFIERE' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO SABE' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'NO TIENE' THEN 'SE DESCONOCE'     
       WHEN s_fnt_prs_idn = 'DESCONOCE' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn = 'G' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn ISNULL AND s_dnr_prs_idn ISNULL THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_idn ISNULL AND s_dnr_prs_idn NOTNULL THEN s_dnr_prs_idn
  ELSE 
      s_fnt_prs_idn
  END AS s_gnr_prs_idn,
  CASE WHEN s_fnt_prs_nme = '#NULL!' AND s_dnr_prs_idn ISNULL THEN 'SE DESCONOCE'
  	   WHEN s_dnr_prs_idn NOTNULL THEN  s_dnr_prs_nme
  	   WHEN s_fnt_prs_nme = '7434053' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '6875977' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '175901093' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '089714782' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '19972476' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '1755916649' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme = '1707667502' THEN 'SE DESCONOCE'
  	   WHEN s_fnt_prs_nme ISNULL AND s_dnr_prs_idn ISNULL AND s_dnr_prs_nme ISNULL AND s_fnt_prs_idn NOTNULL THEN 'SE DESCONOCE'
  ELSE 
          s_fnt_prs_nme
  END AS s_gnr_prs_nme,
  s_fnt_prs_sex,
  CASE WHEN s_fnt_prs_nth = 'VENEZOLANO' THEN 'VENEZUELA'
       WHEN s_fnt_prs_nth = 'VENEZOLANA' THEN 'VENEZUELA'
       WHEN s_fnt_prs_nth = 'COLOMBIANA' THEN 'COLOMBIA'
       WHEN s_fnt_prs_nth = 'COLOMBIANO' THEN 'COLOMBIA'
       WHEN s_fnt_prs_nth = 'ECUARORIANA' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ECUATORIANA' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ECUATORIANA NO DISPONE' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ECUATORIANO' THEN 'ECUADOR'
       WHEN s_fnt_prs_nth = 'ESPAÑOLA' THEN 'ESPAÑA'
       WHEN s_fnt_prs_nth = 'ESTADOUNIDENSE' THEN 'ESTADOS UNIDOS'
       WHEN s_fnt_prs_nth = 'DOMÍNICA' THEN 'DOMINICA'
       WHEN s_fnt_prs_nth = 'CAMERÚN' THEN 'CAMERUN'
       WHEN s_fnt_prs_nth = 'CANADÁ' THEN 'CANADA'
       WHEN s_fnt_prs_nth = 'HAITÍ' THEN 'HAITI'
       WHEN s_fnt_prs_nth = 'IRÁN' THEN 'IRAN'
       WHEN s_fnt_prs_nth = 'PAKISTÁN' THEN 'PAKISTAN'
       WHEN s_fnt_prs_nth = 'PERÚ' THEN 'PERU'
       WHEN s_fnt_prs_nth = 'PERUANA' THEN 'PERU'
       WHEN s_fnt_prs_nth = 'REPÚBLICA DOMINICANA' THEN 'REPUBLICA DOMINICANA'
       WHEN s_dnr_prs_idn NOTNULL THEN 'ECUADOR'
       WHEN s_dnr_prs_idn ISNULL AND s_fnt_prs_nth ISNULL THEN 'SE DESCONOCE' 
  ELSE
           s_fnt_prs_nth
  END AS s_gnr_prs_nth,
  CASE WHEN s_fnt_prs_eth = '' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_eth = 'AFROAMERICANA' THEN 'AFROAMERICANO'
       WHEN s_fnt_prs_eth = 'AFROFESENDIENTE' THEN 'AFRODESCENDIENTE'
       WHEN s_fnt_prs_eth = 'INDÍGENA' THEN 'INDIGENA'
       WHEN s_fnt_prs_eth = 'MESTIZA' THEN 'MESTIZO'
       WHEN s_fnt_prs_eth = 'MONTUBIA' THEN 'MONTUBIO'
       WHEN s_fnt_prs_eth = 'MULATA' THEN 'MULATO'
       WHEN s_fnt_prs_eth = 'NEGRA' THEN 'NEGRO'
       WHEN s_fnt_prs_eth = 'OTROS' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_eth ISNULL THEN 'SE DESCONOCE'
  ELSE 
    s_fnt_prs_eth
  END AS s_gnr_prs_eth,
  CASE WHEN s_fnt_prs_ins = '' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ISNULL THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='BACHILLER' THEN 'BACHILLERATO'
       WHEN s_fnt_prs_ins ='BACHILERATO' THEN 'BACHILLERATO'
       WHEN s_fnt_prs_ins ='ANALFABETA' THEN 'ANALFABETO'
       WHEN s_fnt_prs_ins ='BACHILLERTO' THEN 'BACHILLERATO'
       WHEN s_fnt_prs_ins ='BÁSICA' THEN 'BASICO'
       WHEN s_fnt_prs_ins ='BASICA' THEN 'BASICO'
       WHEN s_fnt_prs_ins ='FEMENINO' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='MASCULINO' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='MDQ' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='NINGUNA' THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ins ='SECUANDARIA' THEN 'SECUNDARIA'
       WHEN s_fnt_prs_ins ='BACHILLERATO IMCOMPLETO' THEN 'BACHILLERATO INCOMPLETO'
       WHEN s_fnt_prs_ins ='SUPERIOR INCOMPLETA' THEN 'SUPERIOR INCOMPLETO'
       WHEN s_fnt_prs_ins ='TECNICO' THEN 'TECNOLOGO'
       WHEN s_fnt_prs_ins ='TEGNOLOGA' THEN 'TECNOLOGO'
       WHEN s_fnt_prs_ins ='TECNOLOGICO' THEN 'TECNOLOGO'
       WHEN s_fnt_prs_ins ='UNIVERSITARIA' THEN 'UNIVERSITARIO'
  ELSE
      s_fnt_prs_ins
  END AS s_gnr_prs_ins,
  CASE WHEN s_fnt_prs_ocp ISNULL THEN 'SE DESCONOCE'
       WHEN s_fnt_prs_ocp = 'ZAPATERÍA' THEN 'ZAPATERO'
       WHEN s_fnt_prs_ocp = 'ZAPATERIA' THEN 'ZAPATERO'
       WHEN s_fnt_prs_ocp = 'ZAPATERA' THEN 'ZAPATERO'
       WHEN s_fnt_prs_ocp = 'ABIGADO' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADA' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADO.' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADS' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'ABOGADA ANALISTA DE PROMOCION DE DERECHOS' THEN 'ABOGADO ANALISTA DE PROMOCION DE DERECHOS'
       WHEN s_fnt_prs_ocp = 'ABOGADA COMERCIANTE' THEN 'ABOGADO COMERCIANTE'
       WHEN s_fnt_prs_ocp = 'ABOGADA DE DESPACHO' THEN 'ABOGADO DE DESPACHO'
       WHEN s_fnt_prs_ocp = 'ABOGADA DIRECTORA DE GESTION' THEN 'ABOGADO DIRECTOR DE GESTION'
       WHEN s_fnt_prs_ocp = 'ABOGADA EMPLEADA PUBLICA' THEN 'ABOGADO EMPLEADO PUBLICO'
       WHEN s_fnt_prs_ocp = 'ABOGADA MÉDICA ANDINA' THEN 'ABOGADO MEDICO ANDINO'
       WHEN s_fnt_prs_ocp = 'ABOGADA, COMERCIANTE' THEN 'ABOGADO COMERCIANTE'
       WHEN s_fnt_prs_ocp = 'ABOGADA. EMPLEADA MUNICIPAL' THEN 'ABOGADO EMPLEADO MUNICIPAL'
       WHEN s_fnt_prs_ocp = 'ABOGADO DEL  ESTADO' THEN 'ABOGADO DEL ESTADO'
       WHEN s_fnt_prs_ocp = 'ABOGADO EN MINISTERIO' THEN 'ABOGADO DEL MINISTERIO'
       WHEN s_fnt_prs_ocp = 'ACABADOS DE CONSTRUCCIÓN' THEN 'ACABADOS DE CONSTRUCCION'
       WHEN s_fnt_prs_ocp = 'ACCCESOR DE VENTAS' THEN 'ASESOR DE VENTAS'
       WHEN s_fnt_prs_ocp = 'ACCESOR COMERCIAL' THEN 'ASESOR COMERCIAL'
       WHEN s_fnt_prs_ocp = 'ACCESOR DE PROYECTOS' THEN 'ASESOR DE PROYECTOS'
       WHEN s_fnt_prs_ocp = 'ACCESOR EN VENTAS' THEN 'ASESOR DE VENTAS'
       WHEN s_fnt_prs_ocp = 'ACCESORIA COMERCIAL' THEN 'ASESOR COMERCIAL'
       WHEN s_fnt_prs_ocp = 'ACCESORIA DE CAMPO' THEN 'ASESOR DE CAMPO'
       WHEN s_fnt_prs_ocp = 'ACCIÓN Y PRODUCCIÓN' THEN 'ACCION Y PRODUCCION'
       WHEN s_fnt_prs_ocp = 'ACESESOR COMERCIAL' THEN 'ASESOR COMERCIAL'
       WHEN s_fnt_prs_ocp = 'ACESOR' THEN 'ASESOR'
       WHEN s_fnt_prs_ocp = '.MILITARR' THEN 'MILITAR'
       WHEN s_fnt_prs_ocp = '3MPKEADO EN FABRICA' THEN 'EMPLEADO DE FABRICA'
       WHEN s_fnt_prs_ocp = '3STUDIANTE' THEN 'ESTUDIANTE'
       WHEN s_fnt_prs_ocp = 'A,MA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AAMA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'ABAOGADO' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL D ETRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL D TRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL DE TRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL DE TRÁNSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CIVIL TRANSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE CVIL DE TRÁNSITO' THEN 'AGENTE CIVIL DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE DE TRÁNSITO' THEN 'AGENTE DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE DE. SEGURIDAD' THEN 'AGENTE DE SEGURIDAD'
       WHEN s_fnt_prs_ocp = 'AGENTE MEROPOLITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METOPOLITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPILITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPILOTANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPITANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPOLITANA' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE METROPOLTANO' THEN 'AGENTE METROPOLITANO'
       WHEN s_fnt_prs_ocp = 'AGENTE TRANSITO' THEN 'AGENTE DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGENTE TRÁNSITO' THEN 'AGENTE DE TRANSITO'
       WHEN s_fnt_prs_ocp = 'AGOGADA' THEN 'ABOGADO'
       WHEN s_fnt_prs_ocp = 'AGRICILTURA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AGRICOLA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AGRÍCOLA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AGRICULTORA' THEN 'AGRICULTOR'
       WHEN s_fnt_prs_ocp = 'AISTENTE' THEN 'ASISTENTE'
       WHEN s_fnt_prs_ocp = 'AGUA POTABEL' THEN 'AGUA POTABLE'
       WHEN s_fnt_prs_ocp = 'AISTENTE' THEN 'ASISTENTE'
       WHEN s_fnt_prs_ocp = 'AISTENTE DE TALLER' THEN 'ASISTENTE DE TALLER'
       WHEN s_fnt_prs_ocp = 'AISTENTE TECNICO' THEN 'ASISTENTE TECNICO'
       WHEN s_fnt_prs_ocp = 'AJENTE DE VIAJES' THEN 'AGENTE DE VIAJES'
       WHEN s_fnt_prs_ocp = 'AJUBILADO' THEN 'JUBILADO'
       WHEN s_fnt_prs_ocp = 'ALABAÑIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑEL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑIEL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBANIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑILERIA' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑILERÍA' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑILES' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAÑLIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALBAOÑIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'ALMA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'ALVANIL' THEN 'ALBAÑIL'
       WHEN s_fnt_prs_ocp = 'AM ADE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AM DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA  DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA D CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DDE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE  CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE 6' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE ACASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE C ASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CAA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CADA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CADO' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CAS' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA A' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DÉ CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA.' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA|' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASA1' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASAA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASAS' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASQ' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASS' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CASSA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CCASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CSA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE CSSA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE XASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DE. CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DECASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA DR CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA E CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA SE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA. DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMA.DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMADE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMAN DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMAÑA DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMBIENTALISTA' THEN 'ASAMBLEISTA'
       WHEN s_fnt_prs_ocp = 'AMO DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'AMS DE CASA' THEN 'AMA DE CASA'
       WHEN s_fnt_prs_ocp = 'ANA DE CASA' THEN 'AMA DE CASA'
  ELSE
    s_fnt_prs_ocp
  END AS s_gnr_prs_ocp,
  CASE WHEN s_dnr_prs_prf = '' THEN 'SE DESCONOCE'
       WHEN s_dnr_prs_prf ISNULL THEN 'SE DESCONOCE'
  ELSE 
      s_dnr_prs_prf
  END AS s_gnr_prs_prf,
  dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt) AS d_gnr_prs_dte_brt,
  dta_uio.i_age_brt(d_fnt_prs_dte_att, s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, 'year') AS i_gnr_prs_age_yr,
  dta_uio.i_age_brt(d_fnt_prs_dte_att, s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, 'month') AS i_gnr_prs_age_mth,
  dta_uio.i_age_brt(d_fnt_prs_dte_att, s_fnt_prs_dte_brt, d_dnr_prs_dte_brt, 'day') AS i_gnr_prs_age_day,
  dta_uio.sif_sql(dta_uio.age_grp(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)) ISNULL, 'SE DESCONOCE',dta_uio.age_grp(d_fnt_prs_dte_att, dta_uio.d_dte_brt(s_fnt_prs_dte_brt, d_dnr_prs_dte_brt)))  AS s_dnr_prs_age_grp,
  CASE WHEN d_dnr_prs_dte_dfn ISNULL THEN '1900-01-01' ELSE d_dnr_prs_dte_dfn END AS d_gnr_prs_dte_dfn,
  dta_uio.sif_sql(s_dnr_prs_stt ISNULL, 'SE DESCONOCE', s_dnr_prs_stt) AS s_gnr_prs_stt,
  dta_uio.sif_sql(s_dnr_prs_cyg = '' OR s_dnr_prs_cyg ISNULL, 'SE DESCONOCE', s_dnr_prs_cyg) AS s_gnr_prs_cyg,
  CASE WHEN s_fnt_prs_rsd_prv_nme = 'LOS RÍOS' THEN 'LOS RIOS'
       WHEN s_fnt_prs_rsd_prv_nme = 'CHILLOGALLO' THEN 'PICHINCHA'
       WHEN s_fnt_prs_rsd_prv_nme = 'BOLÍVAR' THEN 'BOLIVAR'
       WHEN s_fnt_prs_rsd_prv_nme = 'MANABÍ' THEN 'MANABI'
       WHEN s_fnt_prs_rsd_prv_nme = 'SANTO DOMINGO DE LOS TSÁCHILAS' THEN 'SANTO DOMINGO DE LOS TSACHILAS'
       WHEN s_fnt_prs_rsd_prv_nme = 'SUCUMBÍOS' THEN 'SUCUMBIOS'
       WHEN s_fnt_prs_rsd_prv_nme ISNULL THEN 'SE DESCONOCE'
 ELSE s_fnt_prs_rsd_prv_nme
 END AS s_gnr_prs_rsd_prv_nme,
 CASE WHEN s_fnt_prs_rsd_prq_nme ISNULL THEN 'SE DESCONOCE' 
       WHEN s_fnt_prs_rsd_prq_nme = 'ALANGASÍ' THEN 'ALANGASI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ALÓAG' THEN 'ALOAG'
       WHEN s_fnt_prs_rsd_prq_nme = 'ALOASÍ' THEN 'ALOASI'
       WHEN s_fnt_prs_rsd_prq_nme = 'AMBUQUÍ' THEN 'AMBUQUI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ASCÁZUBI' THEN 'ASCAZUBI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ATHUALPA' THEN 'ATAHUALPA'
       WHEN s_fnt_prs_rsd_prq_nme = 'BOMBOLÍ' THEN 'BOMBOLI'
       WHEN s_fnt_prs_rsd_prq_nme = 'CALACALÍ' THEN 'CALACALI'
       WHEN s_fnt_prs_rsd_prq_nme = 'CARCELÉN' THEN 'CARCELEN'
       WHEN s_fnt_prs_rsd_prq_nme = 'CENTRO HISTÓRICO' THEN 'CENTRO HISTORICO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHAUPICUS' THEN 'CHAUPICRUZ'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHILLOGALO' THEN 'CHILLOGALLO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHIMBACALÑR' THEN 'CHIMBACALLE'
       WHEN s_fnt_prs_rsd_prq_nme = 'CHMBACALLE' THEN 'CHIMBACALLE'
       WHEN s_fnt_prs_rsd_prq_nme = 'COMITE DEL PUEBLO' THEN 'COMITE DEL PUEBLO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CONCEPCIÓN' THEN 'CONCEPCION'
       WHEN s_fnt_prs_rsd_prq_nme = 'COTOCOLLLAO' THEN 'COTOCOLLAO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CPTOCOLLAO' THEN 'COTOCOLLAO'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUBIJÍES' THEN 'CUBIJIES'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUMBAYÁ' THEN 'CUMBAYA'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUTULAGUA' THEN 'CUTUGLAGUA'
       WHEN s_fnt_prs_rsd_prq_nme = 'CUTULAGHUA' THEN 'CUTUGLAGUA'
       WHEN s_fnt_prs_rsd_prq_nme = 'CONDADO' THEN 'EL CONDADO'
       WHEN s_fnt_prs_rsd_prq_nme = 'GUAMANANI' THEN 'GUAMANI'
       WHEN s_fnt_prs_rsd_prq_nme = 'GUAMANÍ' THEN 'GUAMANI'
       WHEN s_fnt_prs_rsd_prq_nme = 'ICHIMBIA' THEN 'ITCHIMBIA'
       WHEN s_fnt_prs_rsd_prq_nme = 'ITCHIMBÍA' THEN 'ITCHIMBIA'
       WHEN s_fnt_prs_rsd_prq_nme = 'ITCHIBIA' THEN 'ITCHIMBIA'
  ELSE s_fnt_prs_rsd_prq_nme
  END AS s_gnr_prs_rsd_prq_nme,
  dta_uio.sif_sql(s_fnt_prs_rsd_brr_nme ISNULL, 'SE DESCONOCE', s_fnt_prs_rsd_brr_nme) AS s_gnr_prs_rsd_brr_nme,
  dta_uio.sif_sql(s_fnt_prs_rsd_adr ISNULL, 'SE DESCONOCE', s_fnt_prs_rsd_adr) AS s_gnr_prs_rsd_adr,
  dta_uio.sif_sql(s_dnr_prs_prv_nme ISNULL OR s_dnr_prs_prv_nme = '', 'SE DESCONOCE', s_dnr_prs_prv_nme) AS s_gnr_dnr_prs_prv_nme,
  dta_uio.sif_sql(s_dnr_prs_cnt_nme ISNULL OR s_dnr_prs_cnt_nme = '', 'SE DESCONOCE', s_dnr_prs_cnt_nme) AS s_gnr_dnr_prs_cnt_nme,
  dta_uio.sif_sql(s_dnr_prs_prq_nme ISNULL OR s_dnr_prs_prq_nme = '', 'SE DESCONOCE', s_dnr_prs_prq_nme) AS s_gnr_dnr_prs_prq_nme,
  
FROM dta_uio.data_gnr
WHERE d_fnt_prs_dte_att NOTNULL 
ORDER BY 1,2,3;


