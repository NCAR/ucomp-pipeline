; docformat = 'rst'

;+
; Checks if the given date is in the mlso_numfiles database table. If it is, the
; corresponding day_id is returned. If it is not, a new entry in the table is
; created (day_id and obs_day fields) and the new day_id is returned.
;
; :History:
;   2017-03-20 Don Kolinski
;
; :Returns:
;   integer
;
; :Params:
;   date : in, required, type=string
;     date to insert, if needed
;   db : in, required, type=object
;     `UCOMPdbMySQL` database object
;
; :Keywords:
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the database connection,
;     0 for success
;   logger_name : in, optional, type=string
;     name of logger
;-
function ucomp_db_obsday_insert, date, db, status=status, logger_name=logger_name
  compile_opt strictarr

  obs_day = strjoin(ucomp_decompose_date(date), '-')
  obs_day_index = 0

  ; check to see if passed observation day date is in mlso_numfiles table
  q = 'select count(obs_day) from mlso_numfiles where obs_day=''%s'''
  obs_day_results = db->query(q, obs_day, status=status)
  if (status ne 0L) then goto, done
  obs_day_count = obs_day_results.count_obs_day_

  if (obs_day_count eq 0) then begin
    mg_log, 'inserting a new row in mlso_numfiles...', name=logger_name, /info
    ; if not already in table, create a new entry for the passed observation day
    db->execute, 'insert into mlso_numfiles (obs_day) values (''%s'') ', $
                 obs_day, $
                 status=status
    if (status ne 0L) then goto, done

    obs_day_index = db->query('select last_insert_id()', status=status)
    mg_log, 'query status: %d', status, name=logger_name, /debug
    if (status ne 0L) then goto, done
    mg_log, 'inserted row for %s with id %d', date, obs_day_index, $
            name=logger_name, /info
  endif else begin
    ; if it is in the database, get the corresponding index, day_id
    q = 'select day_id from mlso_numfiles where obs_day=''%s'''
    obs_day_results = db->query(q, obs_day, status=status)
    if (status ne 0L) then goto, done
    obs_day_index = obs_day_results.day_id

    ; remove multiple entries -- this shouldn't happen, it is only correcting
    ; for a corrupted database table
    for i = 1L, n_elements(obs_day_index) - 1L do begin
      mg_log, 'deleting redundant day_id=%d', obs_day_index[i], $
              name=logger_name, /warn
      db->execute, 'delete from mlso_numfiles where day_id=%d', $
                   obs_day_index[i], $
                   status=status, $
                   error_message=error_message, $
                   sql_statement=sql_cmd
      if (status ne 0L) then goto, done
    endfor

    ; keep just the first one
    mg_log, 'using day_id=%d', obs_day_index[0], name=logger_name, /debug
    obs_day_index = obs_day_index[0]
  endelse

  done:
  return, obs_day_index
end
