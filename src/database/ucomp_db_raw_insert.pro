; docformat = 'rst'

;+
; Insert an array of L0 FITS files into the ucomp_raw database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   database : in, optional, type=object
;     `MGdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_raw_insert, l0_files, obsday_index, db, logger_name=logger_name
  compile_opt strictarr

  ; get index for OK quality data files
  q = 'select * from ucomp_quality where quality=''OK'''
  quality_results = db->query(q, fields=fields)
  quality_index = quality_results.quality_id	

  ; get index for raw (level 0) data files
  q = 'select * from ucomp_level where level=''L0'''
  level_results = db->query(q, fields=fields)
  level_index = level_results.level_id	

  n_files = n_elements(l0_files)

  for f = 0L, n_files - 1L do begin
    file = l0_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'date_end', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'quality_id', type: '%d'}, $
              {name: 'level_id', type: '%d'}, $

              {name: 'cam0_arr_temp', type: '%f'}, $
              {name: 'cam0_pcb_temp', type: '%f'}, $
              {name: 'cam1_arr_temp', type: '%f'}, $
              {name: 'cam1_pcb_temp', type: '%f'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_raw (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, file.date_end, $
                 obsday_index, quality_index, level_index, $

                 file.cam0_arr_temp, $
                 file.cam0_pcb_temp, $
                 file.cam1_arr_temp, $
                 file.cam1_pcb_temp, $

                 status=status, $
                 error_message=error_message, $
                 sql_statement=sql_cmd
    if (status ne 0L) then begin
      mg_log, 'error inserting in ucomp_raw table', name=logger_name, /error
      mg_log, 'status: %d, error message: %s', status, error_message, $
              name=logger_name, /error
      mg_log, 'SQL command: %s', sql_cmd, name=logger_name, /error
    endif
  endfor
end
