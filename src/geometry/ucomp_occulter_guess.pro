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
; 
;   camera_name = camera_index eq 0 ? 'rcam' : 'tcam'
;   xcoeffs = run->epoch(camera_name + '_camera_xoffset_coeffs', datetime=datetime)
;   ycoeffs = run->epoch(camera_name + '_camera_yoffset_coeffs', datetime=datetime)
; 
;   x0 = (nx - 1.0) / 2.0 + total(xcoeffs * [1.0, occulter_x])
;   y0 = (ny - 1.0) / 2.0 + total(ycoeffs * [1.0, occulter_y])

  x0 = (nx - 1.0) / 2.0
  y0 = (ny - 1.0) / 2.0

  return, [x0, y0]
end
