; docformat = 'rst'

;+
; Connect to the database.
;
; :Returns:
;   `MGdbMySQL` object, or `!null` if could not connect
;
; :Params:
;   filename : in, required, type=string
;     filename of database logins config file
;   section : in, optional, type=string
;     section name to use in `filename`
;
; :Keywords:
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the database creation;
;     0 if no error
;   logger_name : optional, type=string
;     name of logger
;-
function ucomp_db_connect, filename, section, $
                           status=status, $
                           logger_name=logger_name
  compile_opt strictarr

  db = mgdbmysql()
  db->connect, config_filename=filename, $
               config_section=section, $
               status=status, error_message=error_message
  if (status eq 0L) then begin
    db->getProperty, host_name=host
    mg_log, 'connected to %s', host, name=logger_name, /info
  endif else begin
    mg_log, 'failed to connect to database', name=logger_name, /error
    mg_log, '%s', error_message, name=logger_name, /error
    return, !null
  endelse

  return, db
end
