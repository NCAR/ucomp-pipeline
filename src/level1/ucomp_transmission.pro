; format = 'rst'

;+
; Retrieve the transmission value for a given wave region.
;
; :Returns:
;   float
;
; :Params:
;   wave_region : in, required, type=string
;     wave region
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_transmission, wave_region, run=run
  compile_opt strictarr

  return, run->line(wave_region, 'transmission')
end
