; docformat = 'rst'

;+
; Write the calibration to a file.
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_write_calfile, run=run
  compile_opt strictarr

  cal = run.calibration
  ; TODO: write properties of calibration out to a file
end
