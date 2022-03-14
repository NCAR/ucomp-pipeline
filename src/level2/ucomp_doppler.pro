; docformat = 'rst'

;+
; Compute the doppler, and optionally the doppler velocity.
;-
function ucomp_doppler, file, ext_data, velocity=velocity, run=run
  compile_opt strictarr

  wavelengths = file.wavelengths

  ; TODO: this is hacked together for the current cookbook/recipes, but we need
  ; a more general solution
  i1 = ext_data[*, *, 0, 0]
  i2 = ext_data[*, *, 0, 1]
  i3 = ext_data[*, *, 0, 2]
  d_lambda = wavelengths[1] - wavelengths[0]

  doppler = ucomp_analytic_gauss_fit2(i1, i2, i3, d_lambda)

  rest_wavelength = run->line(file.wave_region, 'center_wavelength')
  doppler += rest_wavelength

  if (arg_present(velocity)) then begin
    c = 299792.458D
    velocity = (doppler - rest_wavelength) * c / rest_wavelength
  endif

  return, doppler
end
