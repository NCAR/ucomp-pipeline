; docformat = 'rst'

;+
; Model for `UCOMP_CIRCFIT` call.
;
; :Returns:
;   error for the given parameters
;
; :Params:
;   p : in, required, type=fltarr(3)
;     fits parameters
;-
function ucomp_circ, p
  compile_opt strictarr
  common fit, x, y, radius

  yf = p[0] * cos(x) + p[1] * sin(x) + p[2]
  return, total((yf - y)^2, /nan, /preserve_type)
end


;+
; Function to iteratively fit a circle to points in polar coordinates. The
; coordinates of the fit are returned. The value of chi^2 (chisq) is
; optionally returned.
;
; :Returns:
;    The values of the fit are returned in a three element vector in the order:
;    radius of the circle center
;    angle of the circle center
;    radius of the circle
;
; :Params:
;    theta : in, required, type=fltarr
;      the angle coordinates
;    r : in, required, type=fltarr
;      the radius coordinates
;
; :Keywords:
;   chisq : out, optional, type=float
;     set to a named variable to retrieve the value of the chisq
;   error : out, optional, type=integer
;     set to a named variable to retrieve the error status of the fit, 0 for no
;     error
;
; :Author: Tomczyk, modified by Sitongia
;-
function ucomp_circfit, theta, r, chisq=chisq, error=error
  compile_opt strictarr
  common fit, x, y, radius

  error = 0L

  ans = ' '
  debug = 0

  x = theta
  rr = r
  radius = mean(r, /nan)
  y = r - radius^2 / r
  count = 1

  while (count gt 0) do begin
    a = amoeba(1.0e-4, $
               p0=[0.0, 0.0, radius], $
               function_name='ucomp_circ', $
               function_value=values, $
               ncalls=n_calls, $
               scale=1.0, $
               nmax=10000)

    ; Check if amoeba failed: it returns -1 but usually returns an array, so
    ; use following hack rather than directly checking return value!
    if (size(a, /n_dimensions) eq 0) then begin
      a = [-1.0, -1.0, radius]
      chisq = -1.0
      error = 1L
      goto, skip
    endif

    rfit = a[0] * cos(x) + a[1] * sin(x) + a[2]
    diff = rfit - y
    chisq = total(diff^2, /nan) / float(n_elements(diff))

    rms = stddev(diff, /nan)
    bad = where(abs(diff) ge 4.0 * rms, count, complement=good)
    if (count gt 0) then begin
      radius = mean(r[good], /nan)
      x = x[good]
      rr = rr[good]
      y = rr - radius^2 / rr
      if (debug eq 1) then begin
        print, count, ' bad points:'
        plot, theta, abs(diff) / rms
        read, 'enter return', ans
      endif
    endif
  endwhile

  a = [a[0:1], radius]

  skip:
  return, a
end
