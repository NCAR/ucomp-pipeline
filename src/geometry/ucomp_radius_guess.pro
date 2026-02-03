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

  ; ; occulter physical diameter [mm]
  ; occulter_diameter = run->epoch('OC-' + occulter_id + '-mm', $
  ;                                datetime=run.date, $
  ;                                found=found)
  ; 
  ; ; focal length at this wavelength [mm]
  ; focal_length = run->line(wave_region, 'focal_length')
  ; plate_scale = run->line(wave_region, 'plate_scale')
  ; 
  ; ; image scale in [arcsec/pixel]
  ; ; 206264.8062471 = 360 * 60 * 60 / (2 * pi)
  ; if (~found) then begin
  ;   radius_guess = 330.0
  ; endif else begin
  ;   arcsec = 206264.806 * (occulter_diameter / 2.0) / focal_length
  ;   radius_guess = arcsec / plate_scale
  ; endelse

  radius_guess = 330.0
  return, radius_guess
end
