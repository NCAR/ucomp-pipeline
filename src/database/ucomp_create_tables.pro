; docformat = 'rst'

;+
; Create UCoMP database tables. Will destroy existing tables!
;
; :Params:
;   run : in, required, type=object
;     `ucomp_run` object
;
; :Author:
;   MLSO Software Team
;-
pro ucomp_create_tables, run=run
  compile_opt strictarr

  log_name = 'ucomp'

  ; create MySQL database interface object
  db = mgdbmysql()
  db->connect, config_filename=run->config('database/config_filename'), $
               config_section=run->config('database/config_section'), $
               status=status, error_message=error_message
  if (status ne 0L) then begin
    mg_log, 'failed to connect to database', name=log_name, /error
    mg_log, '%s', error_message, name=log_name, /error
    return
  endif

  db->getProperty, host_name=host
  mg_log, 'connected to %s', host, name=log_name, /info

  ; tables in the order they need to be created
  ;tables = 'comp_' + ['file', 'sci', 'cal', 'eng', 'sw', 'mission', 'level']
  tables = 'ucomp_' + ['level', 'raw']

  ; delete existing tables (in reverse order), if they exist
  for t = n_elements(tables) - 1L, 0L, - 1L do begin
    mg_log, 'dropping %s...', tables[t], name=log_name, /info
    db->execute, 'drop table if exists %s', tables[t], $
                 status=status, error_message=error_message
    if (status ne 0L) then begin
      mg_log, 'problem dropping %s', tables[t], name=log_name, /error
      mg_log, '%s', error_message, name=log_name, /error
    endif
  endfor

  ; create tables
  for t = 0L, n_elements(tables) - 1L do begin
    mg_log, 'creating %s...', tables[t], name=log_name, /info

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
      mg_log, 'problem creating %s', tables[t], name=log_name, /error
      mg_log, '%s', error_message, name=log_name, /error
    endif
  endfor

  ; some tables have some initial values
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
      mg_log, 'problem inserting level %s', levels[i].name, name=log_name, /error
      mg_log, '%s', error_message, name=log_name, /error
    endif
  endfor

  ; disconnect from database
  mg_log, 'disconnecting from %s', host, name=log_name, /info
  obj_destroy, db
end


; main-level example program

date = '20181127'
config_filename = filepath('ucomp.mgalloy.pike.latest.cfg', $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())

run = ucomp_run(date, config_filename)
ucomp_create_tables, run=run

obj_destroy, run

end
