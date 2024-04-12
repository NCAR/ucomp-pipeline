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

  fixed_data = data

  ; TODO verify the function is never called by mistake with adjacent = 0
  if (n_elements(adjacent) eq 0L) then begin
  ; define kernel
    kernel = fltarr(3, 3) + 1.0
    kernel[1, 1] = 0.0
    kernel = kernel / total(kernel, /preserve_type)

    ; set to zero NaN and hot pixels
    bad = where(~finite(fixed_data), nbad)
    if (nbad gt 0) then fixed_data[bad] = 0.0
    fixed_data[hot] = 0.0

    ; compute median to use in case of large clusters of hot pixels
    pos = where(fixed_data gt 0, count)
    case count of
      0: med = 0.0   ; TODO: not sure what is correct here
      1: med = fixed_data[pos]
      else: med = median(fixed_data[pos])
    endcase
    ; compute array for filling hot pixels, excluding zeros
    data_fill = convol(fixed_data, kernel, /edge_truncate, /normalize, $
                       invalid=0.0, missing=med)
    ; replace hot pixels
    fixed_data[hot] = data_fill[hot]
  endif else begin
    fixed_data[hot] = median(data[adjacent], dimension=2, /even)
  endelse

  return, fixed_data
end
