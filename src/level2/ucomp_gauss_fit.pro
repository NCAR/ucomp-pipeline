; docformat = 'rst'

;+
;
; :Params:
;   all_intensities : in, required, type="fltarr(nx, ny, n_wavelengths)"
;   wavelengths : in, required, type=fltarr(n_wavelengths)
;   center_wavelength : in, required, type=float
;
; :Keywords:
;   n_terms : in, optional, type=integer, default=4
;     number of terms to use in `GAUSSFIT`
;   doppler_shift : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the doppler shift
;   line_width : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the line width, i.e., `2 * a[2]` of
;     the fit
;   peak_intensity : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the peak intensity
;   coefficients : out, optional, type="fltarr(nx, ny, n_terms)"
;     set to a named variable to retrieve the fit coefficients
;   chisq : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the fit chi-squared
;   sigma : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the fit 1-sigma error estimates
;-
pro ucomp_gauss_fit, all_intensities, $
                     wavelengths, $
                     center_wavelength, $
                     n_terms=n_terms, $
                     doppler_shift=doppler_shift, $
                     line_width=line_width, $
                     peak_intensity=peak_intensity, $
                     coefficients=fit_coefficients, $
                     chisq=fit_chisq, $
                     sigma=fit_sigma
  compile_opt strictarr

  dims = size(all_intensities, /dimensions)
  nx = dims[0]
  ny = dims[1]
  n_wavelengths = dims[2]

  _n_terms = mg_default(n_terms, 4L)

  peak_intensity = fltarr(nx, ny)
  line_width = fltarr(nx, ny)
  doppler_shift = fltarr(nx, ny)
  fit_coefficients = fltarr(nx, ny, _n_terms)
  fit_chisq = fltarr(nx, ny)
  fit_sigma = fltarr(nx, ny)

  for y = 0L, ny - 1L do begin
    for x = 0L, nx - 1L do begin
      fit = mlso_gaussfit(wavelengths, $
                          reform(all_intensities[x, y, *]), $
                          pixel_coefficients, $
                          nterms=_n_terms, $
                          chisq=chisq, $
                          sigma=sigma)

      fit_coefficients[x, y, *] = pixel_coefficients
      fit_chisq[x, y] = chisq
      fit_sigma[x, y] = sigma

      peak_intensity[x, y] = fit[0] + fit[3]
      doppler_shift[x, y] = center_wavelength - fit[1]
      line_width[x, y] = 2.0 * fit[2]
    endfor
  endfor
end
