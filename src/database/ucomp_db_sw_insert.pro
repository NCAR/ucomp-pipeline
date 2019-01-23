; docformat = 'rst'

;+
; Checks if the current version of the pipeline is in the ucomp_sw database
; table. If it is, the corresponding sw_id is returned. If it is not, a new
; entry in the table is created and the new sw_id is returned.
;
; :Returns:
;   integer
;
; :Params:
;   database : in, required, type=object
;     `MGdbMySQL` database object
;
; :Keywords:
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the database connection,
;     0 for success
;   logger_name : in, optional, type=string
;     name of logger
;-
function ucomp_db_sw_insert, db, status=status, logger_name=logger_name
  compile_opt strictarr

  version = ucomp_version(revision=revision)

  ; check to see if passed observation day date is in mlso_numfiles table
  q = 'select count(sw_id) from ucomp_sw where sw_version=''%s'' and sw_revision=''%s'''
  sw_id_results = db->query(q, version, revision)
  sw_id_count = sw_id_results.count_sw_id_

  if (sw_id_count eq 0) then begin
    date_format = '(C(CYI, "-", CMOI2.2, "-", CDI2.2, "T", CHI2.2, ":", CMI2.2, ":", CSI2.2))'
    release_date = string(julday(), format=date_format)

    mg_log, 'inserting new version %s [%s]', version, revision, $
            name=logger_name, /info

    ; if not already in table, create a new entry for the sw version/revision
    db->execute, 'insert into ucomp_sw (release_date, sw_version, sw_revision) values (''%s'', ''%s'', ''%s'')',
                 release_date, version, revision, $
                 status=status, error_message=error_message, sql_statement=sql_cmd
    if (status ne 0L) then begin
      mg_log, 'error inserting into ucomp_sw table', $
              name=logger_name, /error
      mg_log, 'status: %d, error message: %s', status, error_message, $
              name=logger_name, /error
      mg_log, 'SQL command: %s', sql_cmd, $
              name=logger_name, /error

      sw_index = 0L
      goto, done
    endif

    sw_index = db->query('select last_insert_id()')
  endif else begin
    ; if it is in the database, get the corresponding index
    q = 'select sw_id from ucomp_sw where sw_version=''%s'' and sw_revision=''%s'''
    sw_id_results = db->query(q, version, revision)
    sw_index = sw_id_results.sw_id

    ; remove multiple entries
    if (n_elements(obs_day_index) gt 1L) then begin
      for i = 1L, n_elements(obs_day_index) - 1L do begin
        mg_log, 'deleting redundant sw_id=%d', sw_index[i], $
                name=logger_name, /warn
        db->execute, 'delete from ucomp_sw where sw_id=%d', $
                     sw_index[i], $
                     status=status, $
                     error_message=error_message, $
                     sql_statement=sql_cmd
        if (status ne 0L) then begin
          mg_log, 'error deleting redundant ucomp_sw entry', $
                  name=logger_name, /error
          mg_log, 'status: %d, error message: %s', status, error_message, $
                  name=logger_name, /error
          mg_log, 'SQL command: %s', sql_cmd, $
                  name=logger_name, /error
        endif
      endfor

      ; keep just the first one
      mg_log, 'keeping sw_id=%d', sw_index[0], name=logger_name, /debug
      sw_index = sw_index[0]
    endif
  endelse

  done:

  return, sw_index
end
