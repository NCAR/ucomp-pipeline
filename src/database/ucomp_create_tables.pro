; docformat = 'rst'

;+
; Create UCoMP database tables. Will destroy existing tables!
;
; :Params:
;   config_filename : in, required, type=string
;     filename for configuration file to use
;
; :Author:
;   MLSO Software Team
;-
pro ucomp_create_tables, config_filename
  compile_opt strictarr

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, 'config file %s not found', config_fullpath, $
            name='ucomp/eod', /critical
    goto, done
  endif

  run = ucomp_run('20190101', 'eod', config_filename, /no_log)

  ; create MySQL database interface object
  db = mgdbmysql()
  db->connect, config_filename=run->config('database/config_filename'), $
               config_section=run->config('database/config_section'), $
               status=status, error_message=error_message
  if (status ne 0L) then begin
    mg_log, 'failed to connect to database', name=run.logger_name, /error
    mg_log, '%s', error_message, name=run.logger_name, /error
    return
  endif

  db->getProperty, host_name=host
  mg_log, 'connected to %s', host, name=run.logger_name, /info

  ; tables in the order they need to be created
  tables = 'ucomp_' + ['mission', $
                       'quality', 'level', $
                       'sw', $
                       'raw', 'eng', 'cal', 'file', 'sci']

  ; delete existing tables (in reverse order), if they exist
  for t = n_elements(tables) - 1L, 0L, - 1L do begin
    mg_log, 'dropping %s...', tables[t], name=run.logger_name, /info
    db->execute, 'drop table if exists %s', tables[t], $
                 status=status, error_message=error_message
    if (status ne 0L) then begin
      mg_log, 'problem dropping %s', tables[t], name=run.logger_name, /error
      mg_log, '%s', error_message, name=run.logger_name, /error
    endif
  endfor

  ; create tables
  for t = 0L, n_elements(tables) - 1L do begin
    mg_log, 'creating %s...', tables[t], name=run.logger_name, /info

    definition_filename = filepath(string(tables[t], format='(%"%s.tbl")'), $
                                   root=mg_src_root())
    nlines = file_lines(definition_filename)
    sql_code = strarr(nlines)
    openr, lun, definition_filename, /get_lun
    readf, lun, sql_code
    free_lun, lun
    sql_code = strjoin(sql_code, mg_newline())

    db->execute, '%s', sql_code, $
                 status=status, error_message=error_message
    if (status ne 0L) then begin
      mg_log, 'problem creating %s', tables[t], name=run.logger_name, /error
      mg_log, '%s', error_message, name=run.logger_name, /error
    endif
  endfor

  ; some tables have some initial values

  qualities = [{name: 'ok', description: 'OK images'}]
  fmt = '(%"insert into ucomp_quality (quality, description) values (''%s'', ''%s'')")'
  for i = 0L, n_elements(qualities) - 1L do begin
    cmd = string(qualities[i].name, qualities[i].description, format=fmt)
    db->execute, cmd, status=status, error_message=error_message
    if (status ne 0L) then begin
      mg_log, 'problem inserting quality %s', qualities[i].name, $
              name=run.logger_name, /error
      mg_log, '%s', error_message, name=run.logger_name, /error
    endif
  endfor

  levels = [{name: 'L0', description: 'raw data'}, $
            {name: 'L0.5', description: 'level 0.5 data (averaged L0 data)'}, $
            {name: 'L1', description: 'level 1 data (calibrated to science units)'}, $
            {name: 'L2', description: 'level 2 data (derived variables)'}, $
            {name: 'unk', description: 'unknown'}]
  fmt = '(%"insert into ucomp_level (level, description) values (''%s'', ''%s'')")'
  for i = 0L, n_elements(levels) - 1L do begin
    cmd = string(levels[i].name, levels[i].description, format=fmt)
    db->execute, cmd, status=status, error_message=error_message
    if (status ne 0L) then begin
      mg_log, 'problem inserting level %s', levels[i].name, name=run.logger_name, /error
      mg_log, '%s', error_message, name=run.logger_name, /error
    endif
  endfor

  ; TODO: insert into mission table

  ; disconnect from database
  mg_log, 'disconnecting from %s', host, name=run.logger_name, /info

  done:
  obj_destroy, db
  obj_destroy, run
end


; main-level example program

date = '20181127'
config_filename = filepath('ucomp.mgalloy.pike.latest.cfg', $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'eod', config_filename)
ucomp_create_tables, run=run

obj_destroy, run

end
