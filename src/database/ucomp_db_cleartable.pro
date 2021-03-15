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
;     `UCOMPdbMySQL` database connection to use
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
               n_affected_rows=n_affected_rows
  if (status eq 0L) then begin
    mg_log, '%d rows deleted', n_affected_rows, name=logger_name, /info
  endif
end
