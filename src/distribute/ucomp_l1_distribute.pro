; docformat = 'rst'

;+
; Package and distribute level 1 products to the appropriate locations.
;
; :Params:
;   wave_type : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_distribute, wave_type, run=run
  compile_opt strictarr

  if (~run->config(wave_type + '/distribute_l1')) then begin
    mg_log, 'skipping distributing %s nm L1 data', wave_type, $
            name=run.logger, /info
    goto, done
  endif

  ucomp_l1_archive, wave_type, run=run

  ; TODO: copy L1 data into archive, etc. directories
  archive_basedir = run->config('results/archive_basedir')
  if (n_elements(archive_basedir) gt 0L) then begin
    archive_dir = filepath('', $
                           subdir=ucomp_decompose_date(run.date), $
                           root=archive_basedir)
    if (~file_test(archive_dir)) then begin
      file_mkdir, archive_dir
      ucomp_fix_permissions, archive_dir, /directory, logger_name=run.logger_name
    endif

    process_dir = filepath('', $
                           subdir=[run.date, 'level1'], $
                           root=run->config('processing/basedir'))

    run->getProperty, files=files, wave_type=wave_type, count=n_files
    for f = 0L, n_files - 1L do begin
      file_copy, filepath(files[f].l1_basename, root=process_dir), $
                 archive_dir, $
                 /overwrite
    endfor
    mg_log, 'copied %d %s nm files to archive', n_files, wave_type, $
            name=run.logger_name, /info
  endif else begin
    mg_log, 'results/archive_basedir not specified', name=run.logger, /warn
  endelse

  done:
end
