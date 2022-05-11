; docformat = 'rst'

;+
; Return an enhanced intensity image.
;
; :Uses:
;   sxpar, mpfitfun
;
; :Returns:
;   enhanced intensity image, `bytarr(1280, 1024)`
;
; :Params:
;   intensity : in, required, type="fltarr(1280, 1024)"
;     image
;   header : in, required, type=strarr
;     FITS header with geometry information
;
; :Keywords:
;   status : out, optional, type=integer
;     set to a named variable to retrieve `MPFITFUN` status, <= 0 indicates
;     definite error
;   error_msg : out, optional, type=string
;     set to named variable to retrieve `MPFITFUN` error message, empty string
;     if no error
;
; :Author:
;   MLSO Software Team
;-
function ucomp_enhanced_intensity, intensity, header, r_outer
  compile_opt strictarr

  radius     = ucomp_getpar(header, 'RADIUS')
  post_angle = ucomp_getpar(header, 'POST_ANG')

  dims = size(intensity, /dimensions)

  field_mask    = ucomp_field_mask(dims[0], dims[1], r_outer)
  occulter_mask = ucomp_occulter_mask(dims[0], dims[1], 1.01 * radius)
  post_mask     = ucomp_post_mask(dims[0], dims[1], post_angle)
  mask          = field_mask and occulter_mask and post_mask

  masked_intensity = intensity * mask

  good_indices = where(intensity gt 1.0 $
                       and intensity lt 100.0, $
                       ;and width lt 60.0 $
                       ;and width gt 15.0 $
                       ;and abs(doppler) lt 30.0 $
                       ;and doppler ne 0.0, $
                       complement=bad_indices)
  masked_intensity[bad_indices] = 0.0

  unsharp_intensity = unsharp_mask(masked_intensity, radius=3.0, amount=2.0)

  return, unsharp_intensity
end
