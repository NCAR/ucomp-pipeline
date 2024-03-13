; docformat = 'rst'

;+
; Procedure to fix hot pixels in UCoMP images. Replaces data by mean of
; adjacent pixels.
;
; :Uses:
;   ucomp_config_common
;
; :Returns:
;   `fltarr(1280, 1024)`
;
; :Params:
;   data : in, required, type="fltarr(1280, 1024)"
;     raw image
;
; :Keywords:
;   hot : in, required, type=lonarr(n)
;     hot pixels
;   adjacent : in, required, type="lonarr(n, 4)"
;     pixels adjacent to hot pixels
;-
function ucomp_fix_hot, data, hot=hot, adjacent=adjacent
  compile_opt strictarr

  fixed = data

  if (n_elements(adjacent) eq 0L) then begin
    kernel = fltarr(3, 3) + 1.0
    kernel[1, 1] = 0.0
    kernel = kernel / total(kernel, /preserve_type)

    fixed[hot] = 0.0

    ; compute smoothed image, excluding zero values
    data_fill = convol(fixed, kernel, $
                       /edge_truncate, /normalize, invalid=0.0, missing=0.0)

    ; replace hot pixels with smoothed values
    fixed[hot] = data_fill[hot]
  endif else begin
    fixed[hot] = median(data[adjacent], dimension=2, /even)
  endelse

  return, fixed
end
