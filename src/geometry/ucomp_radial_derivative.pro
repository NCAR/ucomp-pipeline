; docformat = 'rst'

;+
; Function to interpolate radial scans in an image, take the derivative, and
; fit the maximum with a parabola to find the location of a discontinuity. This
; routine is used to find the location of the solar limb.
;
; :Examples:
;   For example, call it like::
;
;     r = ucomp_radial_derivative(data, dr)
;
; :Uses:
;   parabola
;
; :Returns:
;   `dblarr(360)`, the array of radial positions is returned [pixels]
;
; :Params:
;   data : in, required, type=fltarr
;     the data image to analyze
;   radius_guess : in, required, type=float
;     the approximate radius of the discontinuity (pixels)
;   dr : in, required, type=float
;     the region +/- around radius to make the scan (pixels)
;
; :Keywords:
;   angles : out, required, type=float
;     the array of angles used (radians)
;   center_guess : in, optional, type=fltarr(2)
;     guess for the center; if not provided, use center of `data`
;   points : out, optional, type="fltarr(2, n_scan)"
;     set to a named variable to retrieve the individual occulter edge points
;   pt_weights : out, optional, type=fltarr(n_scans)
;     set to a named variable to retrieve a normalized weighting of the points
;     returned in `POINTS`
;
; :Author:
;   MLSO Software Team
;
; :Requires:
;   IDL 8.2.3
;-
function ucomp_radial_derivative, data, radius_guess, dr, $
                                  angles=angles, $
                                  center_guess=center_guess, $
                                  points=points, $
                                  pt_weights=pt_weights
  compile_opt strictarr

  dims = size(data, /dimensions)

  n_scan = 180L
  angles = dblarr(n_scan)
  radii = dblarr(n_scan)

  ; determine an initial guess for the center
  if (n_elements(center_guess) gt 0L) then begin
    x0 = double(center_guess[0])
    y0 = double(center_guess[1])
  endif else begin
    x0 = double(dims[0] - 1.0) / 2.0D
    y0 = double(dims[1] - 1.0) / 2.0D
  endelse

  n_values = dr * 2 + 1L   ; number of points in interpolated radial scan

  ; make radial scans
  points = dblarr(2L, n_scan)
  pt_weights = dblarr(n_scan)

  for s = 0L, n_scan - 1L do begin
    ; angle for radial scan
    angles[s] = double(s) * 2.0D * !dpi / double(n_scan)

    ; x1 and y1 are start x and y coords; x2 and y2 are end coords
    x1 = x0 + (radius_guess - dr) * cos(angles[s])
    y1 = y0 + (radius_guess - dr) * sin(angles[s])
    x2 = x0 + (radius_guess + dr) * cos(angles[s])
    y2 = y0 + (radius_guess + dr) * sin(angles[s])

    ; dx and dy are spacing in x and y
    dx = (x2 - x1) / double(n_values - 1.0)
    dy = (y2 - y1) / double(n_values - 1.0)

    ; xx and yy are x- and y-coords to interpolate onto for radial scan
    xx = dindgen(n_values) * dx + x1
    yy = dindgen(n_values) * dy + y1

    ; compute radial intensity scan
    rad = interpolate(double(data), xx, yy, cubic=-0.5, missing=0.0, /double)
    rad = deriv(rad)    ; take derivative of radial intensity scan

    ; find position of maximum derivative, imax
    pt_weights[s] = max(rad, imax)
    imax >= 2L
    imax <= n_values - 3L

    points[0, s] = xx[imax]
    points[1, s] = yy[imax]

    radii[s] = radius_guess - dr $
                 + ucomp_parabola([double(imax - 1.), $
                                   double(imax), $
                                   double(imax + 1.)], $
                                  [rad[imax - 1], $
                                   rad[imax], $
                                   rad[imax + 1]])

    ; if (keyword_set(debug_local)) then begin
    ;   print, s, 'angle:', angles[s]
    ;   plot, rad
    ;   oplot, [radii[s] - radius_guess + dr, radii[s] - radius_guess + dr], $
    ;          [0.0, 2.0 * point_weights[s]]
    ;   read, 'enter return:', ans
    ; endif
  endfor

  pt_weights /= total(pt_weights, /preserve_type)

  return, radii
end
