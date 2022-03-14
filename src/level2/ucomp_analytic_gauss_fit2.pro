; docformat = 'rst'

;+
; Procedure to compute analytic fit to a gaussian sampled at three points.
;
; :Returns:
;   doppler shift; the shift of the fit gaussian from the center wavelength in
;   the same units as `d_lambda`

; :Params:
;   i1 : in, required, type="fltarr(xsize, ysize)"
;     the intensity at one of three points in the line profile at regularyly
;     increasing wavelength
;   i2 : in, required, type="fltarr(xsize, ysize)"
;     the intensity at one of three points in the line profile at regularyly
;     increasing wavelength
;   i3 : in, required, type="fltarr(xsize, ysize)"
;     the intensity at one of three points in the line profile at regularyly
;     increasing wavelength
;   d_lambda : in, required, type=float
;     the wavelength spacing between the three samples
;
; :Keywords:
;   line_width : out, optional, type="fltarr(xsize, ysize)"
;     the line width in the same units as d_lambda
;   i_center : out, optional, type=fltarr
;     the central intensity of the gaussian in the same units as i1, i2, i3
;
; :Author:
;   MLSO Software Team
;-
function ucomp_analytic_gauss_fit2, i1, i2, i3, d_lambda, $
                                    line_width=line_width, $
                                    i_center=i_center
  compile_opt strictarr

  a = alog(i3 / i2)
  b = alog(i1 / i2)

  line_width = sqrt(-2.0 * d_lambda^2 / (a + b))

  doppler_shift = line_width^2 / (4.0 * d_lambda) * (a - b)

  if (arg_present(i_center)) then begin
    i_center = i2 * exp(doppler_shift^2 / line_width^2)
    i_center[where(finite(i_center, /nan), /null)] = 0.0
  endif

  doppler_shift[where(finite(doppler_shift, /nan))] = 0.0

  return, doppler_shift
end
