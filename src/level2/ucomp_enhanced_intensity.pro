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
;     intensity image
;   line_width : in, optional, type="fltarr(1280, 1024)"
;     line width image
;   doppler : in, optional, type="fltarr(1280, 1024)"
;     doppler image
;   header : in, required, type=strarr
;     FITS header with geometry information
;   r_outer : in, optional, type=float
;     field radius to mask by
;
; :Keywords:
;   radius : in, optional, type=float, default=3.0
;     `radius` argument to `UNSHARP_MASK`
;   amount : in, optional, type=float, default=2.0
;     `amount` argument to `UNSHARP_MASK`
;   mask : in, optional, type=booleam
;     set to mask the result
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
    _mask = ucomp_mask(dims[0:1], $
                       field_radius=r_outer, $
                       occulter_radius=1.01 * occulter_radius, $
                       post_angle=post_angle)
    masked_intensity = intensity * _mask
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
