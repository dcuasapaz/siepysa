-- ALTER: Cambiar de esquema 
ALTER TABLE public.data_plt SET SCHEMA dta_uio;
-- READ: Ver los datos de la tabla 
SELECT * FROM dta_uio.data_plt;
-- READ: SQl para limpieza de datos
SELECT
  date_part('year', to_date("Fecha atención",'dd/MM/yyyy')) AS i_fnt_yr,
  "right"(dta_uio.smn_epd(date_part('year'::text, to_date("Fecha atención",'dd/MM/yyyy'))::numeric, date_part('month'::text, to_date("Fecha atención",'dd/MM/yyyy') )::numeric, date_part('day'::text, to_date("Fecha atención",'dd/MM/yyyy'))::numeric)::text, 2)::smallint AS i_fnt_epi_wk,
  to_date("Fecha atención",'dd/MM/yyyy') AS d_fnt_prs_dte_att,
  upper(btrim("Grupo atención"))::TEXT AS s_fnt_brg_att_grp,
  'SE DESCONOCE'::TEXT AS s_fnt_brg_att_grp_sub,
  upper(btrim("Provincia unidad"))::TEXT AS s_fnt_prv_att,
  upper(btrim("Cantón unidad"))::TEXT AS s_fnt_cnt_att,
  upper(btrim("Parroquia unidad"))::TEXT AS s_fnt_prq_att,
  'SE DESCONOCE'::TEXT AS s_fnt_brg_nmb,
  upper(btrim("Identificación"))::TEXT AS s_fnt_prs_idn,
  upper(btrim("Paciente"))::TEXT AS s_fnt_prs_nme,
  upper(btrim("Sexo"))::TEXT AS s_fnt_prs_sex,
  upper(btrim("Nacionalidad"))::TEXT AS s_fnt_prs_nth,  
  upper(btrim("Autoidentificación"))::TEXT AS s_fnt_prs_eth, 
  upper(btrim("Institución"))::TEXT AS s_fnt_prs_ins,
  upper(btrim("Ocupación"))::TEXT AS s_fnt_prs_ocp,
  'SE DESCONOCE'::TEXT AS s_fnt_prs_prf,
  to_date("Fecha nacimiento",'dd/MM/yyyy') AS d_fnt_prs_dte_brt,
  date_part('year',age(to_date("Fecha atención",'dd/MM/yyyy'),to_date("Fecha nacimiento",'dd/MM/yyyy'))) AS i_fnt_prs_age_yr,
  date_part('month',age(to_date("Fecha atención",'dd/MM/yyyy'),to_date("Fecha nacimiento",'dd/MM/yyyy'))) AS i_fnt_prs_age_mth,
  date_part('day',age(to_date("Fecha atención",'dd/MM/yyyy'),to_date("Fecha nacimiento",'dd/MM/yyyy'))) AS i_fnt_prs_age_day,
  upper(btrim("Edad"))::TEXT AS s_fnt_prs_age,
  dta_uio.age_grp(to_date("Fecha atención",'dd/MM/yyyy'),to_date("Fecha nacimiento",'dd/MM/yyyy')) AS s_fnt_prs_age_grp,
  to_date('1900-01-01','yyyy-MM-dd') AS d_fnt_prs_dte_dfn,
  'SE DESCONOCE'::TEXT AS s_fnt_prs_stt,
  'SE DESCONOCE'::TEXT AS s_fnt_prs_cyg,
  upper(btrim("Provincia residencia"))::TEXT AS s_fnt_prs_rsd_prv_nme,
  upper(btrim("Cantón residencia"))::TEXT AS s_fnt_prs_rsd_cnt_nme,
  upper(btrim("Parroquia residencia"))::TEXT AS s_fnt_prs_rsd_prq_nme,
  upper(btrim("Barrio residencia"))::TEXT AS s_fnt_prs_rsd_brr_nme,
  upper(btrim("Dirección"))::TEXT AS s_fnt_prs_rsd_adr,
  upper(btrim("Viaje fuera de"))::TEXT AS s_fnt_prs_trv_qst,
  to_date("Última fecha viaje" ,'dd/MM/yyyy')AS d_fnt_prs_trv_dte,
  upper(btrim("Lugar viaje"))::TEXT AS s_fnt_prs_trv_ste,
  -99::SMALLINT AS i_fnt_sgn_prs_stl,
  -99::SMALLINT AS i_fnt_sgn_prs_dst,
  -99::SMALLINT AS i_fnt_sgn_frc_crd,
  -99::SMALLINT AS i_fnt_sgn_frc_rsp,
  -99::SMALLINT AS i_fnt_sgn_str_oxg,
  upper(btrim("Toma temperatura"))::NUMERIC AS r_fnt_sgn_tpr,
  
  
  upper(btrim("Teléfono"))::TEXT,
  
  upper(btrim("Numero Muestra"))::text,
  upper(btrim("Responsable llenado"))::text,
  upper(btrim("Definicion caso"))::text,
  
  upper(btrim("Institución"))::TEXT,
  upper(btrim("Unidad notifica"))::TEXT,
  

  upper(btrim("Nombre notifica"))::TEXT,
  
  upper(btrim("No historia clínica"))::TEXT,
  
  
  
  
  upper(btrim("Lugar probable infección"))::TEXT,
  to_date("Fecha inicio síntomas",'dd/MM/yyyy'),
  upper(btrim("Diagnóstico inicial"))::TEXT,
  upper(btrim("Comorbilidad"))::TEXT,
  
  upper(btrim("Embarazada"))::TEXT,
  upper(btrim("Semanas gestación"))::TEXT,
  
  upper(btrim("Muestra laboratorio"))::TEXT,
  upper(btrim("Laboratorio"))::TEXT, 
  upper(btrim("Tipo muestra"))::TEXT,
  to_date("Fecha toma" ,'dd/MM/yyyy'),
  upper(btrim("Field43"))::TEXT,
  to_date("Fecha recepción" ,'dd/MM/yyyy'),
  upper(btrim("Muestra adecuada"))::TEXT,
  to_date("Fecha procesamiento" ,'dd/MM/yyyy'),
  to_date("Fecha entrega resultado" ,'dd/MM/yyyy'),
  upper(btrim("Estado"))::TEXT,
  upper(btrim("Parámetro"))::TEXT,
  upper(btrim("Resultado"))::TEXT,
  upper(btrim("Field51"))::TEXT,
  upper(btrim("Field52"))::TEXT,
  upper(btrim("Field53"))::TEXT,
  upper(btrim("Field54"))::TEXT,
  upper(btrim("Resultado (Agente)"))::TEXT,
  upper(btrim("Observaciones"))::TEXT
FROM dta_uio.data_plt
ORDER BY 1,2,3;

