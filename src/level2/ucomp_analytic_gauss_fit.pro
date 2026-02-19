; docformat = 'rst'

;+
; Procedure to compute analytic fit to a gaussian sampled at three points for
; an array of intensities
;
; :Params:
;   blue : out, optional, type="fltarr(nx, ny)"
;     image at the blue wing
;   center : out, optional, type="fltarr(nx, ny)"
;     image at the center wavelength
;   red : out, optional, type="fltarr(nx, ny)"
;     image at the red wing
;   d_lambda : in, required, type=float
;     the wavelength spacing between the samples
;
; :Keywords:
;   doppler_shift : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the shift of the fit gaussian from
;     the center wavelength in the same units as `d_lambda`
;   line_width : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the line width [nm] as sigma (not
;     e-folding)
;   peak_intensity : out, optional, type="fltarr(nx, ny)"
;     set to a named variable to retrieve the central intensity of the gaussian
;      in the same units as `blue`, `center`, and `red`
;
; :Author:
;   S. Tomczyk
;   Modified by C. Bethge
;-
pro ucomp_analytic_gauss_fit, blue, center, red, d_lambda, $
                              doppler_shift=doppler_shift, $
                              line_width=line_width, $
                              peak_intensity=peak_intensity
  compile_opt strictarr

  ; initialize arrays
  peak_intensity = blue * 0.0D
  doppler_shift  = blue * 0.0D
  line_width     = blue * 0.0D

  positive_indices = where(blue gt 0.0 and center gt 0.0 and red gt 0.0, n_positive)
  a = alog(red[positive_indices] / center[positive_indices])
  b = alog(blue[positive_indices] / center[positive_indices])
  apb = a + b

  good_indices = where(apb lt 0.0, n_good)
  if (n_good gt 0L) then begin
    indices = positive_indices[good_indices]

    line_width[indices] = sqrt(-2.0D * d_lambda^2D / (apb[good_indices]))
    doppler_shift[indices] $
      = line_width[indices]^2 / (4.0D * d_lambda)*(a[good_indices] - b[good_indices])
    peak_intensity[indices] $
      = center[indices] * exp(doppler_shift[indices]^2 / line_width[indices]^2)
    line_width[indices] /= sqrt(2.0D)   ; convert from e-folding to sigma
  endif
end
