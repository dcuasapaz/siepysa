-----------------------------------------------------------------------------------------------------------------------------------------------
-- DATA - 2021
-----------------------------------------------------------------------------------------------------------------------------------------------
--*******************************************************************************************************************************************--
-- Autor --> DC
-- Date--> 2021-10-21
-- Comment --> Inicio de depuracion de datos
--			   Consultas que ayuden a la presentacion              
--*******************************************************************************************************************************************--
---> READ: Consulta que me permite ver la temporalidad de la data en 2021
SELECT date_part('year',d_prs_dte_att) AS i_yr, 
       min(d_prs_dte_att) AS d_prs_dte_min_att, 
       max(d_prs_dte_att) AS d_prs_dte_max_att 
FROM dta_uio.data_2021_id GROUP BY 1 HAVING min(d_prs_dte_att) NOTNULL;
---> READ: Consulta que me permite ver el resumen de datos obtenidos de la data 2020
SELECT 
2021::SMALLINT AS i_yr, -- Anio
(SELECT count(*) FROM dta_uio.data_2021) AS i_ttl_ptt,
(SELECT count(*) FROM dta_uio.data_2021) - (SELECT count(*) FROM dta_uio.data_2021_gnr) AS i_ttl_ptt_dpl,
(SELECT count(*) FROM dta_uio.data_2021_gnr) AS i_ttl_ptt_dpl_no,
(WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_uio.dta_tbl_prs_idn_2021 GROUP BY 1) SELECT count(*) FROM tmp01) AS i_ttl_ptt_idn_vld,
(SELECT count(*) FROM dta_uio.data_2021) - (WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_uio.dta_tbl_prs_idn_2021 GROUP BY 1) SELECT count(*) FROM tmp01) AS i_ttl_ptt_idn_oth,
(WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_tbl_prs_dnr_2021 GROUP BY 1) SELECT count(*) FROM tmp01) AS i_ttl_ptt_idn_dnr_ok,
(WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_uio.dta_tbl_prs_idn_2021 GROUP BY 1) SELECT count(*) FROM tmp01) - 
(WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_tbl_prs_dnr_2021 GROUP BY 1) SELECT count(*) FROM tmp01) AS i_ttl_ptt_idn_dnr_error,
(SELECT count(*) FROM dta_uio.data_2021) - (WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_uio.dta_tbl_prs_idn_2021 GROUP BY 1) SELECT count(*) FROM tmp01) + 
(WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_uio.dta_tbl_prs_idn_2021 GROUP BY 1) SELECT count(*) FROM tmp01) - 
(WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_tbl_prs_dnr_2021 GROUP BY 1) SELECT count(*) FROM tmp01) AS i_ttl_ptt_vrf;


WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_uio.dta_tbl_prs_idn_2021 GROUP BY 1) SELECT count(*) FROM tmp01;
WITH tmp01 AS (SELECT s_prs_idn, Count(*) AS i_ttl_ptt_idn FROM dta_tbl_prs_dnr_2021 GROUP BY 1) SELECT count(*) FROM tmp01;
 
 --> 1. Fecha_nac: eliminar espacios en blanco, transformar a mayusculas, poniendo null a lo que no tienen registros, registros con errores de tipeo
REFRESH MATERIALIZED VIEW dta_uio.data_2021;


SELECT 
 "Fecha_nac" AS d_fnt_prs_dte_brt,
 CASE 
   WHEN "Fecha_nac" = '########' THEN NULL 
   WHEN "Fecha_nac" = '#NULL!' THEN NULL 
   WHEN  "Fecha_nac" ILIKE '%/%' THEN REPLACE("Fecha_nac", '/','-') ELSE 
   "Fecha_nac"
   END,
   Count(*)
FROM dta_uio.data_2021
GROUP BY 1,2
ORDER BY 1;

WITH tmp01 AS (
SELECT
  "Fecha_nac",
  CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END AS i_pos1,
  CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',2) ELSE "Fecha_nac" END AS i_pos2,
  CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END AS i_pos3,
  dta_uio.sif_sql(length(CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END) = 1, '0'|| (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END), (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END)::text),
  dta_uio.sif_sql(length(CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',2) ELSE "Fecha_nac" END) = 1, '0'|| (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END), (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',2) ELSE "Fecha_nac" END)::text),
  dta_uio.sif_sql(length(CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END) = 1, '0'|| (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END), (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END)::text),
  (dta_uio.sif_sql(length(CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END) = 1, '0'|| (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END), (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END)::text)) || '-' ||
  (dta_uio.sif_sql(length(CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',2) ELSE "Fecha_nac" END) = 1, '0'|| (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END), (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',2) ELSE "Fecha_nac" END)::text)) || '-' ||
  (dta_uio.sif_sql(length(CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END) = 1, '0'|| (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END), (CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END)::text)) AS s_dte,
  count(*)
  FROM dta_uio.data_2021
  GROUP BY 1
 ORDER BY 1)
SELECT 
   s_dte,
   count(*)
FROM tmp01
GROUP BY 1
ORDER BY 1 DESC;

SELECT 
 "Fecha_nac" AS d_fnt_prs_dte_brt,
 CASE 
   WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',1)
   WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',1) ELSE "Fecha_nac" END AS i_pos1,
 CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',2) 
      WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',2) ELSE "Fecha_nac" END AS i_pos2,
 CASE WHEN "Fecha_nac" ~~* '%/%' THEN split_part("Fecha_nac",'/',3) 
      WHEN "Fecha_nac" ~~* '%-%' THEN split_part("Fecha_nac",'-',3) ELSE "Fecha_nac" END AS i_pos3,
 
 Count(*)
FROM dta_uio.data_2021
GROUP BY 1,2
ORDER BY 1;




SELECT "Fecha_nac", REPLACE("Fecha_nac", RIGHT("Fecha_nac",8),''), count(*) FROM dta_uio.data_2021 WHERE "Fecha_nac"::TEXT ilike '%00:00:00%' GROUP BY 1 ORDER BY 1 DESC ;

UPDATE dta_uio.data_20210627 SET "Fecha_nac" = '1984-02-29' WHERE "Fecha_nac" = '29/02/1985';
UPDATE dta_uio.data_20211008 SET "Fecha_nac" = '1984-02-29' WHERE "Fecha_nac" = '29/02/1985';

SELECT * FROM dta_uio.data_20211008 WHERE "Fecha_nac" = '06/051957';
SELECT * FROM dta_uio.data_20210627 WHERE "Fecha_nac" = '09/15/2006';


SELECT 
 "Sat_O2",
 CASE WHEN "Sat_O2" ilike '%Z%' THEN NULL
      WHEN "Sat_O2" ilike '%-%' THEN replace("Sat_O2",'%',null) 
      WHEN "Sat_O2" ilike '%0.%' THEN replace("Sat_O2",'0.','') 
      WHEN "Sat_O2" ilike '%%%' THEN replace("Sat_O2",'%','')
 ELSE "Sat_O2" END, 
 Count(*)
FROM dta_uio.data_2021
GROUP BY 1
ORDER BY 1 DESC;

SELECT '39.2'::NUMERIC;

SELECT 
 "Temp",
 CASE WHEN btrim("Temp") ilike '%#NULL!%' THEN NULL
      WHEN btrim("Temp") ilike '%-%' THEN replace("Temp",'%',null)
      WHEN btrim("Temp") ilike '%,%' THEN replace("Temp",',','.')
      WHEN btrim("Temp") ilike '% %' THEN replace("Temp",' ','')
      WHEN btrim("Temp") ilike '%.' THEN replace("Temp",'.','')
 ELSE btrim("Temp") END::NUMERIC, 
 Count(*)
FROM dta_uio.data_2021
GROUP BY 1
ORDER BY 1 DESC;

REFRESH MATERIALIZED VIEW dta_uio.data_2021;
SELECT 
 "Fec_tom",
 CASE WHEN "Fec_tom" = '' THEN NULL
      WHEN "Fec_tom" ILIKE '%Octubre%'::text THEN replace("Fec_tom"::text, 'Octubre', '10')
      WHEN "Fec_tom" ILIKE '%Oct%'::text THEN replace("Fec_tom"::text, 'Oct', '10')
      WHEN "Fec_tom" ILIKE '%/%' THEN REPLACE ("Fec_tom",'/','-')
      WHEN length("Fec_tom") > 10 THEN LEFT ("Fec_tom",10)
 ELSE "Fec_tom" END,
 Count(*)
FROM dta_uio.data_2021
GROUP BY 1
ORDER BY 1 DESC;

DROP MATERIALIZED VIEW dta_uio.data_2021_fnt;
CREATE MATERIALIZED VIEW dta_uio.data_2021_fnt AS 
SELECT
  data_2021."ID1" AS i_fnt_prs_idn,
  CASE WHEN data_2021.fec_aten::text ~~* '%/%'::text THEN to_date(data_2021.fec_aten::text, 'dd/MM/yyyy'::text)
       WHEN "left"(data_2021.fec_aten::text, 3) ~~* '%-%'::text THEN to_date(data_2021.fec_aten::text, 'dd-MM-yyyy'::text)
  ELSE to_date(data_2021.fec_aten::text, 'yyyy-MM-dd'::text)
  END AS d_fnt_prs_dte_att,
  upper(btrim("RED_GRUP"::TEXT)) AS s_fnt_brg_att_grp,
  upper(btrim("Grup_aten"::TEXT)) AS s_fnt_brg_att_grp_sub,  
  upper(btrim("PARR_ATEN"::TEXT)) AS s_fnt_prq_att,
  CASE WHEN "Brig_Num"::TEXT = '0' THEN NULL ELSE upper(btrim("Brig_Num"::TEXT)) END AS s_fnt_brg_nmb,
  CASE WHEN upper(btrim(data_2021."ID"::text)) = '#REF!'::text THEN NULL::text
  ELSE upper(btrim(data_2021."ID"::text))
  END AS s_fnt_prs_idn,
  upper(btrim(nom::TEXT)) AS s_fnt_prs_nme,
  upper(btrim("Sexo"::TEXT)) AS s_fnt_prs_sex,
  upper(btrim("Nacio"::TEXT)) AS s_fnt_prs_nth,
  upper(btrim("Autoid"::TEXT)) AS s_fnt_prs_eth,
  upper(btrim("Inst"::TEXT)) AS s_fnt_prs_ins,
  upper(btrim("Ocup"::TEXT)) AS s_fnt_prs_ocp,
  CASE WHEN length(CASE WHEN "Fecha_nac" = '########' THEN NULL 
       WHEN "Fecha_nac" = '#NULL!' THEN NULL 
       WHEN  "Fecha_nac" ILIKE '%/%' THEN REPLACE("Fecha_nac", '/','-') 
   ELSE "Fecha_nac" END)>10 
   THEN REPLACE ((CASE WHEN "Fecha_nac" = '########' THEN NULL 
        			   WHEN "Fecha_nac" = '#NULL!' THEN NULL 
                       WHEN  "Fecha_nac" ILIKE '%/%' THEN REPLACE("Fecha_nac", '/','-') 
                   ELSE "Fecha_nac" END),'00:00:00', '') ELSE (CASE WHEN "Fecha_nac" = '########' THEN NULL 
                                                                    WHEN "Fecha_nac" = '#NULL!' THEN NULL 
                                                                    WHEN  "Fecha_nac" ILIKE '%/%' THEN REPLACE("Fecha_nac", '/','-') 
                                                                ELSE "Fecha_nac" END) END AS s_fnt_prs_dte_brt,
   "Edad"::text AS s_fnt_prs_dte_brt_yr,
   upper(btrim(grup_edad::TEXT)) AS s_fnt_prs_age_grp,
   upper(btrim("Prov_res"::TEXT)) AS s_fnt_prs_rsd_prv_nme,
   upper(btrim("Parr_res"::TEXT)) AS s_fnt_prs_rsd_prq_nme,
   upper(btrim("Bar_res"::TEXT)) AS s_fnt_prs_rsd_brr_nme,
   upper(btrim("Dir")) AS s_fnt_prs_rsd_adr,
   upper(btrim("Viaj_fue"::TEXT)) AS s_fnt_prs_trv,
   upper(btrim(ult_fecha_viaje::TEXT)) AS d_fnt_prs_trv_dte,
   upper(btrim("Lug_viaj"::TEXT))  AS s_fnt_prs_trv_ste,
   split_part("Pres_Art"::TEXT,'/',1) AS s_fnt_sgn_prs_stl,
   split_part("Pres_Art"::TEXT,'/',2) AS s_fnt_sgn_prs_dst,
   "FC"::SMALLINT  AS i_fnt_sgn_frc_crd,
   "FR"::SMALLINT  AS i_fnt_sgn_frc_rsp,
   CASE WHEN "Sat_O2" ilike '%Z%' THEN NULL
      WHEN "Sat_O2" ilike '%-%' THEN replace("Sat_O2",'%',null) 
      WHEN "Sat_O2" ilike '%0.%' THEN replace("Sat_O2",'0.','') 
      WHEN "Sat_O2" ilike '%%%' THEN replace("Sat_O2",'%','')
   ELSE "Sat_O2" END::SMALLINT AS i_fnt_sgn_str_oxg,
   CASE WHEN btrim("Temp") ilike '%#NULL!%' THEN NULL
      WHEN btrim("Temp") ilike '%-%' THEN replace("Temp",'%',null)
      WHEN btrim("Temp") ilike '%,%' THEN replace("Temp",',','.')
      WHEN btrim("Temp") ilike '% %' THEN replace("Temp",' ','')
      WHEN btrim("Temp") ilike '%.' THEN replace("Temp",'.','')
 ELSE btrim("Temp") END::NUMERIC AS r_fnt_sgn_tpr,
 upper(btrim(discap))::TEXT AS s_fnt_prs_qst_dsc,
 upper(btrim(cont_caso))::TEXT s_fnt_prs_qst_cse,
 upper(btrim("Sint"))::TEXT s_fnt_prs_qst_snt,
 upper(btrim("DG_ini"))::TEXT s_fnt_prs_qst_dgn,
 upper(btrim("Lug_prob_infe"))::TEXT s_fnt_prs_qst_ifc,
 upper(btrim("Fiebre"))::TEXT s_fnt_prs_snt_fbr,
 upper(btrim("Anosmia/Ageusia"))::TEXT   AS s_fnt_prs_snt_gst_olf,
 upper(btrim("Tos"))::TEXT   AS s_fnt_prs_snt_tos,
 upper(btrim("Disnea"))::TEXT   AS s_fnt_prs_snt_dsn,
 upper(btrim("Odinofagia"))::TEXT   AS s_fnt_prs_snt_dlr_grg,
 upper(btrim("NAusea/VOmito"))::TEXT   AS s_fnt_prs_snt_dlr_nse_vmt,
 upper(btrim("Diarrea"))::TEXT   AS s_fnt_prs_snt_drr,
 NULL  AS s_fnt_prs_snt_esc,
 NULL  AS s_fnt_prs_snt_cnf,
 NULL  AS s_fnt_prs_snt_dlr,
 NULL  AS s_fnt_prs_snt_cns,
 upper(btrim("Comor"))::TEXT AS s_fnt_prs_qst_cmb,
 NULL AS s_fnt_prs_cmb_enf_crd_vsc,
 NULL AS s_fnt_prs_cmb_dbt,
 NULL AS s_fnt_prs_cmb_hpr,
 NULL AS s_fnt_prs_cmb_obs_svr,
 NULL AS s_fnt_prs_cmb_enf_rnl_isf,
 NULL AS s_fnt_prs_cmb_enf_hpt_isf,
 NULL AS s_fnt_prs_cmb_enf_plm_asm,
 upper(btrim("Uni_not"::TEXT)) AS s_fnt_unt_ntf,
 upper(btrim("Emb"::TEXT)) AS s_fnt_prs_emb,
 upper(btrim("Sem_gest"::TEXT)) AS  s_fnt_prs_emb_nmb,
 upper(btrim("Lab"::TEXT)) as s_fnt_lbr_nme,
 upper(btrim("Tip_mues"::TEXT)) AS s_fnt_smp_tpe,
 CASE WHEN "Fec_tom" = '' THEN NULL
      WHEN "Fec_tom" ILIKE '%Octubre%'::text THEN replace("Fec_tom"::text, 'Octubre', '10')
      WHEN "Fec_tom" ILIKE '%Oct%'::text THEN replace("Fec_tom"::text, 'Oct', '10')
      WHEN "Fec_tom" ILIKE '%/%' THEN REPLACE ("Fec_tom",'/','-')
      WHEN length("Fec_tom") > 10 THEN LEFT ("Fec_tom",10)
 ELSE "Fec_tom" END AS s_fnt_smp_dte_tke,
 upper(btrim("ParAmetro"::TEXT)) AS s_fnt_smp_prm,
 upper(btrim("Res"::TEXT)) AS s_fnt_smp_rsl,
 upper(btrim("IGM"::TEXT)) AS s_fnt_smp_igm,
 upper(btrim("IGG"::TEXT)) AS s_fnt_smp_igg,
 NULL AS s_fnt_prs_eml,
 NULL AS s_fnt_prs_enc_01,
 NULL AS s_fnt_prs_enc_02,
 NULL AS s_fnt_prs_enc_03,
 NULL AS s_fnt_prs_enc_04,
 NULL AS s_fnt_prs_enc_05,
 NULL AS s_fnt_prs_enc_06,
 NULL AS s_fnt_prs_enc_07,
 NULL AS s_fnt_prs_asl,
 upper(btrim("Resp_llen"::TEXT))s_fnt_prs_rsp_lnd,
 NULL AS s_fnt_prs_dtl
FROM dta_uio.data_2021;

DROP VIEW dta_uio.data_2021_gnr;
CREATE OR REPLACE VIEW dta_uio.data_2021_gnr AS 
WITH tmp01 AS (
SELECT 
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
FROM dta_tbl_prs_dnr_2021 prs_dnr 
GROUP BY 1,2,3,4,5,6,7,8,9,10)
SELECT
  date_part('year', prs.d_fnt_prs_dte_att)::SMALLINT AS i_fnt_yr,
  "right"(dta_uio.smn_epd(date_part('year'::text, prs.d_fnt_prs_dte_att)::numeric, date_part('month'::text, prs.d_fnt_prs_dte_att)::numeric, date_part('day'::text, prs.d_fnt_prs_dte_att)::numeric)::text, 2)::smallint AS i_fnt_epi_wk,
  prs.d_fnt_prs_dte_att,
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
  prs.s_fnt_prs_dte_brt::TEXT AS s_fnt_prs_dte_brt,
  tmp01.d_dnr_prs_dte_brt,  
  prs.s_fnt_prs_dte_brt_yr::TEXT AS s_fnt_prs_dte_brt_yr,
  NULL::SMALLINT AS i_fnt_prs_brt_yr,
  null::SMALLINT AS i_fnt_prs_brt_mth,
  null::SMALLINT  AS i_fnt_prs_brt_day,
  prs.s_fnt_prs_age_grp,
  NULL AS s_fnt_prs_age_grp_clc,
  date_part('year', age(prs.d_fnt_prs_dte_att, tmp01.d_dnr_prs_dte_brt))::SMALLINT AS i_dnr_prs_brt_yr,
  date_part('month', age(prs.d_fnt_prs_dte_att, tmp01.d_dnr_prs_dte_brt))::SMALLINT AS i_dnr_prs_brt_mth,
  date_part('day', age(prs.d_fnt_prs_dte_att, tmp01.d_dnr_prs_dte_brt))::SMALLINT AS i_dnr_prs_brt_day,
  dta_uio.age_grp(prs.d_fnt_prs_dte_att, tmp01.d_dnr_prs_dte_brt) AS s_dnr_prs_age_grp_clc,
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
  prs.d_fnt_prs_trv_dte AS s_fnt_prs_trv_dte,
  prs.s_fnt_prs_trv_ste,
  prs.s_fnt_sgn_prs_stl,
  prs.s_fnt_sgn_prs_dst,
  prs.i_fnt_sgn_frc_crd::SMALLINT ,
  prs.i_fnt_sgn_frc_rsp::SMALLINT ,
  prs.i_fnt_sgn_str_oxg::SMALLINT ,
  prs.r_fnt_sgn_tpr::NUMERIC,
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
    prs.s_fnt_smp_dte_tke::TEXT AS s_fnt_smp_dte_tke,
    prs.s_fnt_smp_prm,
    btrim(CASE WHEN prs.s_fnt_smp_rsl = '' THEN NULL 
         WHEN prs.s_fnt_smp_rsl = '0' THEN NULL 
    ELSE prs.s_fnt_smp_rsl END) AS s_fnt_smp_rsl,
    prs.s_fnt_smp_igm,
    prs.s_fnt_smp_igg,
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
    Count(*)::smallint AS i_ttl_dpl
FROM dta_uio.data_2021_fnt prs
LEFT JOIN tmp01 ON tmp01.s_dnr_prs_idn = prs.s_fnt_prs_idn
GROUP BY 
  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
  21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
  41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
  61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
  81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,s_fnt_smp_rsl
 ORDER BY 1,2,prs.s_fnt_smp_rsl DESC;



---> READ: Consulta para obtener los registros depurados por campo de 2021
-----------------------------------------------------------------------------------------------------------------------------------------------
-- SQL --> Limpieza de datos
-----------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------
-- SQL --> Validaciones
-----------------------------------------------------------------------------------------------------------------------------------------------

---> READ: Consultas para validar cuando existe un error al correr el algoritmo de la DINARDAP
SELECT * FROM dta_uio.dta_tbl_prs_idn_2021 WHERE s_prs_idn = '1716988603';
SELECT * FROM dta_tbl_prs_dnr_2021 WHERE s_prs_idn = '1306622174';
SELECT * FROM dta_tbl_prs_dnr_2021 ORDER BY 1 DESC;


