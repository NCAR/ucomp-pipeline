; docformat = 'rst'

;+
; Validate all the files of a given level.
;
; :Params:
;   level_name : in, required, type=string
;     name of the level to validate, i.e, "l0", "l1", or "l2"
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_validate, level_name, run=run
  compile_opt strictarr

  ; get validation spec
  option_name = string(level_name, format='(%"validation/%s_specification")')
  spec_filename = run->config(option_name)
  if (n_elements(spec_filename) eq 0L) then begin
    mg_log, 'no %s validation spec, skipping', level_name, $
            name=run.logger_name, /info
    goto, done
  endif

  ; get list of files
  case level_name of
    'l0': begin
            option_section = 'raw'
            validate_datatype = 1B
          end
    'l1': begin
            option_section = 'processing'
            validate_datatype = 0B
          end
    else: begin
        mg_log, 'validating %s not supported', level_name, $
                name=run.logger_name, /error
        goto, done
      end
  endcase
  option_name = string(option_section, format='(%"%s/basedir")')
  basedir = filepath(run.date, root=run->config(option_name))
  files = file_search(filepath('*.fts*', root=basedir), count=n_files)

  n_invalid = 0L
  for f = 0L, n_files - 1L do begin
    basename = file_basename(files[f])
    dt = strmid(basename, 0, 15)
    if (~self->epoch('process', datetime=dt)) then begin
      mg_log, 'skipping %s', basename, name=run.logger_name, /debug
      n_invalid += 1L
      continue
    endif

    is_valid = ucomp_validate_file(files[f], spec_filename, $
                                   validate_datatype=validate_datatype, $
                                   error_msg=error_msg)
    if (~is_valid) then begin
      n_invalid += 1L
      mg_log, '%s not valid', file_basename(files[f]), name=run.logger_name, /warn
      for m = 0L, n_elements(error_msg) - 1L do begin
        mg_log, error_msg[m], name=run.logger_name, /warn
      endfor
    endif
  endfor

  mg_log, '%d/%d %s files invalid', n_invalid, n_files, level_name, $
          name=run.logger_name, /info

  done:
end
