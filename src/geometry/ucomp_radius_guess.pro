; docformat = 'rst'

;+
; Determine the approximate radius for a given radius in pixels.
;
; :Returns:
;   radius in pixels as `float`
;
; :Params:
;   occulter_id : in, required, type=string
;     OCCLTRID value, i.e., "28", "34", etc.
;-
function ucomp_radius_guess, occulter_id, wave_region, run=run
  compile_opt strictarr

  arcsec = run->epoch('OC-' + occulter_id + '-arcsec', found=found)
  if (~found) then arcsec = run->epoch('OC-28-arcsec')

  plate_scale = run->line(wave_region, 'plate_scale')
  radius_guess = arcsec / plate_scale

  return, radius_guess
end
