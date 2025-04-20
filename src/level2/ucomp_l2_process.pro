; docformat = 'rst'

;+
; Do the L1 -> L2 processing for a specific wave type.
;
; :Params:
;   wave_region : in, required, type=string
;     wave type to be processed
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_process, wave_region, run=run
  compile_opt strictarr

  mg_log, 'L2 processing for %s nm...', wave_region, name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_region, name=run.logger_name, /debug
    return
  endif

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then ucomp_mkdir, l2_dir, logger_name=run.logger_name

  ; level 2 individual file processing
  n_digits = floor(alog10(n_files)) + 1L
  for f = 0L, n_files - 1L do begin
    file = files[f]

    mg_log, mg_format('%*d/%d: %s', n_digits, /simple), $
            f + 1L, n_files, file.l1_basename, $
            name=run.logger_name, /info

    if (run->config('gbu/perform_check') && run->epoch('perform_gbu_check')) then begin
      if (~file.ok || file.gbu ne 0L) then begin
        mg_log, 'reject %s for quality', file.l1_basename, $
                name=run.logger_name, /warn
        continue
      endif
    endif

    ucomp_l2_file_step, 'ucomp_l2_file', file.l1_filename, run=run
    file.wrote_l2 = 1B
  endfor

  ; TODO: make this a pipeline step
  ucomp_l2_create_averages, wave_region, $
                            average_filenames=average_filenames, $
                            run=run

  for f = 0L, n_elements(average_filenames) - 1L do begin
    ucomp_l2_file_step, 'ucomp_l2_file', average_filenames[f], $
                        /thumbnail, run=run
  endfor
end
