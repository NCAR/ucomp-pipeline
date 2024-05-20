; docformat = 'rst'

;+
; Calculate the smoothness of a 2-dimensional image. A perfectly smooth image
; would give a roughness of 0.0. Uniformly random data would be approximately
; 1.0 roughness.
;
; :Returns:
;   float
;
; :Params:
;   im : in, required, type=2-dimensional numeric array
;     image to compute the smoothness/roughness of
;-
function ucomp_roughness, im
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
