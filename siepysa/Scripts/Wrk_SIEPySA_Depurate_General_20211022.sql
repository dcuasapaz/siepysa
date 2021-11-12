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
    t1.TABLE_NAME = 'uio_data_gnr'
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

SELECT 
  dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),
  btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),
  ((CASE WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT > 1000  THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT
  ELSE split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',1)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT > 12  THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',1)::SMALLINT 
  ELSE split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT < 1000 THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT
       WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT > 12 THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT
  ELSE split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',1)::SMALLINT
  END))::date
FROM dta_uio.data_gnr
GROUP BY 1;

SELECT 
s_fnt_prs_trv_ste,
CASE WHEN s_fnt_prs_trv_ste = '' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '-' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '#######' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = ' ' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '6' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '13' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '24' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-07-04' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-07-03' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-07-01' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-06-30' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-06-25' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-05-03' THEN 'SE DESCONOCE'
ELSE BTRIM(UPPER(s_fnt_prs_trv_ste))
END,
count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1;


REFRESH MATERIALIZED VIEW dta_uio.data_2020_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_2021;
REFRESH MATERIALIZED VIEW dta_uio.data_2021_fnt;
REFRESH MATERIALIZED VIEW dta_uio.data_gnr;

SELECT 
s_fnt_sgn_prs_stl,
s_fnt_sgn_prs_dst,
CASE WHEN s_fnt_sgn_prs_stl='' THEN -99
     WHEN s_fnt_sgn_prs_stl ISNULL THEN -99
     WHEN s_fnt_sgn_prs_stl='143-' THEN 143
     WHEN s_fnt_sgn_prs_stl='10p' THEN 100
     WHEN s_fnt_sgn_prs_stl='130 0' THEN 130
     WHEN s_fnt_sgn_prs_stl='13q' THEN 130
     WHEN s_fnt_sgn_prs_stl='1p2' THEN 100
     WHEN s_fnt_sgn_prs_stl='126 5' THEN 126
     WHEN s_fnt_sgn_prs_stl='1p0' THEN 100
     WHEN s_fnt_sgn_prs_stl='14q' THEN 140
     WHEN s_fnt_sgn_prs_stl='13r' THEN 130
     WHEN s_fnt_sgn_prs_stl='109t76' THEN 109
     WHEN s_fnt_sgn_prs_stl='100}' THEN 100
     WHEN s_fnt_sgn_prs_stl='12p' THEN 120
     WHEN length(s_fnt_sgn_prs_stl)>3 THEN left(s_fnt_sgn_prs_stl,3)::SMALLINT
ELSE s_fnt_sgn_prs_stl::integer
END AS i_gnr_sgn_prs_stl,
CASE WHEN s_fnt_sgn_prs_dst='' THEN -99
     WHEN s_fnt_sgn_prs_dst ISNULL THEN -99
     WHEN s_fnt_sgn_prs_dst = '6(' THEN 60
     WHEN s_fnt_sgn_prs_dst = '8)' THEN 80
     WHEN s_fnt_sgn_prs_dst = '8''' THEN 80
     WHEN s_fnt_sgn_prs_dst = '7(' THEN 70
     WHEN s_fnt_sgn_prs_dst = '(72' THEN 72
     WHEN s_fnt_sgn_prs_dst = '(7' THEN 70
     WHEN s_fnt_sgn_prs_dst = '7,' THEN 70
     WHEN s_fnt_sgn_prs_dst = '(1' THEN 10
     WHEN s_fnt_sgn_prs_dst = '72.' THEN 72
     WHEN s_fnt_sgn_prs_dst = '&80' THEN 80
     WHEN s_fnt_sgn_prs_dst = '70mw' THEN 70
     WHEN s_fnt_sgn_prs_dst = '8O' THEN 80
     WHEN s_fnt_sgn_prs_dst = '6O' THEN 60
     WHEN s_fnt_sgn_prs_dst = '7O' THEN 70
     WHEN s_fnt_sgn_prs_dst = 'L75' THEN 75
     WHEN s_fnt_sgn_prs_dst = '£0' THEN -99
     WHEN s_fnt_sgn_prs_dst = '6)' THEN 60
     WHEN s_fnt_sgn_prs_dst = '84!' THEN 84
     WHEN s_fnt_sgn_prs_dst = '8£' THEN 83
     WHEN s_fnt_sgn_prs_dst = '78¿7' THEN 78
     WHEN s_fnt_sgn_prs_dst = '68|' THEN 68
     WHEN s_fnt_sgn_prs_dst = '8(' THEN 80
     WHEN s_fnt_sgn_prs_dst = '*97' THEN 97
     WHEN s_fnt_sgn_prs_dst = '&4' THEN 84
     WHEN s_fnt_sgn_prs_dst = '7)' THEN 70
     WHEN s_fnt_sgn_prs_dst = '6$' THEN 65
     WHEN substring(s_fnt_sgn_prs_dst from 1 for 1) = '7' AND length(s_fnt_sgn_prs_dst)>2 THEN RIGHT(s_fnt_sgn_prs_dst,2)::SMALLINT
     WHEN length(s_fnt_sgn_prs_dst) > 2 AND s_fnt_sgn_prs_dst::integer > 120 THEN RIGHT(s_fnt_sgn_prs_dst,2)::SMALLINT
ELSE s_fnt_sgn_prs_dst::integer
END AS i_gnr_sgn_prs_dst,
count(*)
FROM dta_uio.data_gnr
GROUP BY 1,2
ORDER BY 4 DESC;

---> READ: Signos vitales
SELECT 
   i_fnt_sgn_frc_crd, i_fnt_sgn_frc_rsp, i_fnt_sgn_str_oxg, r_fnt_sgn_tpr,
   CASE WHEN i_fnt_sgn_frc_crd ISNULL THEN -99 ELSE i_fnt_sgn_frc_crd END AS i_gnr_sgn_frc_crd,
   CASE WHEN i_fnt_sgn_frc_rsp ISNULL THEN -99 ELSE i_fnt_sgn_frc_rsp END AS i_gnr_sgn_frc_rsp,
   CASE WHEN i_fnt_sgn_str_oxg ISNULL THEN -99 ELSE i_fnt_sgn_str_oxg END AS i_gnr_sgn_str_oxg,
   CASE WHEN r_fnt_sgn_tpr ISNULL THEN -99 ELSE r_fnt_sgn_tpr END AS r_gnr_sgn_tpr,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1,2,3,4
ORDER BY 1 DESC;

---> READ: preguntas
SELECT 
   s_fnt_prs_qst_dsc,
   CASE WHEN s_fnt_prs_qst_dsc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = ' ' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '1' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '2' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '3' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_dsc))
   END AS s_gnr_prs_qst_dsc,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
   s_fnt_prs_qst_cse,
   CASE WHEN s_fnt_prs_qst_cse ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_cse = 'S' THEN 'SI'
        WHEN s_fnt_prs_qst_cse = 'HatenidocontactoconuncasoconocidodeCOVID19probableoconfirmado' THEN 'SI'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_cse))
   END AS s_gnr_prs_qst_cse,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 2 DESC;


SELECT 
   s_fnt_prs_qst_snt,
   CASE WHEN s_fnt_prs_qst_snt ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_snt = 'SINTOMÁTICO' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOMATICI' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOMATICA' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOMAS' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOM_TICO' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SI' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'ASINTOMÁTICO' THEN 'ASINTOMATICO'
   ELSE btrim(upper(s_fnt_prs_qst_snt))
   END AS s_gnr_prs_qst_snt,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_qst_dgn,
   CASE WHEN s_fnt_prs_qst_dgn ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = ' ' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44383' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44382' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44381' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44380' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44379' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44378' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44377' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44375' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44348' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44229' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_dgn)) 
   END s_gnr_prs_qst_dgn,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;


SELECT 
   s_fnt_prs_qst_ifc,
   CASE WHEN s_fnt_prs_qst_ifc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '1/27/1900' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2/2/1900' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '0999462938 ASIST.' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2118103' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2607700' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2666189' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2911054' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3682562' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3097473' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3084767' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3084268' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3074416' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3036546' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '997743959' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '995034093' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '994423889' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '991384737' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '983911618' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '982807786' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '979404682' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_ifc)) 
   END AS s_gnr_prs_qst_ifc,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

---> READ: SINTOMAS
SELECT 
   s_fnt_prs_snt_fbr,
   CASE WHEN s_fnt_prs_snt_fbr ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_fbr)) 
   END AS s_gnr_prs_snt_fbr,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_gst_olf,
   CASE WHEN s_fnt_prs_snt_gst_olf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_gst_olf ='SIO' THEN 'SI'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_gst_olf)) 
   END AS s_gnr_prs_snt_gst_olf,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_tos,
   CASE WHEN s_fnt_prs_snt_tos ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_tos ='AI' THEN 'SI'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_tos)) 
   END AS s_gnr_prs_snt_tos,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_dsn ,
   CASE WHEN s_fnt_prs_snt_dsn ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dsn)) 
   END AS s_gnr_prs_snt_dsn,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_dlr_grg,
   CASE WHEN s_fnt_prs_snt_dlr_grg ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dlr_grg)) 
   END AS s_gnr_prs_snt_dlr_grg,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_dlr_nse_vmt ,
   CASE WHEN s_fnt_prs_snt_dlr_nse_vmt ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr_nse_vmt = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dlr_nse_vmt)) 
   END AS s_gnr_prs_snt_nse_vmt,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_drr ,
   CASE WHEN s_fnt_prs_snt_drr ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_drr)) 
   END AS s_gnr_prs_snt_drr,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_esc,
   CASE WHEN s_fnt_prs_snt_esc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_esc = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_esc)) 
   END AS s_gnr_prs_snt_esc,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_cnf,
   CASE WHEN s_fnt_prs_snt_cnf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cnf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_cnf)) 
   END AS s_gnr_prs_snt_cnf,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_snt_dlr ,
   CASE WHEN s_fnt_prs_snt_dlr ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '135453684' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '135220247' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '133496559' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '133147206' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '133140273' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132781030' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132774809' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132764695' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132762302' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132701232' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132329994' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132271360' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dlr)) 
   END AS s_gnr_prs_snt_dlr,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;


SELECT 
   s_fnt_prs_snt_cns ,
   CASE WHEN s_fnt_prs_snt_cns ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'EA7AD808-51FC-48FC-91C5-EBD072C19279' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'C0CBE245-117F-46AB-92A4-C06254A04D15' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'B2F91E4C-8C74-425C-9004-536051D628A1' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'AB6B8980-88CB-4A39-BA78-61A1CE420827' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '886DFA62-408D-45F4-A011-F06CFE62AA8C' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '71D13275-0BD3-4D79-B618-7DBC627B7694' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '4CB75EEE-2F95-4B48-9B03-0A19878FD58C' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '4B98E948-32C3-4C0F-B711-44DC53B6496A' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '49E6A5A8-877A-431D-B160-373C7963C2BF' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '327EE35F-BC83-4BA0-81D6-35C699E707EC' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '2FE2360F-3495-433C-BAD3-719F0ADF1399' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '0503C3E7-F80C-43D0-83CB-E44B830569B6' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_cns)) 
   END AS s_cnr_prs_snt_cns,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

---> READ: Comorbilidad

SELECT 
   s_fnt_prs_qst_cmb ,
   CASE WHEN s_fnt_prs_qst_cmb ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_cmb = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_cmb)) 
   END AS s_gnr_prs_qst_cmb,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_cmb_enf_crd_vsc,
   CASE WHEN s_fnt_prs_cmb_enf_crd_vsc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-11-06T14:23:50' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-11-05T14:00:15' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-29T15:53:37' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-28T14:31:30' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-28T14:18:54' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T16:27:00' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T16:12:20' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T15:52:25' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T15:46:56' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T14:04:16' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-26T15:26:57' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-26T13:29:24' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_crd_vsc)) 
   END AS s_gnr_prs_cmb_enf_crd_vsc,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;


SELECT 
   s_fnt_prs_cmb_dbt ,
   CASE WHEN s_fnt_prs_cmb_dbt ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_dbt = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_dbt)) 
   END AS s_gnr_prs_cmb_dbt,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_cmb_hpr ,
   CASE WHEN s_fnt_prs_cmb_hpr ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '9104' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8343' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8316' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8045' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8025' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7989' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7975' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7682' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7315' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7121' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '11037' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '11037' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '10435' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_hpr)) 
   END AS s_gnr_prs_cmb_hpr,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;


SELECT 
   s_fnt_prs_cmb_obs_svr ,
   CASE WHEN s_fnt_prs_cmb_obs_svr ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_obs_svr = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_obs_svr)) 
   END AS s_gnr_prs_cmb_obs_svr,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_cmb_enf_rnl_isf ,
   CASE WHEN s_fnt_prs_cmb_enf_rnl_isf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_rnl_isf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_rnl_isf)) 
   END AS s_gnr_prs_cmb_enf_rnl_isf,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_cmb_enf_hpt_isf ,
   CASE WHEN s_fnt_prs_cmb_enf_hpt_isf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_hpt_isf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_hpt_isf)) 
   END AS s_gnr_prs_cmb_enf_hpt_isf,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
   s_fnt_prs_cmb_enf_plm_asm ,
   CASE WHEN s_fnt_prs_cmb_enf_plm_asm ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_plm_asm = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_plm_asm)) 
   END AS s_gnr_prs_cmb_enf_plm_asm,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

---> READ: unidad que notifica

SELECT 
   s_fnt_unt_ntf ,
   CASE WHEN s_fnt_unt_ntf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_unt_ntf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_unt_ntf)) 
   END AS s_gnr_unt_ntf,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;


---> READ: embarazo
SELECT 
   s_fnt_prs_emb ,
   CASE WHEN s_fnt_prs_emb ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'X=' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'X' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'TUNGURAHUA - AMBATO' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'SANTO DOMINGO' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'SAN JUAN' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'RIOBAMBA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'PASTAZA - PUYO- SANTA CLARA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'ORIENTE' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'NO APLICA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'NINGUNO' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'NINGUNA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'N/A' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'IBARRA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = '-' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_emb)) 
   END AS s_gnr_prs_emb,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;


SELECT 
   s_fnt_prs_emb_nmb ,
   CASE WHEN s_fnt_prs_emb_nmb ISNULL THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '#NULL!' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '-' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'SI' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NO APLICA' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'X' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NO' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NINGUNO' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NINGUNA' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'N/A' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '8 SEMANAS' THEN '8'
        WHEN s_fnt_prs_emb_nmb = '36,1' THEN '36'
        WHEN s_fnt_prs_emb_nmb = '24 SEM' THEN '24'       
        WHEN s_fnt_prs_emb_nmb ILIKE '%/%' THEN '-99'        
   ELSE BTRIM(UPPER(s_fnt_prs_emb_nmb)) 
   END::SMALLINT AS i_gnr_prs_emb_nmb,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 DESC;

---> READ: Laboratorio


SELECT 
   d_fnt_prs_dte_att,
   s_fnt_lbr_nme,
   s_fnt_smp_rsl,
   CASE WHEN d_fnt_prs_dte_att BETWEEN '2021-01-01' AND '2021-05-07' AND s_fnt_smp_rsl NOTNULL THEN 'PUCE'
        WHEN d_fnt_prs_dte_att BETWEEN '2021-05-20' AND '2021-10-07' AND s_fnt_smp_rsl NOTNULL THEN 'ANTIGENO'
        WHEN d_fnt_prs_dte_att BETWEEN '2021-01-01' AND '2021-05-07' AND s_fnt_smp_rsl ISNULL THEN 'ATENCION'
        WHEN d_fnt_prs_dte_att BETWEEN '2021-05-20' AND '2021-10-07' AND s_fnt_smp_rsl ISNULL THEN 'ATENCION'
        WHEN s_fnt_lbr_nme ISNULL AND s_fnt_smp_rsl ISNULL THEN 'ATENCION'
   ELSE BTRIM(UPPER(s_fnt_lbr_nme)) 
   END AS s_gnr_lbr_nme,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1,2,3
ORDER BY 1 ASC;
---> READ: Tipo de muestra
SELECT 
   s_fnt_smp_tpe,
   CASE WHEN s_fnt_smp_tpe ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_smp_tpe = 'H.N.' THEN 'HISOPADO NASOFARINGEO'
   ELSE btrim(upper(s_fnt_smp_tpe))
   END s_gnr_smp_tpe,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1
ORDER BY 1 ASC;


--->READ: Fecha de toma

CREATE OR REPLACE FUNCTION dta_uio.d_dte_tke(s_fnt_smp_dte_tke text)
 RETURNS date
 LANGUAGE plpgsql
AS $function$ 
DECLARE
d_dte date;
BEGIN
d_dte := (SELECT
  ((CASE WHEN split_part(s_fnt_smp_dte_tke,'-',3)::integer > 1000  THEN split_part(s_fnt_smp_dte_tke,'-',3)::integer
  ELSE split_part(s_fnt_smp_dte_tke,'-',1)::integer
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_smp_dte_tke,'-',2)::integer > 12  THEN split_part(s_fnt_smp_dte_tke,'-',1)::integer 
  ELSE split_part(s_fnt_smp_dte_tke,'-',2)::integer
  END)::TEXT||'-'||
  (CASE WHEN split_part(s_fnt_smp_dte_tke,'-',3)::integer < 1000 THEN split_part(s_fnt_smp_dte_tke,'-',3)::integer
       WHEN split_part(s_fnt_smp_dte_tke,'-',2)::integer > 12 THEN split_part(s_fnt_smp_dte_tke,'-',2)::integer
  ELSE split_part(s_fnt_smp_dte_tke,'-',1)::integer
  END))::date); 
RETURN d_dte;
END;
$function$
;

SELECT dta_uio.d_dte_tke('01-10-2021');

SELECT 
   d_fnt_prs_dte_att,
   s_fnt_smp_dte_tke,
   s_fnt_smp_rsl,
   (REPLACE(CASE WHEN s_fnt_smp_dte_tke ISNULL AND s_fnt_smp_rsl IS NULL THEN '1900-01-01' WHEN s_fnt_smp_dte_tke ISNULL THEN d_fnt_prs_dte_att::TEXT 
        WHEN length(btrim(s_fnt_smp_dte_tke)) BETWEEN 8 AND 9 THEN d_fnt_prs_dte_att::TEXT WHEN s_fnt_smp_dte_tke ILIKE '%Sep%' THEN REPLACE(s_fnt_smp_dte_tke,'Sep','09')
        WHEN s_fnt_smp_dte_tke ILIKE '%May%' THEN REPLACE(s_fnt_smp_dte_tke,'May','05') WHEN s_fnt_smp_dte_tke ILIKE '%Aug%' THEN REPLACE(s_fnt_smp_dte_tke,'Aug','08')
        WHEN s_fnt_smp_dte_tke ILIKE '%Jan%' THEN REPLACE(s_fnt_smp_dte_tke,'Jan','01') WHEN s_fnt_smp_rsl NOTNULL THEN (CASE WHEN length(s_fnt_smp_dte_tke)> 10 THEN LEFT(s_fnt_smp_dte_tke,10) ELSE s_fnt_smp_dte_tke END)  
   ELSE s_fnt_smp_dte_tke END,'/','-')),
   dta_uio.d_dte_tke((REPLACE(CASE WHEN s_fnt_smp_dte_tke ISNULL AND s_fnt_smp_rsl IS NULL THEN '1900-01-01' WHEN s_fnt_smp_dte_tke ISNULL THEN d_fnt_prs_dte_att::TEXT 
        WHEN length(btrim(s_fnt_smp_dte_tke)) BETWEEN 8 AND 9 THEN d_fnt_prs_dte_att::TEXT WHEN s_fnt_smp_dte_tke ILIKE '%Sep%' THEN REPLACE(s_fnt_smp_dte_tke,'Sep','09')
        WHEN s_fnt_smp_dte_tke ILIKE '%May%' THEN REPLACE(s_fnt_smp_dte_tke,'May','05') WHEN s_fnt_smp_dte_tke ILIKE '%Aug%' THEN REPLACE(s_fnt_smp_dte_tke,'Aug','08')
        WHEN s_fnt_smp_dte_tke ILIKE '%Jan%' THEN REPLACE(s_fnt_smp_dte_tke,'Jan','01') WHEN s_fnt_smp_rsl NOTNULL THEN (CASE WHEN length(s_fnt_smp_dte_tke)> 10 THEN LEFT(s_fnt_smp_dte_tke,10) ELSE s_fnt_smp_dte_tke END)  
   ELSE s_fnt_smp_dte_tke END,'/','-'))) AS d_gnr_smp_dte_tke,
   count(*)
FROM dta_uio.data_gnr
GROUP BY 1,2,3
ORDER BY 4 DESC ;


--->READ: parametro
SELECT 
s_fnt_smp_prm,
s_fnt_smp_rsl,
CASE WHEN s_fnt_smp_prm ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_smp_prm = '0' THEN 'SE DESCONOCE'
     WHEN s_fnt_smp_prm = 'ANTIGENOS' THEN 'ANTIGENO'
     WHEN s_fnt_smp_prm = 'COVID-19 PCR' THEN 'RT-PCR --> SARS-CoV-2'
     WHEN s_fnt_smp_prm = 'DETECCION DE SARS COV 2 POR PCR EN TIEMPO REAL' THEN 'RT-PCR --> SARS-CoV-2'
     WHEN s_fnt_smp_prm = 'DETECCIÓN DE SARS COV 2 POR PCR EN TIEMPO REAL' THEN 'RT-PCR --> SARS-CoV-2'
     WHEN s_fnt_smp_prm = 'GEN RDRP' THEN 'RT-PCR --> SARS-CoV-2 (GEN RDRP)'
     WHEN s_fnt_smp_prm = 'GEN ORF1AB' THEN 'RT-PCR --> SARS-CoV-2 (GEN ORF1AB)'
     WHEN s_fnt_smp_prm = 'GEN ORF1A' THEN 'RT-PCR --> SARS-CoV-2 (GEN ORF1A)'
     WHEN s_fnt_smp_prm = 'GEN E' THEN 'RT-PCR --> SARS-CoV-2 (GEN E)'
     WHEN s_fnt_smp_prm = 'GEN N' THEN 'RT-PCR --> SARS-CoV-2 (GEN N)'
ELSE BTRIM(UPPER(s_fnt_smp_prm))
END AS s_gnr_smp_prm, 
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1,2
ORDER BY 1;

--->READ: resultado
SELECT 
s_fnt_smp_rsl,
CASE WHEN s_fnt_smp_rsl ISNULL THEN 'ATENCION'
ELSE s_fnt_smp_rsl
END AS s_gnr_smp_rsl,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_smp_igm ,
CASE WHEN s_fnt_smp_igm ISNULL THEN 'ATENCION'
     WHEN s_fnt_smp_igm ILIKE '%@%' THEN 'ATENCION'
     WHEN s_fnt_smp_igm ILIKE '%SARS-COV-2RAPID ANTIGEN TEST%' THEN 'ATENCION'
     WHEN s_fnt_smp_igm ILIKE '%NO TIENE%' THEN 'NEGATIVO'
ELSE s_fnt_smp_igm
END AS s_gnr_smp_igm,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_smp_igg ,
CASE WHEN s_fnt_smp_igg ISNULL THEN 'ATENCION'
     WHEN s_fnt_smp_igg ILIKE '%/%' THEN 'ATENCION'
     WHEN s_fnt_smp_igg ILIKE '%-%' THEN 'ATENCION'
     WHEN s_fnt_smp_igg ILIKE '%NO TIENE%' THEN 'NEGATIVO'
     WHEN s_fnt_smp_igg ILIKE '%9%' THEN 'ATENCION'
ELSE s_fnt_smp_igg
END AS s_gnr_smp_igg,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_eml ,
CASE WHEN s_fnt_prs_eml ISNULL THEN 'SE DESCONOCE'
ELSE btrim(lower(s_fnt_prs_eml))
END AS s_gnr_prs_eml,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_01,
CASE WHEN s_fnt_prs_enc_01 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_01))
END AS s_gnr_prs_enc_01,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_02,
CASE WHEN s_fnt_prs_enc_02 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_02))
END AS s_gnr_prs_enc_02,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_03,
CASE WHEN s_fnt_prs_enc_03 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_03))
END AS s_gnr_prs_enc_03,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_04,
CASE WHEN s_fnt_prs_enc_04 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_04))
END AS s_gnr_prs_enc_04,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_05,
CASE WHEN s_fnt_prs_enc_05 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_05))
END AS s_gnr_prs_enc_05,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_06,
CASE WHEN s_fnt_prs_enc_06 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_06))
END AS s_gnr_prs_enc_06,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_enc_07,
CASE WHEN s_fnt_prs_enc_07 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_07))
END AS s_gnr_prs_enc_07,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_asl ,
CASE WHEN s_fnt_prs_asl ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_asl))
END AS s_gnr_prs_asl,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

SELECT 
s_fnt_prs_rsp_lnd ,
CASE WHEN s_fnt_prs_rsp_lnd ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '0' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '06' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '10' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '16' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '18' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '20' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '31' THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_rsp_lnd))
END AS s_gnr_prs_rsp_lnd,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;
---> READ: detalle discapacidad
SELECT 
s_fnt_prs_dtl ,
CASE WHEN s_fnt_prs_dtl ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_dtl = '' THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_dtl))
END AS s_gnr_prs_dsc_dtl,
Count(*)
FROM dta_uio.data_gnr 
GROUP BY 1
ORDER BY 1;

---> READ: Construir consulta actualizada
DROP MATERIALIZED VIEW dta_uio.uio_data_gnr;
CREATE MATERIALIZED VIEW dta_uio.uio_data_gnr AS 
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
  dta_uio.s_trv_qst(s_fnt_prs_trv) AS s_gnr_prs_trv_qst,
  ((CASE WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT > 1000  THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT
  ELSE split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',1)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT > 12  THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',1)::SMALLINT 
  ELSE split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT
  END)::TEXT||'-'||
  (CASE WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT < 1000 THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',3)::SMALLINT
       WHEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT > 12 THEN split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',2)::SMALLINT
  ELSE split_part(btrim(REPLACE(dta_uio.d_trv_qst(s_fnt_prs_trv_dte, s_fnt_prs_trv_ste),'/','-')),'-',1)::SMALLINT
  END))::date AS d_gnr_prs_trv_dte,
  (CASE WHEN s_fnt_prs_trv_ste = '' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '-' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '#######' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = ' ' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '6' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '13' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '24' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-07-04' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-07-03' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-07-01' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-06-30' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-06-25' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_trv_ste = '2021-05-03' THEN 'SE DESCONOCE'
  ELSE BTRIM(UPPER(s_fnt_prs_trv_ste))
  END) AS s_gnr_prs_trv_ste,
  CASE WHEN s_fnt_sgn_prs_stl='' THEN -99
     WHEN s_fnt_sgn_prs_stl ISNULL THEN -99
     WHEN s_fnt_sgn_prs_stl='143-' THEN 143
     WHEN s_fnt_sgn_prs_stl='10p' THEN 100
     WHEN s_fnt_sgn_prs_stl='130 0' THEN 130
     WHEN s_fnt_sgn_prs_stl='13q' THEN 130
     WHEN s_fnt_sgn_prs_stl='1p2' THEN 100
     WHEN s_fnt_sgn_prs_stl='126 5' THEN 126
     WHEN s_fnt_sgn_prs_stl='1p0' THEN 100
     WHEN s_fnt_sgn_prs_stl='14q' THEN 140
     WHEN s_fnt_sgn_prs_stl='13r' THEN 130
     WHEN s_fnt_sgn_prs_stl='109t76' THEN 109
     WHEN s_fnt_sgn_prs_stl='100}' THEN 100
     WHEN s_fnt_sgn_prs_stl='12p' THEN 120
     WHEN length(s_fnt_sgn_prs_stl)>3 THEN left(s_fnt_sgn_prs_stl,3)::SMALLINT
ELSE s_fnt_sgn_prs_stl::integer
END AS i_gnr_sgn_prs_stl,
CASE WHEN s_fnt_sgn_prs_dst='' THEN -99
     WHEN s_fnt_sgn_prs_dst ISNULL THEN -99
     WHEN s_fnt_sgn_prs_dst = '6(' THEN 60
     WHEN s_fnt_sgn_prs_dst = '8)' THEN 80
     WHEN s_fnt_sgn_prs_dst = '8''' THEN 80
     WHEN s_fnt_sgn_prs_dst = '7(' THEN 70
     WHEN s_fnt_sgn_prs_dst = '(72' THEN 72
     WHEN s_fnt_sgn_prs_dst = '(7' THEN 70
     WHEN s_fnt_sgn_prs_dst = '7,' THEN 70
     WHEN s_fnt_sgn_prs_dst = '(1' THEN 10
     WHEN s_fnt_sgn_prs_dst = '72.' THEN 72
     WHEN s_fnt_sgn_prs_dst = '&80' THEN 80
     WHEN s_fnt_sgn_prs_dst = '70mw' THEN 70
     WHEN s_fnt_sgn_prs_dst = '8O' THEN 80
     WHEN s_fnt_sgn_prs_dst = '6O' THEN 60
     WHEN s_fnt_sgn_prs_dst = '7O' THEN 70
     WHEN s_fnt_sgn_prs_dst = 'L75' THEN 75
     WHEN s_fnt_sgn_prs_dst = '£0' THEN -99
     WHEN s_fnt_sgn_prs_dst = '6)' THEN 60
     WHEN s_fnt_sgn_prs_dst = '84!' THEN 84
     WHEN s_fnt_sgn_prs_dst = '8£' THEN 83
     WHEN s_fnt_sgn_prs_dst = '78¿7' THEN 78
     WHEN s_fnt_sgn_prs_dst = '68|' THEN 68
     WHEN s_fnt_sgn_prs_dst = '8(' THEN 80
     WHEN s_fnt_sgn_prs_dst = '*97' THEN 97
     WHEN s_fnt_sgn_prs_dst = '&4' THEN 84
     WHEN s_fnt_sgn_prs_dst = '7)' THEN 70
     WHEN s_fnt_sgn_prs_dst = '6$' THEN 65
     WHEN substring(s_fnt_sgn_prs_dst from 1 for 1) = '7' AND length(s_fnt_sgn_prs_dst)>2 THEN RIGHT(s_fnt_sgn_prs_dst,2)::SMALLINT
     WHEN length(s_fnt_sgn_prs_dst) > 2 AND s_fnt_sgn_prs_dst::integer > 120 THEN RIGHT(s_fnt_sgn_prs_dst,2)::SMALLINT
ELSE s_fnt_sgn_prs_dst::integer
END AS i_gnr_sgn_prs_dst,
CASE WHEN i_fnt_sgn_frc_crd ISNULL THEN -99 ELSE i_fnt_sgn_frc_crd END AS i_gnr_sgn_frc_crd,
CASE WHEN i_fnt_sgn_frc_rsp ISNULL THEN -99 ELSE i_fnt_sgn_frc_rsp END AS i_gnr_sgn_frc_rsp,
CASE WHEN i_fnt_sgn_str_oxg ISNULL THEN -99 ELSE i_fnt_sgn_str_oxg END AS i_gnr_sgn_str_oxg,
CASE WHEN r_fnt_sgn_tpr ISNULL THEN -99 ELSE r_fnt_sgn_tpr END AS r_gnr_sgn_tpr,
CASE WHEN s_fnt_prs_qst_dsc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = ' ' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '1' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '2' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dsc = '3' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_dsc))
   END AS s_gnr_prs_qst_dsc,
CASE WHEN s_fnt_prs_dtl ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_dtl = '' THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_dtl))
END AS s_gnr_prs_dsc_dtl,
CASE WHEN s_fnt_prs_qst_cse ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_cse = 'S' THEN 'SI'
        WHEN s_fnt_prs_qst_cse = 'HatenidocontactoconuncasoconocidodeCOVID19probableoconfirmado' THEN 'SI'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_cse))
   END AS s_gnr_prs_qst_cse,
CASE WHEN s_fnt_prs_qst_snt ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_snt = 'SINTOMÁTICO' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOMATICI' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOMATICA' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOMAS' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SINTOM_TICO' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'SI' THEN 'SINTOMATICO'
        WHEN s_fnt_prs_qst_snt = 'ASINTOMÁTICO' THEN 'ASINTOMATICO'
   ELSE btrim(upper(s_fnt_prs_qst_snt))
   END AS s_gnr_prs_qst_snt,
CASE WHEN s_fnt_prs_qst_dgn ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = ' ' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44383' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44382' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44381' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44380' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44379' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44378' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44377' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44375' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44348' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_dgn = '44229' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_dgn)) 
   END s_gnr_prs_qst_dgn,
CASE WHEN s_fnt_prs_qst_ifc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '1/27/1900' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2/2/1900' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '0999462938 ASIST.' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2118103' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2607700' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2666189' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '2911054' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3682562' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3097473' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3084767' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3084268' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3074416' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '3036546' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '997743959' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '995034093' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '994423889' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '991384737' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '983911618' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '982807786' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_ifc = '979404682' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_ifc)) 
   END AS s_gnr_prs_qst_ifc,
CASE WHEN s_fnt_prs_snt_fbr ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_fbr)) 
   END AS s_gnr_prs_snt_fbr,
CASE WHEN s_fnt_prs_snt_gst_olf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_gst_olf ='SIO' THEN 'SI'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_gst_olf)) 
   END AS s_gnr_prs_snt_gst_olf,
CASE WHEN s_fnt_prs_snt_tos ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_tos ='AI' THEN 'SI'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_tos)) 
   END AS s_gnr_prs_snt_tos,
CASE WHEN s_fnt_prs_snt_dsn ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dsn)) 
   END AS s_gnr_prs_snt_dsn,
CASE WHEN s_fnt_prs_snt_dlr_grg ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dlr_grg)) 
   END AS s_gnr_prs_snt_dlr_grg,
CASE WHEN s_fnt_prs_snt_dlr_nse_vmt ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr_nse_vmt = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dlr_nse_vmt)) 
   END AS s_gnr_prs_snt_nse_vmt,
CASE WHEN s_fnt_prs_snt_drr ISNULL THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_drr)) 
   END AS s_gnr_prs_snt_drr,
CASE WHEN s_fnt_prs_snt_esc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_esc = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_esc)) 
   END AS s_gnr_prs_snt_esc,
CASE WHEN s_fnt_prs_snt_cnf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cnf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_cnf)) 
   END AS s_gnr_prs_snt_cnf,
CASE WHEN s_fnt_prs_snt_dlr ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '135453684' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '135220247' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '133496559' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '133147206' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '133140273' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132781030' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132774809' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132764695' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132762302' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132701232' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132329994' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_dlr = '132271360' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_dlr)) 
   END AS s_gnr_prs_snt_dlr,
CASE WHEN s_fnt_prs_snt_cns ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'EA7AD808-51FC-48FC-91C5-EBD072C19279' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'C0CBE245-117F-46AB-92A4-C06254A04D15' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'B2F91E4C-8C74-425C-9004-536051D628A1' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = 'AB6B8980-88CB-4A39-BA78-61A1CE420827' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '886DFA62-408D-45F4-A011-F06CFE62AA8C' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '71D13275-0BD3-4D79-B618-7DBC627B7694' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '4CB75EEE-2F95-4B48-9B03-0A19878FD58C' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '4B98E948-32C3-4C0F-B711-44DC53B6496A' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '49E6A5A8-877A-431D-B160-373C7963C2BF' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '327EE35F-BC83-4BA0-81D6-35C699E707EC' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '2FE2360F-3495-433C-BAD3-719F0ADF1399' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_snt_cns = '0503C3E7-F80C-43D0-83CB-E44B830569B6' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_snt_cns)) 
   END AS s_cnr_prs_snt_cns,
CASE WHEN s_fnt_prs_qst_cmb ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_qst_cmb = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_qst_cmb)) 
   END AS s_gnr_prs_qst_cmb,
CASE WHEN s_fnt_prs_cmb_enf_crd_vsc ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-11-06T14:23:50' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-11-05T14:00:15' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-29T15:53:37' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-28T14:31:30' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-28T14:18:54' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T16:27:00' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T16:12:20' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T15:52:25' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T15:46:56' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-27T14:04:16' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-26T15:26:57' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_crd_vsc = '2020-10-26T13:29:24' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_crd_vsc)) 
   END AS s_gnr_prs_cmb_enf_crd_vsc,
CASE WHEN s_fnt_prs_cmb_dbt ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_dbt = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_dbt)) 
   END AS s_gnr_prs_cmb_dbt,
CASE WHEN s_fnt_prs_cmb_hpr ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '9104' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8343' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8316' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8045' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '8025' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7989' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7975' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7682' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7315' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '7121' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '11037' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '11037' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_hpr = '10435' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_hpr)) 
   END AS s_gnr_prs_cmb_hpr,
CASE WHEN s_fnt_prs_cmb_obs_svr ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_obs_svr = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_obs_svr)) 
   END AS s_gnr_prs_cmb_obs_svr,
CASE WHEN s_fnt_prs_cmb_enf_rnl_isf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_rnl_isf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_rnl_isf)) 
   END AS s_gnr_prs_cmb_enf_rnl_isf,
CASE WHEN s_fnt_prs_cmb_enf_hpt_isf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_hpt_isf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_hpt_isf)) 
   END AS s_gnr_prs_cmb_enf_hpt_isf,
CASE WHEN s_fnt_prs_cmb_enf_plm_asm ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_cmb_enf_plm_asm = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_cmb_enf_plm_asm)) 
   END AS s_gnr_prs_cmb_enf_plm_asm,
CASE WHEN s_fnt_unt_ntf ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_unt_ntf = '' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_unt_ntf)) 
   END AS s_gnr_unt_ntf,
CASE WHEN s_fnt_prs_emb ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = '' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'X=' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'X' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'TUNGURAHUA - AMBATO' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'SANTO DOMINGO' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'SAN JUAN' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'RIOBAMBA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'PASTAZA - PUYO- SANTA CLARA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'ORIENTE' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'NO APLICA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'NINGUNO' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'NINGUNA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'N/A' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = 'IBARRA' THEN 'SE DESCONOCE'
        WHEN s_fnt_prs_emb = '-' THEN 'SE DESCONOCE'
   ELSE BTRIM(UPPER(s_fnt_prs_emb)) 
   END AS s_gnr_prs_emb,
CASE WHEN s_fnt_prs_emb_nmb ISNULL THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '#NULL!' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '-' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'SI' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NO APLICA' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'X' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NO' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NINGUNO' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'NINGUNA' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = 'N/A' THEN '-99'
        WHEN s_fnt_prs_emb_nmb = '8 SEMANAS' THEN '8'
        WHEN s_fnt_prs_emb_nmb = '36,1' THEN '36'
        WHEN s_fnt_prs_emb_nmb = '24 SEM' THEN '24'       
        WHEN s_fnt_prs_emb_nmb ILIKE '%/%' THEN '-99'        
   ELSE BTRIM(UPPER(s_fnt_prs_emb_nmb)) 
   END::SMALLINT AS i_gnr_prs_emb_nmb,
CASE WHEN d_fnt_prs_dte_att BETWEEN '2021-01-01' AND '2021-05-07' AND s_fnt_smp_rsl NOTNULL THEN 'PUCE'
        WHEN d_fnt_prs_dte_att BETWEEN '2021-05-20' AND '2021-10-07' AND s_fnt_smp_rsl NOTNULL THEN 'ANTIGENO'
        WHEN d_fnt_prs_dte_att BETWEEN '2021-01-01' AND '2021-05-07' AND s_fnt_smp_rsl ISNULL THEN 'ATENCION'
        WHEN d_fnt_prs_dte_att BETWEEN '2021-05-20' AND '2021-10-07' AND s_fnt_smp_rsl ISNULL THEN 'ATENCION'
        WHEN s_fnt_lbr_nme ISNULL AND s_fnt_smp_rsl ISNULL THEN 'ATENCION'
   ELSE BTRIM(UPPER(s_fnt_lbr_nme)) 
   END AS s_gnr_lbr_nme,
CASE WHEN s_fnt_smp_tpe ISNULL THEN 'SE DESCONOCE'
        WHEN s_fnt_smp_tpe = 'H.N.' THEN 'HISOPADO NASOFARINGEO'
   ELSE btrim(upper(s_fnt_smp_tpe))
   END s_gnr_smp_tpe,
dta_uio.d_dte_tke((REPLACE(CASE WHEN s_fnt_smp_dte_tke ISNULL AND s_fnt_smp_rsl IS NULL THEN '1900-01-01' WHEN s_fnt_smp_dte_tke ISNULL THEN d_fnt_prs_dte_att::TEXT 
        WHEN length(btrim(s_fnt_smp_dte_tke)) BETWEEN 8 AND 9 THEN d_fnt_prs_dte_att::TEXT WHEN s_fnt_smp_dte_tke ILIKE '%Sep%' THEN REPLACE(s_fnt_smp_dte_tke,'Sep','09')
        WHEN s_fnt_smp_dte_tke ILIKE '%May%' THEN REPLACE(s_fnt_smp_dte_tke,'May','05') WHEN s_fnt_smp_dte_tke ILIKE '%Aug%' THEN REPLACE(s_fnt_smp_dte_tke,'Aug','08')
        WHEN s_fnt_smp_dte_tke ILIKE '%Jan%' THEN REPLACE(s_fnt_smp_dte_tke,'Jan','01') WHEN s_fnt_smp_rsl NOTNULL THEN (CASE WHEN length(s_fnt_smp_dte_tke)> 10 THEN LEFT(s_fnt_smp_dte_tke,10) ELSE s_fnt_smp_dte_tke END)  
   ELSE s_fnt_smp_dte_tke END,'/','-'))) AS d_gnr_smp_dte_tke,
CASE WHEN s_fnt_smp_prm ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_smp_prm = '0' THEN 'SE DESCONOCE'
     WHEN s_fnt_smp_prm = 'ANTIGENOS' THEN 'ANTIGENO'
     WHEN s_fnt_smp_prm = 'COVID-19 PCR' THEN 'RT-PCR --> SARS-CoV-2'
     WHEN s_fnt_smp_prm = 'DETECCION DE SARS COV 2 POR PCR EN TIEMPO REAL' THEN 'RT-PCR --> SARS-CoV-2'
     WHEN s_fnt_smp_prm = 'DETECCIÓN DE SARS COV 2 POR PCR EN TIEMPO REAL' THEN 'RT-PCR --> SARS-CoV-2'
     WHEN s_fnt_smp_prm = 'GEN RDRP' THEN 'RT-PCR --> SARS-CoV-2 (GEN RDRP)'
     WHEN s_fnt_smp_prm = 'GEN ORF1AB' THEN 'RT-PCR --> SARS-CoV-2 (GEN ORF1AB)'
     WHEN s_fnt_smp_prm = 'GEN ORF1A' THEN 'RT-PCR --> SARS-CoV-2 (GEN ORF1A)'
     WHEN s_fnt_smp_prm = 'GEN E' THEN 'RT-PCR --> SARS-CoV-2 (GEN E)'
     WHEN s_fnt_smp_prm = 'GEN N' THEN 'RT-PCR --> SARS-CoV-2 (GEN N)'
ELSE BTRIM(UPPER(s_fnt_smp_prm))
END AS s_gnr_smp_prm, 
CASE WHEN s_fnt_smp_rsl ISNULL THEN 'ATENCION'
ELSE s_fnt_smp_rsl
END AS s_gnr_smp_rsl,
CASE WHEN s_fnt_smp_igm ISNULL THEN 'ATENCION'
     WHEN s_fnt_smp_igm ILIKE '%@%' THEN 'ATENCION'
     WHEN s_fnt_smp_igm ILIKE '%SARS-COV-2RAPID ANTIGEN TEST%' THEN 'ATENCION'
     WHEN s_fnt_smp_igm ILIKE '%NO TIENE%' THEN 'NEGATIVO'
ELSE s_fnt_smp_igm
END AS s_gnr_smp_igm,
CASE WHEN s_fnt_smp_igg ISNULL THEN 'ATENCION'
     WHEN s_fnt_smp_igg ILIKE '%/%' THEN 'ATENCION'
     WHEN s_fnt_smp_igg ILIKE '%-%' THEN 'ATENCION'
     WHEN s_fnt_smp_igg ILIKE '%NO TIENE%' THEN 'NEGATIVO'
     WHEN s_fnt_smp_igg ILIKE '%9%' THEN 'ATENCION'
ELSE s_fnt_smp_igg
END AS s_gnr_smp_igg,
CASE WHEN s_fnt_prs_eml ISNULL THEN 'SE DESCONOCE'
ELSE btrim(lower(s_fnt_prs_eml))
END AS s_gnr_prs_eml,
CASE WHEN s_fnt_prs_enc_01 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_01))
END AS s_gnr_prs_enc_01,
CASE WHEN s_fnt_prs_enc_02 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_02))
END AS s_gnr_prs_enc_02,
CASE WHEN s_fnt_prs_enc_03 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_03))
END AS s_gnr_prs_enc_03,
CASE WHEN s_fnt_prs_enc_04 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_04))
END AS s_gnr_prs_enc_04,
CASE WHEN s_fnt_prs_enc_05 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_05))
END AS s_gnr_prs_enc_05,
CASE WHEN s_fnt_prs_enc_06 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_06))
END AS s_gnr_prs_enc_06,
CASE WHEN s_fnt_prs_enc_07 ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_enc_07))
END AS s_gnr_prs_enc_07,
CASE WHEN s_fnt_prs_asl ISNULL THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_asl))
END AS s_gnr_prs_asl,
CASE WHEN s_fnt_prs_rsp_lnd ISNULL THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '0' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '06' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '10' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '16' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '18' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '20' THEN 'SE DESCONOCE'
     WHEN s_fnt_prs_rsp_lnd = '31' THEN 'SE DESCONOCE'
ELSE btrim(upper(s_fnt_prs_rsp_lnd))
END AS s_gnr_prs_rsp_lnd
FROM dta_uio.data_gnr
WHERE d_fnt_prs_dte_att NOTNULL 
ORDER BY 1,2,3;

SELECT * FROM dta_uio.uio_data_gnr LIMIT 10;


  
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
    t1.TABLE_SCHEMA = 'public' AND
    t1.TABLE_NAME = 'tst_ptt'
ORDER BY
t1.ORDINAL_POSITION;

SELECT * FROM PG_CLASS ORDER BY 2;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS ORDER BY 2,3;

SELECT * FROM information_schema.views WHERE table_name = 'uio_data_gnr';

SELECT view_definition
FROM information_schema.views
WHERE table_schema = 'dta_uio'
AND table_name = 'uio_data_gnr';

SELECT *
FROM materialized_views
WHERE table_schema = 'dta_uio'
AND table_name = 'uio_data_gnr';

SELECT view_definition
FROM information_schema."views" 
WHERE table_schema = 'public '
AND table_name = 'tst_ptt';
