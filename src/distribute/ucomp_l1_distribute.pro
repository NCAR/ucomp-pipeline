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

  ; TODO: make tarball of L1 data
  ; TODO: put link to L1 tarball in HPSS directory

  ; TODO: copy L1 data into archive, etc. directories
  archive_dir = filepath('', $
                         subdir=ucomp_decompose_date(run.date), $
                         root=run->config('results/archive_basedir'))
  if (~file_test(archive_dir)) then file_mkdir, archive_dir

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

  done:
end
