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
;   error_message : out, optional, type=string
;     error message if status not 0
;-
function ucomp_db_connect, filename, section, $
                           status=status, $
                           error_message=error_message
  compile_opt strictarr

  db = mgdbmysql()
  db->connect, config_filename=filename, $
               config_section=section, $
               status=status, error_message=error_message
  if (status ne 0L) then return, !null

  return, db
end
