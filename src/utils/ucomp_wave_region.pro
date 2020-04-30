; docformat = 'rst'

;+
; Determine the line, i.e., wave type, that a wavelength is a part of.
;
; :Returns:
;   string ('1074', etc.) or float (central wavelength if /CENTRAL_WAVELENGTH is
;   set)
;
; :Params:
;   wavelength : in, required, type=float
;     wavelength to determine line
;
; :Keywords:
;   central_wavelength : in, optional, type=boolean
;     set to return the central wavelength instead of the wave type
;-
function ucomp_wave_region, wavelength, central_wavelength=central_wavelength
  compile_opt strictarr

  ; TODO: this is information that is leaking from the lines.spec.cfg file
  wave_regions = ['530', '637', '692', '706', '789', '1074', '1079']
  wave_centers = [530.3, 637.4, 691.8, 706.2, 789.4, 1074.62, 1079.8]

  !null = min(abs(wave_centers - wavelength), w)
  return, keyword_set(central_wavelength) ? wave_centers[w] : wave_regions[w]
end
