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
;   post_angle : in, required, type=float
;     post angle in degrees
;-
function ucomp_vcrosstalk_metric, data, solar_radius, post_angle
  compile_opt strictarr

  v = data[*, *, 3]

  dims = size(v, /dimensions)

  annulus_mask = ucomp_annulus(1.08 * solar_radius, $
                               1.14 * solar_radius, $
                               dimensions=dims[0:1])
  post_mask = ucomp_post_mask(dims[0:1], post_angle)
  threshold_mask = abs(v) lt 5.0

  mask = annulus_mask and post_mask and threshold_mask

  indices = where(mask, n_pts)

  return, total((v[indices])^2, /preserve_type, /nan) * 1.0e6 / n_pts / n_pts
end
