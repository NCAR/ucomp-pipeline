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
;   sw_index : in, required, type=integer
;     index into ucomp_sw database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_sci_insert, l0_files, obsday_index, sw_index, db, logger_name=logger_name
  compile_opt strictarr

  if (n_elements(l0_files) eq 0L) then begin
    mg_log, 'no science file to insert, skipping', name=logger_name, /info
    goto, done
  endif

  ; choose science file -- right now, just the first file
  science_files = l0_files[0]

  n_files = n_elements(science_files)
  mg_log, 'inserting %d files into ucomp_sci', n_files, name=logger_name, /info

  for f = 0L, n_files - 1L do begin
    file = science_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'wave_region', type: '''%s'''}, $
              {name: 'ucomp_sw_id', type: '%d'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_sci (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 file.wave_region, $
                 sw_index, $

                 status=status
  endfor

  done:
end
