; docformat = 'rst'

;+
; Produce the quick invert images:
;
; - intensity
; - enhanced intensity
; - Q/I
; - U/I
; - L/I
; - azimuth
; - line width
; - velocity
; - radial azimuth
;
; :Params:
;   wave_region : in, required, type=string
;   average_filenames : in, required, type=string
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_quick_invert, wave_region, $
                           average_filenames=average_filenames, $
                           run=run
  compile_opt strictarr

  for f = 0L, n_elements(average_filenames) - 1L do begin
    if (average_filenames[f] ne '') then begin
      run.datetime = strmid(file_basename(average_filenames[f]), 0, 8)
      ; TODO: create quick invert
    endif
  endfor
end
