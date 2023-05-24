; docformat = 'rst'

;+
; Applies distortion correction to a sub-image `sub_image` given the
; distortion coefficients.
;
; :Returns:
;   distortion corrected image
;
; :Params:
;   sub_image : in, out, required, type="fltarr(nx, ny)"
;     sub-image to correct
;   dx_c : in, required, type="fltarr(nx, ny)"
;     x coefficients for subimage, already expanded to `sub_image` size
;   dy_c : in, required, type="fltarr(nx, ny)"
;     y coefficients for subimage, already expanded to `sub_image` size
;
; :Author:
;   MLSO Software Team
;-
function ucomp_apply_distortion, sub_image, dx_c, dy_c
  compile_opt strictarr

  dist_corrected = interpolate(sub_image, dx_c, dy_c, cubic=-0.5, missing=0.0)
  return, dist_corrected
end
