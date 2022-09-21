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
;   line_width : in, optional, type="fltarr(1280, 1024)"
;     line width
;   dopper : in, optional, type="fltarr(1280, 1024)"
;     doppler
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
function ucomp_enhanced_intensity, intensity, $
                                   line_width, $
                                   doppler, $
                                   header, $
                                   r_outer, $
                                   radius=radius, $
                                   amount=amount, $
                                   mask=mask
  compile_opt strictarr

  _radius = mg_default(radius, 3.0)
  _amount = mg_default(amount, 2.0)

  occulter_radius = ucomp_getpar(header, 'RADIUS')
  post_angle      = ucomp_getpar(header, 'POST_ANG')

  if (keyword_set(mask)) then begin
    dims = size(intensity, /dimensions)

    occulter_mask = ucomp_occulter_mask(dims[0], dims[1], 1.01 * occulter_radius)
    field_mask    = ucomp_field_mask(dims[0], dims[1], r_outer)
    post_mask     = ucomp_post_mask(dims[0], dims[1], post_angle)

    masked_intensity = intensity * (field_mask and occulter_mask and post_mask)
  endif else begin
    masked_intensity = intensity
  endelse

  good_indices = where(intensity gt 0.5 $
                       and intensity lt 100.0, $
                       ; and line_width lt 60.0 $
                       ; and line_width gt 15.0 $
                       ; and abs(doppler) lt 30.0 $
                       ; and doppler ne 0.0, $
                       complement=bad_indices, /null)
  masked_intensity[bad_indices] = !values.f_nan

  unsharp_intensity = unsharp_mask(masked_intensity, $
                                   radius=_radius, amount=_amount)

  return, unsharp_intensity
end
