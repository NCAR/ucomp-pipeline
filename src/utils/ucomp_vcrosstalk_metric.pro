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
;
; :Keywords:
;   threshold_value : in, optional, type=float, default=5.0
;     threshold value for "high value" to ignore in calculation
;   max_high_points : in, optional, type=int, default=1000L
;     if there are more than `max_high_points` above `threshold`, then don't
;     mask them out
;   min_rsun : in, optional, type=float, default=1.08
;     height on inner edge of annulus for pixels tested [Rsun]
;   max_rsun : in, optional, type=float, default=1.14
;     height on outer edge of annulus for pixels tested [Rsun]
;-
function ucomp_vcrosstalk_metric, data, solar_radius, post_angle, $
                                  threshold_value=threshold_value, $
                                  max_high_points=max_high_points, $
                                  min_rsun=min_rsun, $
                                  max_rsun=max_rsun
  compile_opt strictarr

  ; TODO: adjust these, move them to the epochs file?
  _threshold_value = mg_default(threshold_value, 5.0)
  _max_high_points = mg_default(max_high_points, 1000L)
  _min_rsun = mg_default(min_rsun, 1.08)
  _max_rsun = mg_default(max_rsun, 1.14)

  v = data[*, *, 3]

  dims = size(v, /dimensions)

  annulus_mask = ucomp_annulus(_min_rsun * solar_radius, $
                               _max_rsun * solar_radius, $
                               dimensions=dims[0:1])
  post_mask = ucomp_post_mask(dims[0:1], post_angle)
  threshold_mask = abs(v) lt _threshold_value

  mask = annulus_mask and post_mask
  !null = where(threshold_mask, ncomplement=n_high_pts)

  ; check how many pixels are caught be this threshold, if too
  ; many, we shouldn't mask them out
  if (n_high_pts lt _max_high_points) then mask and= threshold_mask

  indices = where(mask, n_pts)

  return, total((v[indices])^2, /preserve_type, /nan) * 1.0e6 / n_pts / n_pts
end
