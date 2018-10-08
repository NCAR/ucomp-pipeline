; docformat = 'rst'

;+
; Determine the line, i.e., wave type, that a wavelength is a part of.
;
; :Returns:
;   str ('1074', etc.) or float (central wavelength)
;
; :Params:
;   wavelength : in, required, type=float
;     wavelength to determine line
;
; :Keywords:
;   central_wavelength : in, optional, type=boolean
;     set to return the central wavelength instead of the wave type
;-
function ucomp_wave_type, wavelength, central_wavelength=central_wavelength
  compile_opt strictarr

  ; TODO: need to know possible wave_type's
  wave_types = ['1074', '1079', '1083']
  wave_centers = [1074.62, 1079.8, 1083.0]

  !null = min(abs(wave_centers - wavelength), w)
  return, keyword_set(central_wavelength) ? wave_centers[w] : wave_types[w]
end
