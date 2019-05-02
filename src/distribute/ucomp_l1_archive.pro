; docformat = 'rst'

;+
; Archive L1 files for given wave type on the HPSS.
;
; :Params:
;   wave_type : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_archive, wave_type, run=run
  compile_opt strictarr

  if (~run->config(wave_type + '/distribute_l1')) then begin
    mg_log, 'skipping distributing %s nm L1 data', wave_type, $
            name=run.logger, /info
    goto, done
  endif

  cd, current=original_dir

  l1_dir = filepath('level1', subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l1_dir)) then begin
    mg_log, 'L1 directory does not exist', name=run.logger_name, /warn
    goto, done
  endif
  cd, l1_dir

  ; TODO: make tarball of L1 data
  ; TODO: put link to L1 tarball in HPSS directory

  done:
  cd, original_dir
end
