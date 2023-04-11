; docformat = 'rst'

;+
; Determine occulter center guess.
;
; :Returns:
;   `fltarr(2)`
;
; :Params:
;   camera_index : in, required, type=int
;     camera number: 0 (RCAM) or 1 (TCAM)
;   datetime : in, required, type=string
;     date/time in one of the formats required by `ucomp_run::epoch`
;   occulter_x : in, required, type=float
;     value of the `OCCLTR-X` FITS keyword
;   occulter_y : in, required, type=float
;     value of the `OCCLTR-Y` FITS keyword
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_occulter_guess, camera_index, datetime, occulter_x, occulter_y, $
                               run=run
  compile_opt strictarr

  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  return, ([nx, ny] - 1.0) / 2.0
end
