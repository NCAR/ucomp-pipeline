; docformat = 'rst'

;+
; Insert an array of L1 FITS files into the ucomp_file database table.
;
; :Params:
;   l1_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   sw_index : in, required, type=integer
;     index into ucomp_sw database table
;   database : in, required, type=object
;     `MGdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, optional, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_file_insert, l1_files, obsday_index, sw_index, db, $
                          logger_name=logger_name
  compile_opt strictarr

  ; get index for level 1 data files
  q = 'select * from ucomp_level where level=''L1'''
  level_results = db->query(q, fields=fields)
  level_index = level_results.level_id	

  ; get index for intensity files
  q = 'select * from mlso_producttype where producttype=''intensity'''
  producttype_results = db->query(q, fields=fields)
  producttype_index = producttype_results.producttype_id	

  ; get index for FITS files
  q = 'select * from mlso_filetype where filetype=''fits'''
  filetype_results = db->query(q, fields=fields)
  filetype_index = filetype_results.filetype_id	

  n_files = n_elements(l1_files)

  for f = 0L, n_files - 1L do begin
    file = l1_files[f]

    mg_log, 'ingesting %s', file.l1_basename, name=logger_name, /info

    q = 'insert into ucomp_file (file_name, date_obs, obsday_id, carrington_rotation, level_id, producttype_id, filetype_id, quality, wavetype, ntunes, ucomp_sw_id) values (''%s'', ''%s'', %d, %d, %d, %d, %d, %d, %d, %d, %d)'
    db->execute, q, $
                 file.l1_basename, $
                 file.date_obs,$
                 obsday_index, $
                 long(file.carrington_rotation), $
                 level_index, $
                 producttype_index, $
                 filetype_index, $
                 file.quality_bitmask, $
                 long(file.wave_type), $
                 file.n_unique_wavelengths, $
                 sw_index, $
                 status=status, $
                 error_message=error_message, $
                 sql_statement=sql_cmd
    if (status ne 0L) then begin
      mg_log, 'error inserting in ucomp_file table', name=logger_name, /error
      mg_log, 'status: %d, error message: %s', status, error_message, $
              name=logger_name, /error
      mg_log, 'SQL command: %s', sql_cmd, name=logger_name, /error
    endif
  endfor
end
