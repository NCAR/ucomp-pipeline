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
  years = date_parts[0] + doy / 365.0D - 2000.0D
  return, poly(years, double(coeffs))
end


; main-level example program

date = '20220901'
wave_offset = 2.070

;coeffs_1 = [1080.12, -0.248584]
coeffs_1 = [1079.808594, -0.234617]
coeffs_2 = double([1100.069946, -2.048975, 0.040610])

rest_wavelength_1 = ucomp_rest_wavelength(date, coeffs_1)
rest_wavelength_2 = ucomp_rest_wavelength(date, coeffs_2)

print, rest_wavelength_1, format='linear fit: %0.3f nm'
print, rest_wavelength_2, format='quadratic fit: %0.3f nm'

c = 299792.458D

center_wavelength = 1074.7
wave_region_offset = 1.89

rest_wavelength_1 -= center_wavelength + wave_region_offset - wave_offset
rest_wavelength_1 *= c / center_wavelength
print, rest_wavelength_1, format='linear fit: %0.3f km/s'

rest_wavelength_2 -= center_wavelength + wave_region_offset - wave_offset
rest_wavelength_2 *= c / center_wavelength
print, rest_wavelength_2, format='quadratic fit: %0.3f km/s'

end
