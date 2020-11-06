; docformat = 'rst'

;+
; Applies distortion correction to a sub-image `sub_image` and given the
; distortion coefficients.
;
; :Params:
;   sub_image : in, out, required, type="fltarr(nx, ny)"
;     sub-image to correct
;   dx_c : in, required, type="fltarr(3, 3)"
;     x coefficients for subimage
;   dy_c : in, required, type="fltarr(3, 3)"
;     y coefficients for subimage
;
; :Author:
;   MLSO Software Team
;-
function ucomp_apply_distortion, sub_image, dx_c, dy_c
  compile_opt strictarr

  dims = size(sub_image, /dimensions)
  nx = dims[0]
  ny = dims[1]

  x = dindgen(nx, ny) mod nx
  y = transpose(dindgen(ny, nx) mod ny)

  dist_corrected = interpolate(sub_image, $
                               x + ucomp_eval_surf(dx_c, dindgen(nx), dindgen(ny)), $
                               y + ucomp_eval_surf(dy_c, dindgen(nx), dindgen(ny)), $
                               cubic=-0.5, missing=0.0)
  return, dist_corrected
end
