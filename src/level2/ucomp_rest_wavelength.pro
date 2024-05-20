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
