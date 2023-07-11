; docformat = 'rst'

;+
; Create string to describe the display parameters for an image.
;
; :Returns:
;   string
;
; :Params:
;   display_min : in, required, type=float
;     display min (will be taken to `power`)
;   display_max : in, required, type=float
;     display max (will be taken to `power`)
;   display_power : in, required, type=float
;     power to raise the display image to
;   display_gamma : in, optional, type=float
;     gamma used to display image
;-
function ucomp_display_image_params, display_min, $
                                     display_max, $
                                     display_power, $
                                     display_gamma
  compile_opt strictarr

  if (display_power eq 1.0) then begin
    result = string(display_min, display_max, $
                   format='min/max: %0.2f to %0.2f')
  endif else begin
    result = string(display_min, display_power, $
                   display_max, display_power, $
                   format='min/max: %0.2f!E%0.2f!N to %0.1f!E%0.2f!N')
  endelse

  if (n_elements(display_gamma) gt 0L) then begin
    result = string(result, display_gamma, format='%s, gamma: %0.1f')
  endif

  return, result
end
