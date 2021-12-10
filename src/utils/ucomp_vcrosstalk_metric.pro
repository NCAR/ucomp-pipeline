; docformat = 'rst'

;+
; Calculate a metric that represents the V crosstalk.
;
; :Returns:
;   float
;
; :Params:
;   data : in, required, type="fltarr(nx, ny, 4)"
;     demodulated data
;   occulter_radius : in, required, type=float
;     occulter radius in pixels
;-
function ucomp_vcrosstalk_metric, data, occulter_radius
  compile_opt strictarr

  v = data[*, *, 3]

  dims = size(v, /dimensions)
  x = rebin(reform(findgen(dims[0]), dims[0], 1), dims[0], dims[1]) - (dims[0] - 1.0) / 2.0
  y = rebin(reform(findgen(dims[1]), 1, dims[1]), dims[0], dims[1]) - (dims[1] - 1.0) / 2.0
  r = sqrt(x^2 + y^2)

  min_radius = 1.04 * occulter_radius
  max_radius = 1.10 * occulter_radius
  annulus_indices = where(r gt min_radius and r lt max_radius, n_annulus_indices)

  return, total((v[annulus_indices])^2, /preserve_type) * 1.0e6 / n_annulus_indices
end

