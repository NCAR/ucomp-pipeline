;+
;  Name: gauss_fit_3
;
;  Description:
;    procedure to compute analytic fit to a gaussian sampled at three points
;
;  Input:
;    x - wavelengths - must be equally spaced
;    y - intensities - must be positive and the peak must be contained between the wavelength extrema
;
;  Output:
;    wave0 the central wavelength of the fit gaussian
;    width:  the linewidth in the same units as the wavelengths
;    i_cent: the central intensity of the gaussian in the same units as the intensity
;
;  Author: S. Tomczyk
;  Modified by: C. Bethge
;-
pro gauss_fit_3,x,y,wave0,width,i_cent

  if (y[0] lt 0 or y[1] lt 0 or y[2] lt 0) then begin
    width = 0D
    wave0 = 0D
    i_cent = 0D
    goto, skip_calc
  endif

  i1 = y[0]
  i2 = y[1]
  i3 = y[2]

  a=alog(i3/i2)
  b=alog(i1/i2)

  d_lambda = x[1]-x[0]
  if (-2D*d_lambda^2D/(a+b)) lt 0 then begin
    width = 0D
    wave0 = 0D
    i_cent = 0D
    goto, skip_calc
  endif

  width = sqrt( -2D*d_lambda^2D/(a+b) )
  wave0 = width^2D/(4D*d_lambda)*(a-b)
  i_cent=i2*exp(wave0^2D/width^2D)
  wave0 = wave0 + x[1]

  skip_calc:
end
