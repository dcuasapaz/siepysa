-- READ: Consultar datos obtenidos de la dinardap y comparar con la tabla de cedulas validadas como OK 
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
  prs.i_epi_wk AS i_fnt_epi_wk,
  prs.d_uio_dte_att AS d_fnt_prs_dte_att,
  prs.s_brg_att_grp AS s_fnt_brg_att_grp,
  prs.s_brg_att_grp_sub AS s_fnt_brg_att_grp_sub,
  prs.s_brg_nmb AS s_fnt_brg_nmb,
  prs.s_prs_idn AS s_fnt_prs_idn,
  tmp01.s_dnr_prs_idn,
  prs.s_prs_nme AS s_fnt_prs_nme,
  tmp01.s_dnr_prs_nme,
  prs.s_prs_sex AS s_fnt_prs_sex,
  prs.s_prs_nth AS s_fnt_prs_nth,
  prs.s_prs_eth AS s_fnt_prs_eth,
  prs.s_prs_ins AS s_fnt_prs_ins,
  prs.s_prs_ocp AS s_fnt_prs_ocp,
  tmp01.s_dnr_prs_prf,
  prs.d_prs_dte_brt AS d_fnt_prs_dte_brt,
  tmp01.d_dnr_prs_dte_brt,  
  prs.i_prs_dte_brt_yr AS i_fnt_prs_dte_brt_yr,
  date_part('year', age(prs.d_uio_dte_att, prs.d_prs_dte_brt)) AS i_fnt_prs_brt_yr,
  date_part('month', age(prs.d_uio_dte_att, prs.d_prs_dte_brt)) AS i_fnt_prs_brt_mth,
  date_part('day', age(prs.d_uio_dte_att, prs.d_prs_dte_brt)) AS i_fnt_prs_brt_day,
  prs.s_prs_age_grp AS s_fnt_prs_age_grp,
  dta_uio.age_grp(prs.d_uio_dte_att, prs.d_prs_dte_brt) AS s_fnt_prs_age_grp_clc,
  date_part('year', age(prs.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt)) AS i_dnr_prs_brt_yr,
  date_part('month', age(prs.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt)) AS i_dnr_prs_brt_mth,
  date_part('day', age(prs.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt)) AS i_dnr_prs_brt_day,
  dta_uio.age_grp(prs.d_uio_dte_att, tmp01.d_dnr_prs_dte_brt) AS s_dnr_prs_age_grp_clc,
  tmp01.d_dnr_prs_dte_dfn,
  tmp01.s_dnr_prs_stt,
  tmp01.s_dnr_prs_cyg,
  prs.s_prs_rsd_prv_nme AS s_fnt_prs_rsd_prv_nme,
  prs.s_prs_rsd_prq_nme AS s_fnt_prs_rsd_prq_nme,
  prs.s_prs_rsd_brr_nme AS s_fnt_prs_rsd_brr_nme,
  prs.s_prs_rsd_adr AS s_fnt_prs_rsd_adr,
  tmp01.s_dnr_prs_prv_nme,
  tmp01.s_dnr_prs_cnt_nme,
  tmp01.s_dnr_prs_prq_nme,
  dta_uio.sif_sql(prs.s_prs_rsd_prv_nme ISNULL, tmp01.s_dnr_prs_prv_nme,  prs.s_prs_rsd_prv_nme) AS s_gnr_prs_rsd_prv_nme,
  dta_uio.sif_sql(prs.s_prs_rsd_prq_nme ISNULL, tmp01.s_dnr_prs_prq_nme,  prs.s_prs_rsd_prq_nme) AS s_gnr_prs_rsd_prq_nme,
  prs.s_prs_trv,
  prs.d_prs_trv_dte,
  prs.s_prs_trv_ste,
  prs.r_sgn_prs_stl,
  prs.r_sgn_prs_dst,
  prs.r_sgn_frc_crd,
  prs.r_sgn_frc_rsp,
  prs.r_sgn_str_oxg,
  prs.r_sgn_tpr,
  prs.s_prs_qst_dsc,
  prs.s_prs_qst_cse,
  prs.s_prs_qst_snt,
  prs.s_prs_qst_dgn,
  prs.s_prs_qst_ifc,
  prs.s_prs_snt_fbr,
    prs.s_prs_snt_gst_olf,
    prs.s_prs_snt_tos,
    prs.s_prs_snt_dsn,
    prs.s_prs_snt_dlr_grg,
    prs.s_prs_snt_dlr_nse_vmt,
    prs.s_prs_snt_drr,
    prs.s_prs_snt_esc,
    prs.s_prs_snt_cnf,
    prs.s_prs_snt_dlr,
    prs.s_prs_snt_cns,
    prs.s_prs_qst_cmb,
    prs.s_prs_cmb_enf_crd_vsc,
    prs.s_prs_cmb_dbt,
    prs.s_prs_cmb_hpr,
    prs.s_prs_cmb_obs_svr,
    prs.s_prs_cmb_enf_rnl_isf,
    prs.s_prs_cmb_enf_hpt_isf,
    prs.s_prs_cmb_enf_plm_asm,
    prs.s_unt_ntf,
    prs.s_prs_emb,
    prs.s_prs_emb_nmb,
    prs.s_lbr_nme,
    prs.s_smp_tpe,
    to_date(prs.d_smp_dte_tke,'yyyy-MM-dd') AS d_fnt_smp_dte_tke,
    prs.s_smp_prm AS s_fnt_smp_prm,
    prs.s_smp_rsl AS s_fnt_smp_rsl,
    prs.s_prs_eml,
    prs.s_prs_enc_01,
    prs.s_prs_enc_02,
    prs.s_prs_enc_03,
    prs.s_prs_enc_04,
    prs.s_prs_enc_05,
    prs.s_prs_enc_06,
    prs.s_prs_enc_07,
    prs.s_prs_asl,
    prs.s_prs_rsp_lnd,
    prs.s_prs_dtl  
FROM dta_uio.data_2020_str prs
FULL JOIN tmp01 ON tmp01.s_dnr_prs_idn = prs.s_prs_idn
GROUP BY 
  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
  21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
  41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
  61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
  81,82,83,84,85,86,87,88,89,90,91
 ORDER BY 1,2,prs.s_smp_rsl DESC;


SELECT * FROM dta_uio.data_2020_gnr;


SELECT * FROM dta_tbl_prs dtp ORDER BY 1 DESC;
SELECT * FROM dta_tbl_prs_dnr ORDER BY 1 DESC;
SELECT s_prs_idn, count(*) FROM dta_tbl_prs_dnr GROUP BY 1 ORDER BY 1 DESC;


SELECT * FROM dta_uio.dta_tbl_prs_idn_2021 WHERE s_prs_idn = '1715722763';
SELECT * FROM dta_tbl_prs_dnr_2021 WHERE s_prs_idn = '1724971922';
SELECT * FROM dta_tbl_prs_dnr_2021 ORDER BY 1 DESC;



DROP MATERIALIZED VIEW dta_uio.data_2020_str;

CREATE MATERIALIZED VIEW dta_uio.data_2020_str AS 
SELECT "right"(dta_uio.smn_epd(date_part('year'::text, data_2020.fecha_atencion::date)::numeric, date_part('month'::text, data_2020.fecha_atencion::date)::numeric, date_part('day'::text, data_2020.fecha_atencion::date)::numeric)::text, 2)::smallint AS i_epi_wk,
    data_2020.fecha_atencion::date AS d_uio_dte_att,
        CASE
            WHEN data_2020."Brigada_Num"::text = ''::text THEN NULL::character varying
            WHEN data_2020."Brigada_Num"::text = ' '::text THEN NULL::character varying
            ELSE data_2020."Brigada_Num"
        END::text AS s_brg_nmb,
    data_2020."PARROQUIA"::text AS s_brg_prq_nme,
    data_2020."RED_GRUP"::text AS s_brg_att_grp,
    data_2020."Grupoa_atencion"::text AS s_brg_att_grp_sub,
    upper(btrim(data_2020."ID"::text)) AS s_prs_idn,
    length(upper(btrim(data_2020."ID"::text)))::smallint AS i_prs_idn_lng,
    upper(btrim(data_2020.nombre::text)) AS s_prs_nme,
        CASE
            WHEN upper(btrim(data_2020."Nacionalidad"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Nacionalidad"::text))
        END AS s_prs_nth,
    upper(btrim(data_2020."Sexo"::text)) AS s_prs_sex,
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
        END AS d_prs_dte_brt,
    data_2020."Edad"::smallint AS i_prs_dte_brt_yr,
    data_2020.grup_edad::text AS s_prs_age_grp,
        CASE
            WHEN upper(btrim(data_2020."Autoidentificación"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Autoidentificación"::text))
        END AS s_prs_eth,
        CASE
            WHEN upper(btrim(data_2020."Instrucción"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Instrucción"::text))
        END AS s_prs_ins,
        CASE
            WHEN upper(btrim(data_2020."Ocupación"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Ocupación"::text))
        END AS s_prs_ocp,
        CASE
            WHEN upper(btrim(data_2020."Provinciaresidencia"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Provinciaresidencia"::text))
        END AS s_prs_rsd_prv_nme,
        CASE
            WHEN upper(btrim(data_2020."Parroquiaresidencia"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Parroquiaresidencia"::text))
        END AS s_prs_rsd_prq_nme,
        CASE
            WHEN upper(btrim(data_2020."Barrioresidencia"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Barrioresidencia"::text))
        END AS s_prs_rsd_brr_nme,
        CASE
            WHEN upper(btrim(data_2020."Dirección"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Dirección"::text))
        END AS s_prs_rsd_adr,
        CASE
            WHEN upper(btrim(data_2020."Viaje_fuera"::text)) = ''::text THEN NULL::text
            ELSE upper(btrim(data_2020."Viaje_fuera"::text))
        END AS s_prs_trv,
    data_2020.ult_fecha_viaje AS d_prs_trv_dte,
    data_2020."Lugarviaje"::text AS s_prs_trv_ste,
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
        END::text, '/'::text, 1) AS r_sgn_prs_stl,
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
        END::text, '/'::text, 2) AS r_sgn_prs_dst,
    data_2020."Frec_card"::numeric AS r_sgn_frc_crd,
    data_2020."Frec_resp"::numeric AS r_sgn_frc_rsp,
        CASE
            WHEN data_2020."Sat_O2"::text = ''::text THEN NULL::numeric
            ELSE round(data_2020."Sat_O2"::numeric, 2)
        END AS r_sgn_str_oxg,
        CASE
            WHEN data_2020."Temp"::text = '#NULL!'::text THEN NULL::numeric
            WHEN data_2020."Temp"::text = ''::text THEN NULL::numeric
            WHEN data_2020."Temp"::text = ' '::text THEN NULL::numeric
            ELSE round(data_2020."Temp"::numeric, 2)
        END AS r_sgn_tpr,
    data_2020.discapacidad::text AS s_prs_qst_dsc,
    data_2020."Hatenidocontactoconuncasoc"::text AS s_prs_qst_cse,
    data_2020."DG_inicial"::text AS s_prs_qst_dgn,
    data_2020."Lugar_proB_infecc"::text AS s_prs_qst_ifc,
        CASE
            WHEN data_2020."Sintomatoloía"::text = ''::text THEN NULL::text
            ELSE upper(data_2020."Sintomatoloía"::text)
        END AS s_prs_qst_snt,
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
        END AS d_prs_qst_dte_snt,
    CASE WHEN data_2020."Fiebre"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Fiebre"::text)) END AS s_prs_snt_fbr,
    CASE WHEN data_2020."Perdida_gusto_olfato"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Perdida_gusto_olfato"::text)) END AS s_prs_snt_gst_olf,
    CASE WHEN data_2020."Tos"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Tos"::text)) END AS s_prs_snt_tos,
    CASE WHEN data_2020."Disnea"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Disnea"::text)) END AS s_prs_snt_dsn,
    CASE WHEN data_2020."Dolorenlagarganta"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Dolorenlagarganta"::text)) END AS s_prs_snt_dlr_grg,
    CASE WHEN data_2020."Náuseaovómito"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Náuseaovómito"::text)) END AS s_prs_snt_dlr_nse_vmt,
    CASE WHEN data_2020."Diarrea"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Diarrea"::text)) END AS s_prs_snt_drr,
    CASE WHEN data_2020."Escalofrios"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Escalofrios"::text)) END AS s_prs_snt_esc,
    CASE WHEN data_2020."Confusiónodificultadparaesta"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Confusiónodificultadparaesta"::text)) END AS s_prs_snt_cnf,
    CASE WHEN data_2020."Doloropresiónpersistenteene"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Doloropresiónpersistenteene"::text)) END AS s_prs_snt_dlr,
    CASE WHEN data_2020."Cianosis"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Cianosis"::TEXT)) END AS s_prs_snt_cns,
    CASE WHEN data_2020."Comorbilidad"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Comorbilidad"::text)) END AS s_prs_qst_cmb,
    CASE WHEN data_2020."Enfermedadescardiovascularesa"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadescardiovascularesa"::text)) END AS s_prs_cmb_enf_crd_vsc,
    CASE WHEN data_2020."Diabetes"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Diabetes"::text)) END AS s_prs_cmb_dbt,
    CASE WHEN data_2020."Hipertensión"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Hipertensión"::text)) END AS s_prs_cmb_hpr,
    CASE WHEN data_2020."Obesidadsevera"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Obesidadsevera"::text)) END AS s_prs_cmb_obs_svr,
    CASE WHEN data_2020."Enfermedadesrenalesinsuficien"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadesrenalesinsuficien"::text)) END AS s_prs_cmb_enf_rnl_isf,
    CASE WHEN data_2020."Enfermedadeshepáticasinsufici"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadeshepáticasinsufici"::text)) END AS s_prs_cmb_enf_hpt_isf,
    CASE WHEN data_2020."Enfermedadespulmonaresasma"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enfermedadespulmonaresasma"::text)) END AS s_prs_cmb_enf_plm_asm,
    CASE WHEN data_2020."Unidadnotifica"::text = '' THEN NULL ELSE upper(trim(BOTH data_2020."Unidadnotifica"::text)) END AS s_unt_ntf,
    CASE WHEN data_2020."Embarazada"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Embarazada"::TEXT)) END AS s_prs_emb,
    CASE WHEN data_2020."Semanasgestación"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Semanasgestación"::TEXT)) END AS s_prs_emb_nmb,
    CASE WHEN data_2020."Laboratorio"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Laboratorio"::TEXT)) END AS s_lbr_nme,
    CASE WHEN data_2020."Tipomuestra"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Tipomuestra"::TEXT)) END AS s_smp_tpe,
    CASE WHEN data_2020."Fechatoma"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Fechatoma"::TEXT)) END AS d_smp_dte_tke,
    CASE WHEN data_2020."Parámetro"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Parámetro"::TEXT)) END AS s_smp_prm,
    CASE WHEN data_2020."Resultado"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Resultado"::TEXT)) END AS s_smp_rsl,
    CASE WHEN data_2020."Correo"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Correo"::TEXT)) END AS s_prs_eml,
    CASE WHEN data_2020."Hanotadounestadodetristeza"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Hanotadounestadodetristeza"::TEXT)) END AS s_prs_enc_01,
    CASE WHEN data_2020."Enlasúltimassemanassehase"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlasúltimassemanassehase"::TEXT)) END AS s_prs_enc_02,
    CASE WHEN data_2020."Enlasúltimassemanashaprese"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlasúltimassemanashaprese"::TEXT)) END AS s_prs_enc_03,
    CASE WHEN data_2020."Enlasúltimassemanasustedy"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlasúltimassemanasustedy"::TEXT)) END AS s_prs_enc_04,
    CASE WHEN data_2020."Hanotadounaumentoenelcons"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Hanotadounaumentoenelcons"::TEXT)) END AS s_prs_enc_05,
    CASE WHEN data_2020."Enlosúltimos4meseshapensa"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Enlosúltimos4meseshapensa"::TEXT)) END AS s_prs_enc_06,
    CASE WHEN data_2020."Tienesuficientesingresoseconó"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Tienesuficientesingresoseconó"::TEXT))END AS s_prs_enc_07,
    CASE WHEN data_2020."Requiere_aislamiento"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Requiere_aislamiento"::TEXT)) END AS s_prs_asl,
    CASE WHEN data_2020."Resp_llenado"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Resp_llenado"::TEXT)) END AS s_prs_rsp_lnd,
    CASE WHEN data_2020."Detalle"::TEXT = '' THEN NULL ELSE upper(trim(BOTH data_2020."Detalle"::TEXT)) END AS s_prs_dtl
   FROM dta_uio.data_2020
  WHERE data_2020.fecha_atencion IS NOT NULL
  ORDER BY ("right"(dta_uio.smn_epd(date_part('year'::text, data_2020.fecha_atencion::date)::numeric, date_part('month'::text, data_2020.fecha_atencion::date)::numeric, date_part('day'::text, data_2020.fecha_atencion::date)::numeric)::text, 2)::smallint), (data_2020.fecha_atencion::date), (
        CASE
            WHEN data_2020."Brigada_Num"::text = ''::text THEN NULL::character varying
            WHEN data_2020."Brigada_Num"::text = ' '::text THEN NULL::character varying
            ELSE data_2020."Brigada_Num"
        END::text);

