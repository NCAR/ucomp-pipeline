; docformat = 'rst'

;+
; Calculate the smoothness of a 2-dimensional image.
;
; :Returns:
;   float
;
; :Params:
;   im : in, required, type=2-dimensional numeric array
;     image to compute the smoothness of
;-
function ucomp_smoothness, im
  compile_opt strictarr

  x = float(im)

  dims = size(x, /dimensions)

  d = shift(dist(dims[0], dims[1]), dims[0] / 2, dims[1] / 2)
  outside_indices = where(d gt 750, n_outside)
  if (n_outside gt 0L) then x[outside_indices] = !values.f_nan

  norm = 2L^16  - 1.0
  s = mean(abs(laplacian(x, /nan, /edge_truncate) / norm), /nan)
  return, s
end


; main-level example program

n_iterations = 10L
norm = 2L^16  - 1.0
;im = dist(100)
;im = randomu(seed, 100, 100)
;im = fltarr(100, 100) + 100.0
im = rebin(reform(findgen(100), 100, 1), 100, 100)

im *= norm / max(im)

print, ucomp_smoothness(im), format='initial image: smoothness=%0.5f'
for i = 0L, n_iterations - 1L do begin
  im = smooth(im, 3, /edge_truncate)
  print, i + 1, ucomp_smoothness(im), format='iteration %02d: smoothness=%0.5f'
endfor

end
