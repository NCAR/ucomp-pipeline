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
; :Keywords:
;   bilinear : in, optional, type=boolean
;     set to use bilinear interpolation instead of the default cubic=-0.5
;     method
;
; :Author:
;   MLSO Software Team
;-
function ucomp_apply_distortion, sub_image, dx_c, dy_c, bilinear=bilinear
  compile_opt strictarr

  cubic_parameter = keyword_set(bilinear) ? !null : -0.5

  dist_corrected = interpolate(sub_image, dx_c, dy_c, missing=0.0, $
                               cubic=cubic_parameter)

  return, dist_corrected
end