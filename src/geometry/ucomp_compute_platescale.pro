; docformat = 'rst'

;+
; Compute the image scale (plate scale) for a given image.
;
; :Returns:
;   plate scale as float
;
; :Params:
;   radius : in, required, type=float
;     found radius of an image
;   occulter_id : in, required, type=string
;     occulter ID
;   wave_region : in, required, type=string
;     wave region, i.e., "1074"
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_compute_platescale, radius, occulter_id, wave_region, run=run
  compile_opt strictarr

  if (occulter_id eq 'NONE') then return, !values.f_nan

  ; occulter physical diameter [mm]
  occulter_diameter = run->epoch('OC-' + occulter_id + '-mm', datetime=run.date)

  ; magnification of optical system (occulter image radius/occulter radius,
  ; 10 um pixels)
  magnification = radius * 0.01 / (occulter_diameter / 2.0)

  ; focal length at this wavelength [mm]
  focal_length = run->line(wave_region, 'focal_length')

  ; image scale in [arcsec/pixel]
  ; 206264.8062471 = 360 * 60 * 60 / (2 * pi)
  platescale = 206264.8 * 0.01 / magnification / focal_length

  return, platescale
end
