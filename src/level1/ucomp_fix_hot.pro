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
  fixed[hot] = median(data[adjacent], dimension=2, /even)

  return, fixed
end
