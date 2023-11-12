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
pro ucomp_db_create_tables, config_filename
  compile_opt strictarr

  mode = 'eod'

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, 'config file %s not found', config_fullpath, $
            name='ucomp/' + mode, /critical
    goto, done
  endif

  date = '20190101'   ; using arbitrary date
  run = ucomp_run(date, mode, config_filename, /no_log)
  if (not obj_valid(run)) then goto, done

  if (~run->config('database/update')) then begin
    mg_log, 'config file indicates no updating database, exiting...', $
            name=run.logger_name, /warn
    goto, done
  endif

  ; connect to the database
  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        status=status, $
                        log_statements=run->config('database/log_statements'))
  if (status ne 0) then goto, done

  ; tables in the order they need to be created
  tables = 'ucomp_' + ['mission', $
                       'quality', 'level', $
                       'sw', $
                       'raw', 'eng', 'cal', 'file', $
                       'sci_dynamics', 'sci_polarization']

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
                                   subdir=['..', '..', 'resource', 'database'], $
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
      mg_log, 'SQL cmd: %s', sql_code, name=run.logger_name, /error
      goto, done
    endif
  endfor

  ; remove old UCoMP product types from mlso_producttype table
  db->execute, 'delete from mlso_producttype where description like "UCoMP%"', $
               status=status, error_message=error_message, $
               sql_statement=sql_cmd
  if (status ne 0L) then begin
    mg_log, 'problem removing old UCoMP product types', $
            name=run.logger_name, /error
    mg_log, 'status: %d, error message: %s', status, error_message, $
            name=run.logger_name, /error
    mg_log, 'SQL command: %s', sql_cmd, name=run.logger_name, /error
    goto, done
  endif

  ; populate some tables with initial values
  insert_tables = ['ucomp_quality', 'ucomp_level', 'ucomp_mission', $
                   'mlso_producttype']
  for t = 0L, n_elements(insert_tables) - 1L do begin
    mg_log, 'populating %s', insert_tables[t], name=log_name, /info

    definition_filename = filepath(string(insert_tables[t], $
                                          format='(%"%s_insert.tbl")'), $
                                   subdir=['..', '..', 'resource', 'database'], $
                                   root=mg_src_root())
    nlines = file_lines(definition_filename)
    sql_code = strarr(nlines)
    openr, lun, definition_filename, /get_lun
    readf, lun, sql_code
    free_lun, lun

    for s = 0L, nlines - 1L do begin
      db->execute, '%s', sql_code[s], $
                   status=status, error_message=error_message
      if (status ne 0L) then begin
        mg_log, 'problem populating %s with statement %s', $
                insert_tables[t], $
                sql_code[s], $
                name=run.logger_name, /error
        mg_log, '%s', error_message, name=run.logger_name, /error
      endif
    endfor
  endfor

  ; disconnect from database
  mg_log, 'disconnecting from %s', db.host_name, name=run.logger_name, /info

  done:
  if (obj_valid(db)) then obj_destroy, db
  if (obj_valid(run)) then obj_destroy, run
end


; main-level example program

config_filename = filepath('ucomp.latest.cfg', $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

ucomp_db_create_tables, config_filename

end
