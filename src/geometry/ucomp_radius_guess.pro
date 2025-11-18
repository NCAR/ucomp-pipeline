; docformat = 'rst'

;+
; Determine the approximate occulter radius for a given occulter and wave
; region.
;
; :Returns:
;   radius in pixels as `float`
;
; :Params:
;   occulter_id : in, required, type=string
;     OCCLTRID value, i.e., "28", "34", etc.
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_radius_guess, occulter_id, wave_region, run=run
  compile_opt strictarr

  ; TODO: make this a function of occulter and time because it changed on
  ; 2022-02-02

;   arcsec = run->epoch('OC-' + occulter_id + '-arcsec', found=found)
;   if (~found) then arcsec = run->epoch('OC-28-arcsec')
;
;   plate_scale = run->line(wave_region, 'plate_scale')
;   radius_guess = arcsec / plate_scale

  radius_guess = 330.0
  return, radius_guess
end
