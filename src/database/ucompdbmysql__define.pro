; docformat = 'rst'

pro ucompdbmysql::report_error, sql_statement=sql_cmd, $
                               status=status, $
                               error_message=error_message
  compile_opt strictarr

  if (status ne 0L) then begin
    mg_log, 'error with SQL statement', name=self.logger_name, /error
    mg_log, 'status: %d', status, name=self.logger_name, /error
    mg_log, '%s', error_message, name=self.logger_name, /error
    mg_log, 'SQL command: %s', sql_cmd, name=self.logger_name, /error
  endif
end


pro ucompdbmysql::report_warnings, sql_statement=sql_cmd, n_warnings=n_warnings
  compile_opt strictarr

  if (n_warnings gt 0L) then begin
    mg_log, '%d warnings for SQL statement', n_warnings, $
            name=self.logger_name, /error
    mg_log, 'SQL command: %s', sql_cmd, name=self.logger_name, /error
    warnings = self->query('show warnings', status=status)
    if (status ne 0L) then begin
      mg_log, 'error retrieving warnings', name=self.logger_name, /error
    endif

    for w = 0L, n_warnings - 1L do begin
      mg_log, '%s [%d]: %s', $
              warnings[w].level, warnings[w].code, warnings[w].message, $
              name=self.logger_name, /error
    endfor
  endif
end


pro ucompdbmysql::report_statement, mysql_statement
  compile_opt strictarr

  if (self.log_statements) then begin
    mg_log, mysql_statement, name=self.logger_name, /debug
  endif
end


pro ucompdbmysql::setProperty, _extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0L) then self->mgdbmysql::setProperty, _extra=e
end


pro ucompdbmysql::getProperty, _ref_extra=e
  compile_opt strictarr

  if (n_elements(e) gt 0) then self->mgdbmysql::getProperty, _strict_extra=e
end


pro ucompdbmysql::cleanup
  compile_opt strictarr

  self->mgdbmysql::cleanup
end


function ucompdbmysql::init, logger_name=logger_name, $
                             log_statements=log_statements, $
                             _extra=e
  compile_opt strictarr

  status = self->mgdbmysql::init(_extra=e)
  if (status ne 1) then return, status

  self.log_statements = keyword_set(log_statements)
  if (n_elements(logger_name) gt 0L) then self.logger_name = logger_name

  return, 1
end


pro ucompdbmysql__define
  compile_opt strictarr

  !null = { UCoMPdbMySQL, inherits MGdbMySQL, $
            logger_name: '', $
            log_statements: 0B }
end


; main-level example

; the below generates a warning because of date_obs has seconds=60
db = ucompdbmysql()
db->connect, config_filename='/home/mgalloy/.mysqldb', $
             config_section='mgalloy@webdev'
db->execute, 'insert into kcor_img (file_name, date_obs, date_end, obs_day, carrington_rotation, level, quality, producttype, filetype, numsum, exptime) values (''%s'', ''%s'', ''%s'', %d, %d, %d, %d, %d, %d, %d, %f)', $
             '20131025_171960_kcor_l1', $
             '2013-10-25 17:19:60', $
             '2013-10-25 17:19:44', $
             1300, 2142, 1, 75, 1, 1, 512, 0.0001, $
             status=status
last_insert_id = db->query('select last_insert_id()')
db->execute, 'delete from kcor_img where img_id=%d', last_insert_id.last_insert_id__

obj_destroy, db

end
