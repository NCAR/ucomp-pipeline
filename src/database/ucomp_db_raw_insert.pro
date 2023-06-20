; docformat = 'rst'

;+
; Insert an array of L0 FITS files into the ucomp_raw database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_raw_insert, l0_files, obsday_index, db, logger_name=logger_name
  compile_opt strictarr

  n_files = n_elements(l0_files)
  mg_log, 'inserting %d files into ucomp_raw', n_files, name=logger_name, /info

  ; get index for OK quality data files
  q = 'select * from ucomp_quality where quality=''OK'''
  ok_quality_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  ok_quality_index = ok_quality_results.quality_id

  q = 'select * from ucomp_quality where quality=''bad'''
  bad_quality_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  bad_quality_index = bad_quality_results.quality_id

  ; get index for raw (level 0) data files
  q = 'select * from ucomp_level where level=''L0'''
  level_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id

  for f = 0L, n_files - 1L do begin
    file = l0_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $

              {name: 'datatype', type: '''%s'''}, $
              {name: 'wave_region', type: '''%s'''}, $
              {name: 'quality_id', type: '%d'}, $
              {name: 'quality_bitmask', type: '%d'}, $
              {name: 'level_id', type: '%d'}, $

              {name: 'obs_id', type: '''%s'''}, $
              {name: 'obs_plan', type: '''%s'''}, $

              {name: 't_rack', type: '%s'}, $
              {name: 't_lcvr1  ', type: '%s'}, $
              {name: 't_lcvr2  ', type: '%s'}, $
              {name: 't_lcvr3  ', type: '%s'}, $
              {name: 't_lnb1', type: '%s'}, $
              {name: 't_mod', type: '%s'}, $
              {name: 't_lnb2', type: '%s'}, $
              {name: 't_lcvr4', type: '%s'}, $
              {name: 't_lcvr5', type: '%s'}, $
              {name: 't_base', type: '%s'}, $
              {name: 'tu_rack', type: '%s'}, $
              {name: 'tu_lcvr1', type: '%s'}, $
              {name: 'tu_lcvr2', type: '%s'}, $
              {name: 'tu_lcvr3', type: '%s'}, $
              {name: 'tu_lnb1', type: '%s'}, $
              {name: 'tu_mod', type: '%s'}, $
              {name: 'tu_lnb2', type: '%s'}, $
              {name: 'tu_lcvr4', type: '%s'}, $
              {name: 'tu_lcvr5', type: '%s'}, $
              {name: 'tu_base', type: '%s'}, $
              {name: 't_c0arr', type: '%s'}, $
              {name: 't_c0pcb', type: '%s'}, $
              {name: 't_c1arr', type: '%s'}, $
              {name: 't_c1pcb', type: '%s'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_raw (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $

                 file.data_type, $
                 file.wave_region, $
                 file.quality_bitmask eq 0 ? ok_quality_index : bad_quality_index, $
                 file.quality_bitmask, $
                 level_index, $

                 file.obs_id, $
                 file.obs_plan, $

                 ucomp_db_float(file.t_rack, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr3, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lnb1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_mod, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lnb2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr4, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr5, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_base, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_rack, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr3, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lnb1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_mod, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lnb2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr4, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr5, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_base, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_c0arr, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_c0pcb, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_c1arr, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_c1pcb, valid_range=[-20.0, 100.0]), $

                 status=status
    if (status ne 0L) then goto, done
  endfor

  done:
end
