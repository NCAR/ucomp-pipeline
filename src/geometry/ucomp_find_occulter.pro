; docformat = 'rst'

;+
; Procedure to find the edge of the occulting disk.
;
; A 3-element array is returned containing: the x- and y-coordinates of the
; center of the occulter  and the occulter radius. The value of chi^2 (`CHISQ`)
; is optionally returned. The `ELLIPTICAL` keyword can change to retrieve an
; elliptical fit.
;
; :Examples:
;   For example, call like::
;
;     ucomp_find_occulter, data, radius_guess=350.0
;
; :Uses:
;   ucomp_radial_derivative, mpfitellipse, ucomp_circfit
;
; :Returns:
;   `fltarr(3)` in the form `[x, y, r]`, or, if `ELLIPTICAL` is set, `fltarr(5)`
;   in the form `[x, y, semi axis 1, semi axis 2, rotation angle]`
;
; :Params:
;   data : in, required, type="fltarr(nx, ny)"
;     the data array in which to locate the image
;
; :Keywords:
;   chisq : out, optional, type=float
;     set to a named variable to retrieve the chi^2 of the fit
;   radius_guess : in, optional, type=float, default=295. or 224.
;     the optional guess of the radius of the discontinuity
;   center_guess : in, required, type=fltarr(2)
;     guess for the center; if not provided, use center of `data`
;   dradius : in, optional, type=float, default=40.0
;     the +/- size of the radius which to scan
;   error : out, optional, type=long
;     0 if no error
;   points : out, optional, type="fltarr(2, n_points)"
;     points that are fitted to find occulter
;   pt_weights : out, optional, type=fltarr(n_points)
;     set to a named variable to retrieve a normalized weighting of the points
;     returned in `POINTS`
;   elliptical : in, optional, type=boolean
;     set to find elliptical occulter instead of circular occulter
;   eccentricity : out, optional, type=float
;     set to a named variable to retrieve the eccentricity of a valid fit when
;     `ELLIPICAL` is set
;   ellipse_angle : out, optional, type=float
;     set to a named variable to retrieve the angle of the major axis of the
;     ellipse found when `ELLIPTICAL` is set
;   remove_post : in, optional, type=boolean
;     set to remove points in the estimated location of the post from the search
;
; :Author:
;   MLSO Software Team
;-
function ucomp_find_occulter, data, $
                              chisq=chisq, $
                              radius_guess=radius_guess, $
                              center_guess=center_guess, $
                              dradius=dradius, $
                              error=error, $
                              points=points, $
                              pt_weights=pt_weights, $
                              elliptical=elliptical, $
                              eccentricity=eccentricity, $
                              ellipse_angle=ellipse_angle, $
                              remove_post=remove_post
  compile_opt strictarr

  ; if guess of radius is input, use it, otherwise use default guess
  _radius_guess = n_elements(radius_guess) eq 0L ? 330.0 : radius_guess

  ; if number of points around radius is input, use it, otherwise use default
  ; number of points (+/-) around radius for determination
  _dradius = n_elements(dradius) eq 0L ? 80.0 : dradius

  ; find limb positions, array of angles (theta) and limb positions (r) is returned
  r = ucomp_radial_derivative(data, _radius_guess, _dradius, $
                              angles=angles, $
                              center_guess=center_guess, $
                              points=points, $
                              pt_weights=pt_weights)

  x = reform(points[0, *])
  y = reform(points[1, *])

  ; remove points under the occulter post
  if (keyword_set(remove_post)) then begin
    ; post_width_angle = 14.0
    post_width_angle = 8.0
    l0_post_angle = -90.0
    theta = atan(y - center_guess[1], x - center_guess[0]) * !radeg
    non_post_indices = where(theta lt (l0_post_angle - post_width_angle / 2.0) $
                               or theta gt (l0_post_angle + post_width_angle / 2.0))

    points = points[*, non_post_indices]

    if (keyword_set(elliptical)) then begin
      x = x[non_post_indices]
      y = y[non_post_indices]
      pt_weights = pt_weights[non_post_indices]
    endif else begin
      angles = angles[non_post_indices]
      r = r[non_post_indices]
    endelse
  endif

  if (keyword_set(elliptical)) then begin
    p = mpfitellipse(x, y, $
                     weights=pt_weights, $
                     circular=0B, $
                     /tilt, $
                     /quiet, $
                     status=status, $
                     bestnorm=bestnorm)
    error = status le 0
    chisq = bestnorm / n_elements(x)

    eccentricity = sqrt(1 - (p[1] / p[0])^2)
    ellipse_angle = p[4] * !radeg
    return, p[[2, 3, 0, 1, 4]]
  endif else begin
    p = ucomp_circfit(angles, r, chisq=chisq, error=error)
    return, [center_guess, 0.0] + [p[0] / 2.0, p[1] / 2.0, p[2]]
  endelse
end
