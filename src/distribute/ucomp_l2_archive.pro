; docformat = 'rst'

;+
; Archive L2 files for given wave type on the HPSS.
;
; :Params:
;   wave_type : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_archive, wave_type, run=run
  compile_opt strictarr

  if (~run->config(wave_type + '/distribute_l2')) then begin
    mg_log, 'skipping distributing %s nm L2 data', wave_type, $
            name=run.logger, /info
    goto, done
  endif

  cd, current=original_dir

  l2_dir = filepath('level2', subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir)) then begin
    mg_log, 'L2 directory does not exist', name=run.logger_name, /warn
    goto, done
  endif
  cd, l2_dir

  ; TODO: make tarball of L2 data
  ; TODO: put link to L2 tarball in HPSS directory

  done:
  cd, original_dir
end
