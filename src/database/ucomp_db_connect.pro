; docformat = 'rst'

;+
; Connect to the database.
;
; :Returns:
;   `UCOMPdbMySQL` object, or `!null` if could not connect
;
; :Params:
;   filename : in, required, type=string
;     filename of database logins config file
;   section : in, optional, type=string
;     section name to use in `filename`
;
; :Keywords:
;   logger_name : in, optional, type=string
;     name of logger to log messages to
;   log_statements : in, optional, type=boolean
;     set to log all database commands
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the database creation;
;     0 if no error
;-
function ucomp_db_connect, filename, section, $
                           logger_name=logger_name, $
                           log_statements=log_statements, $
                           status=status
  compile_opt strictarr

  db = ucompdbmysql(logger_name=logger_name, log_statements=log_statements)
  db->connect, config_filename=filename, $
               config_section=section, $
               status=status, $
               error_message=error_message
  if (status ne 0L) then begin
    mg_log, 'problem connecting to database', name=logger_name, /error
    mg_log, '%s', error_message, name=logger_name, /error
    return, !null
  endif

  db->getProperty, host_name=host, $
                   client_version=client_version, $
                   client_info=client_info, $
                   server_version=server_version, $
                   server_info=server_info, $
                   proto_info=proto_info, $
                   host_info=host_info
  mg_log, 'connected to %s', host, name=logger_name, /info
  mg_log, 'client version: %s (%d)', client_info, client_version, name=logger_name, /debug
  mg_log, 'server version: %s (%d)', server_info, server_version, name=logger_name, /debug
  mg_log, 'connected: %s (%d)', host_info, proto_info, name=logger_name, /debug

  return, db
end
