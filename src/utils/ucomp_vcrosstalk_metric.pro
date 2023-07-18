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
;   solar_radius : in, required, type=float
;     solar radius in pixels
;-
function ucomp_vcrosstalk_metric, data, solar_radius
  compile_opt strictarr

  v = data[*, *, 3]

  dims = size(v, /dimensions)

  annulus_mask = ucomp_annulus(1.08 * solar_radius, $
                               1.14 * solar_radius, $
                               dimensions=dims[0:1])
  annulus_indices = where(annulus_mask, n_annulus_pts)

  return, total((v[annulus_indices])^2, /preserve_type) * 1.0e6 / n_annulus_pts / n_annulus_pts
end
