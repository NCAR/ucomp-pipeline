; docformat = 'rst'

function ucomp_doppler, file, ext_data, velocity=velocity, run=run
  compile_opt strictarr

  doppler = ucomp_analytic_gauss_fit2(i1, i2, i3, d_lambda)

  rest_wavelength = run->line(file.wave_region, 'center_wavelength')
  doppler += rest_wavelength

  if (arg_present(velocity)) then begin
    c = 299792.458D
    velocity = (doppler - rest_wavelength) * c / rest_wavelength
  endif

  return, doppler
end
