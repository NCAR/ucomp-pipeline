; docformat = 'rst'

;+
; Extract a radial intensity profile from a FITS file.
;
; :Returns:
;   profile as a `fltarr(n_radii)`
;
; :Params:
;   component : in, required, type="fltarr(m, n)"
;     intensity, Q, or U image
;   sun_pixels : in, required, type=float
;     number of pixels corresponding to a solar radius
;
; :Keywords:
;   standard_deviation : out, optional, type=fltarr
;     set to a named variable to retrieve the standard deviation of intensity
;     profile
;-
function ucomp_radial_profile, component, sun_pixels, $
                               standard_deviation=standard_deviation

  ; center of array
  dims = size(component, /dimensions)
  center_x = (dims[0] - 1.0) / 2.0
  center_y = (dims[1] - 1.0) / 2.0

  ; angles for full circle in radians
  theta = findgen(360) * !dtor

  n_radii      = 90
  start_radius = 1.05
  radius_step  = 0.02
  radii = radius_step * findgen(n_radii) + start_radius

  profile = fltarr(n_radii)
  standard_deviation = fltarr(n_radii)
  for r = 0L, n_radii - 1L do begin
    x = sun_pixels * radii[r] * cos(theta) + center_x
    y = sun_pixels * radii[r] * sin(theta) + center_y
    profile[r] = mean(component[round(x), round(y)])
    standard_deviation[r] = stddev(component[round(x), round(y)])
  endfor

  return, profile
end
