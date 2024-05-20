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
