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

CREATE MATERIALIZED VIEW dta_uio.dpa_qry_prq_uio AS 
SELECT 
  gid,
  upper(btrim(clave_parr::TEXT)) AS s_prq_cde,
  upper(btrim(nombre_par::TEXT)) AS s_prq_nme,
  upper(btrim(zonadminis::TEXT)) AS s_prq_zne_adm,
  upper(btrim(delegacion::TEXT)) AS s_prq_dlg,
  geom
FROM dta_uio.dpa_tbl_prq_uio dtpu;

DROP MATERIALIZED dta_uio.uio_qry_prq_pst_2021;
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

