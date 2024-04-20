; docformat = 'rst'

pro ucomp_gauss_fit, all_intensities, $
                     wavelengths, $
                     center_wavelength, $
                     doppler_shift=doppler_shift, $
                     line_width=line_width, $
                     peak_intensity=peak_intensity, $
                     coefficients=fit_coefficients, $
                     chisq=fit_chisq
  compile_opt strictarr

  dims = size(all_intensities, /dimensions)
  nx = dims[0]
  ny = dims[1]
  n_wavelengths = dims[2]

  n_terms = 4L

  peak_intensity = fltarr(nx, ny)
  line_width = fltarr(nx, ny)
  doppler_shift = fltarr(nx, ny)
  fit_coefficients = fltarr(nx, ny, n_terms)
  fit_chisq = fltarr(nx, ny)

  for y = 0L, ny - 1L do begin
    for x = 0L, nx - 1L do begin
      fit = gaussfit(wavelengths, $
                     reform(all_intensities[x, y, *]), $
                     pixel_coefficients, $
                     nterms=n_terms, $
                     chisq=chisq)

      fit_coefficients[x, y, *] = pixel_coefficients
      fit_chisq[x, y] = chisq

      peak_intensity[x, y] = fit[0] + fit[3]
      doppler_shift[x, y] = center_wavelength - fit[1]
      line_width[x, y] = 2.0 * fit[2]
    endfor
  endfor
end
