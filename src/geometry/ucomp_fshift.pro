; docformat = 'rst'

;+
; To provide a shifted image in units of fractional pixels.
;
; :Returns:
;   oimage
;     shifted image
;
; :Params:
;   data : in, required, type=array
;     an array of any size.
;   x : in, required, type=float
;     fractional amount of shift in x direction; positive x shifts the image
;     right (i.e. sign of `x` has the same meaning as those of `SHIFT`)
;   y : in, required, type=float
;     fractional amount of shift in y direction; positive y shifts the image up
;     (i.e. sign of `y` has the same meaning as those of `SHIFT`)
;
; :Keywords:
;   interp : in, optional, type=integer, default=2
;     specify method of interpolation; default value is 2 (cubic convolution
;     interpolation). See IDL manual for details.
;
; :History:
;   version 1.0  T.Sakao written on 95.06.30 (Fri)
;           1.1  96.01.16 (Tue) Option interp added.
;-
function ucomp_fshift, data, x, y, interp=itp
  compile_opt strictarr

  p = fltarr(2, 2)
  q = fltarr(2, 2)

  p[0, 0] = -x
  p[0, 1] = 1.0
  q[0, 0] = -y
  q[1, 0] = 1.0

  _itp = n_elements(itp) eq 0L ? 2L : itp

  return, poly_2d(data, p, q, _itp)
end
