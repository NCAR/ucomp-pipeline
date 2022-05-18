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

  ; level 2 individual file processing
  for f = 0L, n_files - 1L do begin
    ucomp_l2_dynamics, files[f], run=run
    ucomp_l2_polarization, files[f], run=run
  endfor

  ; TODO: level 2 averaging
end
