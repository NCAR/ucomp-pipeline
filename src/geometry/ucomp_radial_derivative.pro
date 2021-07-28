; docformat = 'rst'

;+
; Function to interpolate radial scans in an image, take the derivative, and
; fit the maximum with a parabola to find the location of a discontinuity. This
; routine is used to find the location of the solar limb.
;
; :Examples:
;   For example, call it like::
;
;     cent = ucomp_radial_derivative(data, dr)
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
                                  points=points
  compile_opt strictarr
  ;on_error, 2

  dims = size(data, /dimensions)

  n_scan = 360L   ; number of radial scans around circumference
  angles = dblarr(n_scan)
  radii = dblarr(n_scan)

  ; determine an initial guess for the center
  if (n_elements(center_guess) gt 0L) then begin
    x0 = double(center_guess[0])
    y0 = double(center_guess[1])

    ; TODO: remove when done
    ; mg_log, 'center guess: %0.1f, %0.1f, %0.1f', $
    ;         x0, y0, radius_guess, $
    ;         name='comp', /debug
    ; mg_log, 'center of image: %0.1f, %0.1f, %0.1f', $
    ;         (float(dims[0]) - 1.0) / 2.0, (float(dims[1]) - 1.0) / 2.0, radius_guess, $
    ;         name='comp', /debug 
  endif else begin
    x0 = double(dims[0] - 1.0) / 2.0D 
    y0 = double(dims[1] - 1.0) / 2.0D
  endelse

  n_values = dr * 2   ; number of points in interpolated radial scan

  ; make radial scans
  points = fltarr(2L, n_scan)

  for s = 0L, n_scan - 1L do begin
    ; angle for radial scan
    angles[s] = double(s) * 2.0D * !dpi / double(n_scan)

    ; x1 and y1 are start x and y coords; x2 and y2 are end coords
    x1 = x0 + (radius_guess - dr) * cos(angles[s])
    y1 = y0 + (radius_guess - dr) * sin(angles[s])
    x2 = x0 + (radius_guess + dr) * cos(angles[s])
    y2 = y0 + (radius_guess + dr) * sin(angles[s])

    ; dx and dy are spacing in x and y
    dx = (x2 - x1) / double(n_values - 1)
    dy = (y2 - y1) / double(n_values - 1)

    ; xx and yy are x- and y-coords to interpolate onto for radial scan
    xx = dindgen(n_values) * dx + x1
    yy = dindgen(n_values) * dy + y1

    ; if (keyword_set(debug)) then plots, xx, yy, color=200, /device

    ; compute radial intensity scan
    rad = interpolate(double(data), xx, yy, cubic=-0.5, missing=0.0, /double)
    rad = deriv(rad)    ; take derivative of radial intensity scan

    ; find position of maximum derivative, imax
    mx = max(rad, imax)
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

    if (keyword_set(debug)) then begin
      ans = ''
      mg_log, 'angles: %s', strjoin(strtrim(angles, 2), ', '), name='comp', /debug
      plot, rad
      oplot, [radii[s] - radius_guess + dr, radii[s] - radius_guess + dr], [0.0, 2.0 * mx]
      read, 'enter return:', ans
    endif
  endfor

  return, radii
end


; main-level example program

date = '20210725'
basename = '20210725.230123.ucomp.1074.continuum_correction.7.fts'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'unit', config_filename, /no_log)

filename = filepath(basename, $
                    subdir=[date, 'level1'], $
                    root=run->config('processing/basedir'))

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=4
fits_close, fcb

for c = 0, 1 do begin
  im = total(data[*, *, *, c], 3)
  radii = ucomp_radial_derivative(im, 330.0, 40.0, points=points)
  
  mg_image, bytscl(im, -0.1, 310.0), /new, title=string(c, format='Camera %d')
  plots, points[0, *], points[1, *], /device, color='0000ff'x, thick=2.0, linestyle=2
endfor

obj_destroy, run

end
