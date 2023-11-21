; docformat = 'rst'

;+
; Compute the model fit for the rest wavelength for a given day.
;
; :Returns:
;   wavelength in nm
;
; :Params:
;   date : in, required, type=string
;     date to compute rest wavelength for in the format YYYYMMDD
;   coeffs : in, required, type=fltarr(n)
;     coefficients for the order `n` polynomial fit of the rest wavelength
;     model
;-
function ucomp_rest_wavelength, date, coeffs
  compile_opt strictarr

  date_parts = long(ucomp_decompose_date(date))
  doy = mg_ymd2doy(date_parts[0], date_parts[1], date_parts[2])
  years = date_parts[0] + doy / 365.0 - 2000.0
  return, poly(years, coeffs)
end


; main-level example program

coeffs = [1080.12, -0.248584]
rest_wavelength = ucomp_rest_wavelength('20220901', coeffs)

print, rest_wavelength, format='%0.2f nm'

c = 299792.458D

nominal_wavelength = 1074.7
print, (rest_wavelength - 1074.7) * c / nominal_wavelength, $
       format='%0.2f km/s'

nominal_wavelength = 1079.8
wave_offset = 2.040
print, (rest_wavelength - 1074.7 - 1.89 + wave_offset) * c / nominal_wavelength, $
       format='%0.2f km/s'

end
