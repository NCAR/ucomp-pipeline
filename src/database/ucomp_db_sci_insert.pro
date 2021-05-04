; docformat = 'rst'

;+
; Choose representative science file(s) from an array of L0 FITS files and
; enter them into the ucomp_sci database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   database : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_sci_insert, l0_files, obsday_index, db, logger_name=logger_name
  compile_opt strictarr

  if (n_elements(l0_files) eq 0L) then begin
    mg_log, 'no science file to insert, skipping', name=logger_name, /info
    goto, done
  endif

  ; TODO: choose science file
  science_files = l0_files[0]

  n_files = n_elements(science_files)
  mg_log, 'inserting %d files into ucomp_sci', n_files, name=logger_name, /info

  ; get index for OK quality data files
  q = 'select * from ucomp_quality where quality=''OK'''
  quality_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  quality_index = quality_results.quality_id	

  ; get index for raw (level 0) data files
  q = 'select * from ucomp_level where level=''L0'''
  level_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id	

  for f = 0L, n_files - 1L do begin
    file = science_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    ; TODO: implement
;     fields = [{name: 'file_name', type: '''%s'''}, $
;               {name: 'date_obs', type: '''%s'''}, $
;               {name: 'obsday_id', type: '%d'}, $
;               {name: 'quality_id', type: '%d'}, $
;               {name: 'level_id', type: '%d'}, $
; 
;               {name: 'cam0_arr_temp', type: '%f'}, $
;               {name: 'cam0_pcb_temp', type: '%f'}, $
;               {name: 'cam1_arr_temp', type: '%f'}, $
;               {name: 'cam1_pcb_temp', type: '%f'}]
;     sql_cmd = string(strjoin(fields.name, ', '), $
;                      strjoin(fields.type, ', '), $
;                      format='(%"insert into ucomp_sci (%s) values (%s)")')
;     db->execute, sql_cmd, $
;                  file_basename(file.raw_filename), $
;                  file.date_obs, $
;                  obsday_index, quality_index, level_index, $
; 
;                  file.cam0_arr_temp, $
;                  file.cam0_pcb_temp, $
;                  file.cam1_arr_temp, $
;                  file.cam1_pcb_temp, $
; 
;                  status=status
  endfor

  done:
end
