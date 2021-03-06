; docformat = 'rst'

;+
; Package and distribute level 1 products to the appropriate locations.
;
; :Params:
;   wave_region : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_distribute, wave_region, run=run
  compile_opt strictarr

  if (~run->config(wave_region + '/distribute_l1')) then begin
    mg_log, 'skipping distributing %s nm L1 data', wave_region, $
            name=run.logger, /info
    goto, done
  endif

  ucomp_l1_archive, wave_region, run=run

  ; TODO: copy L1 data into web archive, etc. directories
  web_basedir = run->config('results/web_basedir')
  if (n_elements(web_basedir) gt 0L) then begin
    web_dir = filepath('', $
                       subdir=ucomp_decompose_date(run.date), $
                       root=web_basedir)
    ucomp_mkdir, web_dir, logger_name=run.logger_name

    process_dir = filepath('', $
                           subdir=[run.date, 'level1'], $
                           root=run->config('processing/basedir'))

    files = run->get_files(wave_region=wave_region, count=n_files)
    for f = 0L, n_files - 1L do begin
      file_copy, filepath(files[f].l1_basename, root=process_dir), $
                 archive_dir, $
                 /overwrite
    endfor
    mg_log, 'copied %d %s nm files to archive', n_files, wave_region, $
            name=run.logger_name, /info
  endif else begin
    mg_log, 'results/web_basedir not specified', name=run.logger, /warn
  endelse

  done:
end
