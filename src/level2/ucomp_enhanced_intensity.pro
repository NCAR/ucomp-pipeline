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
;
; :Keywords:
;   radius : in, optional, type=float, default=3.0
;     `radius` argument to `UNSHARP_MASK`
;   amount : in, optional, type=float, default=2.0
;     `amount` argument to `UNSHARP_MASK`
;   occulter_radius : in, optional, type=float
;     occulter radius to use if `MASK` is set
;   post_angle : in, optional, type=float
;     post angle to use if `MASK` is set
;   field_radius : in, optional, type=float
;     field radius to use if `MASK` is set
;   mask : in, optional, type=booleam
;     set to mask the result
;
; :Author:
;   MLSO Software Team
;-
function ucomp_enhanced_intensity, intensity, $
                                   radius=radius, $
                                   amount=amount, $
                                   occulter_radius=occulter_radius, $
                                   post_angle=post_angle, $
                                   field_radius=field_radius, $
                                   mask=mask
  compile_opt strictarr

  _radius = mg_default(radius, 3.0)
  _amount = mg_default(amount, 2.0)

  if (keyword_set(mask)) then begin
    dims = size(intensity, /dimensions)
    _mask = ucomp_mask(dims[0:1], $
                       field_radius=field_radius, $
                       occulter_radius=occulter_radius + 3.5, $
                       post_angle=post_angle)
    masked_intensity = intensity * _mask
  endif else begin
    masked_intensity = intensity
  endelse

  unsharp_intensity = unsharp_mask(masked_intensity, $
                                   radius=_radius, amount=_amount)

  return, unsharp_intensity
end
