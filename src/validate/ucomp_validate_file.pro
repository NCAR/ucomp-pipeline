; docformat = 'rst'

pro ucomp_validate_file, date, config_filename, filename, level
  compile_opt strictarr

  run = ucomp_run(date, 'validate', config_filename, /no_log)
  if (not obj_valid(run)) then goto, done

  l0_header_spec_filename = run->config("validation/l0_specification")

  if (level eq 0L) then begin
    is_valid = ucomp_validate_l0_file(filepath(filename, $
                                               subdir=date, $
                                               root=run->config("raw/basedir")), $
                                      l0_header_spec_filename, $
                                      error_msg=error_msg)
  endif else begin
    print, 'only level 0 files are supported currently'
  endelse

  print, is_valid ? 'Valid' : 'Not valid'
  if (~is_valid) then begin
    print, transpose(error_msg)
  endif

  done:
  if (obj_valid(run)) then obj_destroy, run
end
