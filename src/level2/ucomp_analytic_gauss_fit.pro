; docformat = 'rst'

;+
; Procedure to compute analytic fit to a gaussian sampled at three points for
; an array of intensities
;
; :Params:
;   i1, i2, i3 : in, required, type="fltarr(nx, ny)"
;     arrays of the intensity at three points in the line profile increasing
;     monotonically in wavelength
;    d_lambda : in, required, type=float
;      the wavelength spacing between the samples
;
; :Keywords:
;   doppler_shift : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the shift of the fit gaussian from
;     the center wavelength in the same units as `d_lambda`
;   line_width : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the line width in the same units as
;     d_lambda
;   peak_intensity : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the central intensity of the gaussian
;      in the same units as i1, i2, i3
;
; :Author:
;   S. Tomczyk
;   Modified by C. Bethge
;-
pro ucomp_analytic_gauss_fit, i1, i2, i3, d_lambda, $
                              doppler_shift=doppler_shift, $
                              line_width=line_width, $
                              peak_intensity=peak_intensity
  compile_opt strictarr

  ; initialize arrays
  peak_intensity = i1 * 0.0D
  doppler_shift  = i1 * 0.0D
  line_width     = i1 * 0.0D

  positive_indices = where(i1 gt 0.0 and i2 gt 0.0 and i3 gt 0.0, n_positive)
  a = alog(i3[positive_indices] / i2[positive_indices])
  b = alog(i1[positive_indices] / i2[positive_indices])
  apb = a + b

  good_indices = where(apb lt 0.0, n_good)
  if (n_good gt 0L) then begin
    line_width[positive_indices[good_indices]] $
      = sqrt(-2.0D * d_lambda^2D / (apb[good_indices]))
    doppler_shift[positive_indices[good_indices]] $
      = line_width[positive_indices[good_indices]]^2 / (4.0D * d_lambda)*(a[good_indices] - b[good_indices])
    peak_intensity[positive_indices[good_indices]] $
      = i2[positive_indices[good_indices]] * exp(doppler_shift[positive_indices[good_indices]]^2 / line_width[positive_indices[good_indices]]^2)  
  endif
end
