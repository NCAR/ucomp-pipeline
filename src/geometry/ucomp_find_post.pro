; docformat = 'rst'

;+
; Function to find the position angle of the occulter post in UCoMP data. This
; routine interpolates the UCoMP annulus to r-theta coordinates and averages
; over `r` to find the intensity variation with theta which is then fit with a
; gaussian to determine the location of the occulter post.
;
; :Returns:
;   position angle in degrees as float
;
; :Params:
;   im : in, required, type=`fltarr(nx, ny)`
;     the image in which to find the post angle
;   occulter_center : in, required, type=fltarr(2)
;     occulter center in pixel coordinates
;   occulter_radius : in, required, type=float
;     occulter radius in pixels
;
; :Author:
;   MLSO Software Team
;
; :History:
;   added gaussian fit and comments - 10/24/14 ST
;   replaced average with IDL built-in mean 01/07/15 GdT
;   see git log for recent changes
;-
function ucomp_find_post, im, occulter_center, occulter_radius, $
                          angle_guess=angle_guess, $
                          angle_tolerance=angle_tolerance, $
                          error=error, err_msg=err_msg
  compile_opt idl2

  _angle_guess = mg_default(angle_guess, 180.0)
  _angle_tolerance = mg_default(angle_tolerance, 30.0)

  n_theta = 4 * 360     ; sampling in theta direction
  n_radius = 70         ; sampling in radius direction

  ; this is theta from 0 to 2*pi
  theta = rebin(2.0D * !dpi * findgen(n_theta) / float(n_theta), n_theta, n_radius)

  ; this is r from the occulter radius to the field stop radius
  annulus_width = 100.0
  r = rebin(transpose(annulus_width * findgen(n_radius) / float(n_radius - 1) + occulter_radius), $
            n_theta, n_radius)

  ; convert to rectangular coordinates
  ; occulter.x and occulter.y are the center of the occulter - not the offset
  x = r * cos(theta) + occulter_center[0]
  y = r * sin(theta) + occulter_center[1]

  ; use bilinear to extract the values
  new_im = bilinear(im, x, y)

  ; extract center of annulus to avoid overlap and off-center
  new_im = new_im[*, 25:n_radius - 21]

  ; average over y
  theta_scan = mean(new_im, dimension=2)

  ; fit the inverted intensity with a gaussian, use the location of maximum as
  ; a guess for the post position
  y = median(theta_scan) - theta_scan
  x = findgen(n_theta) / (float(n_theta) - 1.0) * 360.0

  lower_limit = _angle_guess + 90.0 - _angle_tolerance
  upper_limit = _angle_guess + 90.0 + _angle_tolerance
  ind = where((x gt lower_limit) and (x lt upper_limit), count)

  x = x[ind]
  y = y[ind]

  max_value = max(y, max_pixel)
  estimates = [max(y), x[max_pixel], 6.0, 0.0, 0.0, 0.0]
  yfit = mlso_gaussfit(x, y, coeff, $
                       nterms=6, $
                       status=error, $
                       iter=n_iterations, $
                       estimates=estimates)

  case error of
    0: err_msg = ''
    1: err_msg = 'fit chi-square increasing without bound'
    2: err_msg = string(n_iterations, $
                        format='(%"fit failed to converge after %d iterations")')
    else: err_msg = string(error, format='(%"unknown GAUSSFIT status: %d")')
  endcase

  ; Rotate into coordinate system that solar position angles are referenced,
  ; namely from the top of the image (north) instead of the mathematical polar
  ; coordinate system, where theta=0 is on the right. This angle is measured
  ; CCW from North.
  return, coeff[1] - 90.0
end
