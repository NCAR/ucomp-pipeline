; docformat = 'rst'

;+
; Applies distortion correction to a sub-image `sub_image` given the
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
; :Keywords:
;   id : in, optional, type=string
;     unique identifier for coefficients; if present, then coefficients and 
;     intermediate values can be cached later calls
;   clear_cache : in, optional, type=boolean
;     set to clear cache if done performing any distortion corrections
;
; :Author:
;   MLSO Software Team
;-
function ucomp_apply_distortion, sub_image, dx_c, dy_c, $
                                 id=id, clear_cache=clear_cache
  compile_opt strictarr
  common ucomp_apply_distortion, coeffs_hash

  if (keyword_set(clear_cache) && obj_valid(coeffs_hash)) then begin
    obj_destroy, coeffs_hash
    return, !null
  endif

  if (n_elements(coeffs_hash) eq 0L) then coeffs_hash = hash()

  if (coeffs_hash->hasKey(id)) then begin
    s = coeffs_hash[id]
    full_x = s.full_x
    full_y = s.full_y
  endif else begin
    dims = size(sub_image, /dimensions)
    nx = dims[0]
    ny = dims[1]
  
    x = dindgen(nx, ny) mod nx
    y = transpose(dindgen(ny, nx) mod ny)
  
    full_x = x + ucomp_eval_surf(dx_c, dindgen(nx), dindgen(ny))
    full_y = y + ucomp_eval_surf(dy_c, dindgen(nx), dindgen(ny))
    if (n_elements(id) gt 0L) then begin
      coeffs_hash[id] = {full_x: full_x, full_y: full_y}
    endif
  endelse

  dist_corrected = interpolate(sub_image, full_x, full_y, $
                               cubic=-0.5, missing=0.0)
  return, dist_corrected
end
