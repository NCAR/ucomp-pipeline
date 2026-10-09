; docformat = 'rst'

;+
; Set the process status for the day to "processed" or "processing". Inserts
; the day, if there isn't already a row for the given date.
;
; :Params:
;   process_state : in, required, type=string
;     must be either "processed" or "processing", exactly
;   obsday_id : in, required, type=int
;     `day_id` index into `mlso_numfiles` corresponging to the observing day
;     being processed 
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
pro ucomp_db_set_process, process_state, obsday_id, db, $
                          status=status, logger_name=logger_name
  compile_opt strictarr

  sw_id = ucomp_db_sw_insert(db, status=status, logger_name=logger_name)
  hostname = mg_hostname()
  iso_format = '(C(CYI, "-", CMOI02, "-", CDI02, "T", CHI02, ":", CMI02, ":", CSI02))'
  now = string(systime(/julian), $
               format=iso_format)

  q = 'select process_id from ucomp_process where obsday_id=%d limit 1;'
  processes = db->query(q, obsday_id, status=status, count=n_processes)
  if (status ne 0L) then goto, done

  if (n_processes eq 0L) then begin
    mg_log, 'inserting a new row into ucomp_process...', name=logger_name, /info
    cmd = 'insert into ucomp_process (obsday_id, ucomp_sw_id, date_processed, status, hostname) values (%d, %d, ''%s'', ''%s'', ''%s'')'
    db->execute, cmd, obsday_id, sw_id, now, process_state, hostname, status=status
  endif else begin
    process_id = processes[0].process_id
    mg_log, 'updating row in ucomp_process to %s...', process_state, $
            name=logger_name, /info
    cmd = 'update ucomp_process set ucomp_sw_id=%d, date_processed=''%s'', status=''%s'', hostname=''%s'' where process_id=%d'
    db->execute, cmd, sw_id, now, process_state, hostname, process_id, status=status
  endelse

  done:
end
