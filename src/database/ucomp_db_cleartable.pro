; docformat = 'rst'


;+
; Helper routine to clear a table for a given day.
;
; :Params:
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   table : in, required, type=string
;     table to clear, i.e., ucomp_file, ucomp_eng, etc.
;   db : in, optional, type=object
;     `MGdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     name of log to send log messages to
;-
pro ucomp_db_cleartable, obsday_index, table, db, $
                         logger_name=logger_name
  compile_opt strictarr

  mg_log, 'clearing %s table', table, name=logger_name, /info
  db->execute, 'delete from %s where obsday_id=%d', $
               table, obsday_index, $
               status=status, $
               error_message=error_message, $
               sql_statement=sql_cmd, $
               n_affected_rows=n_affected_rows
  if (status ne 0L) then begin
    mg_log, 'error clearing %s table', table, $
            name=logger_name, /error
    mg_log, 'status: %d, error message: %s', status, error_message, $
            name=logger_name, /error
    mg_log, 'SQL command: %s', sql_cmd, $
            name=logger_name, /error
  endif else begin
    mg_log, '%d rows deleted', n_affected_rows, name=logger_name, /info
  endelse
end
