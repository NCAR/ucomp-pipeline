; docformat = 'rst'

;+
; Given 3 points, determine the x-coordinate of the vertex of the parabola
; uniquely formed by the 3 points.
;
; :Returns:
;   float
;
; :Params:
;   x : in, required, type=fltarr(3)
;     x-coordinates of the 3 points
;   y : in, required, type=fltarr(3)
;     y-coordinates of the 3 points
;-
function ucomp_parabola, x, y
  compile_opt strictarr

  ;return, x[2] - (y[2] - y[1]) / (y[2] - 2.0 * y[1] + y[0]) - 0.5
  ;return, x[2] - (x[1] - x[0]) * ((y[2] - y[1]) / (y[2] - 2.0 * y[1] + y[0]) + 0.5)

  ; actual coordinates of the parabola formed by the 3 points
  ;denom = (x[0] - x[1]) * (x[0] - x[2]) * (x[1] - x[2])
  ;a     = (x[2] * (y[1] - y[0]) + x[1] * (y[0] - y[2]) + x[0] * (y[2] - y[1])) / denom
  ;b     = (x[2] * x[2] * (y[0] - y[1]) + x[1] * x[1] * (y[2] - y[0]) + x[0] * x[0] * (y[1] - y[2])) / denom
  ;c     = (x[1] * x[2] * (x[1] - x[2]) * y[0] + x[2] * x[0] * (x[2] - x[0]) * y[1] + x[0] * x[1] * (x[0] - x[1]) * y[2]) / denom

  ; don't need denom since it cancels in the expression we want to evaluate
  a = x[2] * (y[1] - y[0]) + x[1] * (y[0] - y[2]) + x[0] * (y[2] - y[1])
  b = x[2] * x[2] * (y[0] - y[1]) + x[1] * x[1] * (y[2] - y[0]) + x[0] * x[0] * (y[1] - y[2])

  return, - b / (2.0 * a)
end


; main-level example program

coeffs = randomu(seed, 3)
x = randomu(seed, 3)
x = x[sort(x)]
y = coeffs[0] + x * (coeffs[1] + x * coeffs[2])

xmin = ucomp_parabola(x, y)
xmin_standard = - coeffs[1] / (2.0 * coeffs[2])
print, xmin, xmin_standard, xmin - xmin_standard

n = 100
x_standard = findgen(n) / (n - 1)
y_standard = coeffs[0] + x_standard * (coeffs[1] + x_standard * coeffs[2])

plot, x, y, psym=4, xrange=[0.0, 1.0]
plots, fltarr(2) + xmin, !y.crange
plots, x_standard, y_standard, psym=3


end
