; format = 'rst'

;+
; Retrieve the opal_radiance value for a given wave region.
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
function ucomp_opal_radiance, wave_region, run=run
  compile_opt strictarr

  return, run->line(wave_region, 'opal_radiance')
end
