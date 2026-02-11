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
;   mask : in, optional, type="bytarr(nx, ny)"
;     mask of which pixels to fit
;   n_fits : out, optional, type=integer
;     set to a named variable to retrive the number of Gaussian fits performed
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
                     estimates_peak_intensity=estimates_peak_intensity, $
                     estimates_xpeak=estimates_xpeak, $
                     estimates_line_width=estimates_line_width, $
                     mask=mask, $
                     min_threshold=min_threshold, $
                     max_threshold=max_threshold, $
                     n_fits=n_fits, $
                     doppler_shift=doppler_shift, $
                     line_width=line_width, $
                     peak_intensity=peak_intensity, $
                     coefficients=fit_coefficients, $
                     chisq=fit_chisq, $
                     sigma=fit_sigma
  compile_opt strictarr

  n_fits = 0L

  dims = size(all_intensities, /dimensions)
  nx = dims[0]
  ny = dims[1]
  n_wavelengths = dims[2]

  _mask = n_elements(mask) gt 0L ? mask : (bytarr(dims[0:1]) + 1B)
  _n_terms = mg_default(n_terms, 4L)

  peak_intensity = fltarr(nx, ny) + !values.f_nan
  line_width = fltarr(nx, ny) + !values.f_nan
  doppler_shift = fltarr(nx, ny) + !values.f_nan
  fit_coefficients = fltarr(nx, ny, _n_terms) + !values.f_nan
  fit_chisq = fltarr(nx, ny) + !values.f_nan
  fit_sigma = fltarr(nx, ny, _n_terms) + !values.f_nan

  mask_indices = where(mask gt 0, n_mask_indices)
  if (n_mask_indices eq 0L) then goto, done

  xy = array_indices(dims[0:1], mask_indices, /dimensions)
  for i = 0L, n_mask_indices - 1L do begin
    x = xy[0, i]
    y = xy[1, i]
    pts = reform(all_intensities[x, y, *])
    valid_indices = where(pts gt min_threshold and pts lt max_threshold)

    case _n_terms of
      3: estimates = [estimates_peak_intensity[x, y], $
                      estimates_xpeak[x, y], $
                      estimates_line_width[x, y]]
      4: estimates = [estimates_peak_intensity[x, y], $
                      estimates_xpeak[x, y], $
                      estimates_line_width[x, y], $
                      0.0]
      else: ; no estimate
    endcase

    fit = mlso_gaussfit(wavelengths[valid_indices], $
                        pts[valid_indices], $
                        pixel_coefficients, $
                        nterms=_n_terms, $
                        estimates=estimates, $
                        chisq=chisq, $
                        sigma=sigma)

    fit_coefficients[x, y, *] = pixel_coefficients
    fit_chisq[x, y] = chisq
    fit_sigma[x, y, *] = sigma

    peak_intensity[x, y] = fit[0] + fit[3]
    doppler_shift[x, y] = center_wavelength - fit[1]
    line_width[x, y] = 2.0 * fit[2]
  endfor

  done:
  n_fits = n_mask_indices
end
