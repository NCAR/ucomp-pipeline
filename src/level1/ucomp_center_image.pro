; docformat = 'rst'

;+
; Shift the image to the center of the occulter and rotate by the p-angle.
;
; :Returns:
;   centered image as `fltarr(nx, ny)`
;
; :Params:
;   im : in, required, type=`fltarr(nx, ny)`
;     image to transform
;   geometry : in, required, type=object
;     geometry object for the given image
;-
function ucomp_center_image, im, geometry
  compile_opt strictarr

  if (total(finite(im), /integer) eq 0L) then return, im

  dims = size(im, /dimensions)
  nx = dims[0]
  ny = dims[1]

  ; perform all centering and rotating operations in one interpolation
  x0 = (float(nx) - 1.0) / 2.0
  y0 = (float(ny) - 1.0) / 2.0

  x = rebin(findgen(nx) - x0, nx, ny)
  y = transpose(rebin(findgen(ny) - y0, ny, nx))

  ; rotation matrix rotating by p-angle
  angle = geometry.p_angle   ; solar p-angle (deg)
  xp = x * cos(angle / !radeg) - y * sin(angle / !radeg)
  yp = x * sin(angle / !radeg) + y * cos(angle / !radeg)

  ; add translation offsets
  xpp = xp + geometry.occulter_center[0]
  ypp = yp + geometry.occulter_center[1]

  return, interpolate(im, xpp, ypp, missing=!values.f_nan, cubic=-0.5, /double)
end
