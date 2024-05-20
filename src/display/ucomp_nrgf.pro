; docformat = 'rst'

;+
; Apply the Normalized Radial Graded Filter (NRGF) for removing the radial
; gradient from coronal images to reveal coronal structures.
;
; :Returns:
;   filtered image, the same dimensions as `im`
;
; :Params:
;   im : in, required, type="fltarr(xsize, ysize)"
;     the image to be filtered
;   occulter_radius : in, required, type=float
;     occulter radius for the image to be filtered
;
; :Keywords:
;   xcenter : in, optional, type=float, default=`(xsize - 1) / 2`
;     x-axis coordinate of the center of the solar disk's image
;   ycenter : in, optional, type=float, default=`(ysize - 1) / 2`
;     y-axis coordinate of the center of the solar disk's image
;   min_value : in, optional, type=float, default=`min(im)``
;     threshold values below this minimum value
;   max_value : in, optional, type=float, default=`max(im)``
;     threshold values above this maximum value
;   mean_profile : in, optional, type=fltarr
;     radial profile of mean used to computer NRGF
;   stddev_profile : in, optional, type=fltarr
;     radial profile of standard deviation used to computer NRGF
;
; :History:
;   adapted from a routine for the K-Coronagraph written by Silvano Fineschi
;   and Sarah Gibson
;-
function ucomp_nrgf, im, occulter_radius, $
                     xcenter=xcenter, $
                     ycenter=ycenter, $
                     min_value=min_value, $
                     max_value=max_value, $
                     mean_profile=mean_profile, $
                     stddev_profile=stddev_profile
  compile_opt strictarr

  _min_value = n_elements(min_value) eq 0L ? min(im) : max_value
  _max_value = n_elements(max_value) eq 0L ? max(im) : max_value

  ; dimensions of the input image
  dims = size(im, /dimensions)
  xsize = dims[0]
  ysize = dims[1]

  _xcenter = n_elements(xcenter) eq 0L ? (xsize - 1L) / 2.0 : xcenter
  _ycenter = n_elements(ycenter) eq 0L ? (ysize - 1L) / 2.0 : ycenter

  ; determine the minimum radii from the occulter's center to the image's edge
  d_n = ysize - _ycenter
  d_e = _xcenter
  d_s = _ycenter
  d_w = xsize - _xcenter
  ;field_radius = min([d_n, d_e, d_s, d_w])
  ;field_radius = sqrt(_xcenter^2 + _ycenter^2)  ; TODO: not in general
  field_radius = 750L
  ;field_radius = 818.89712419

  d = long(shift(dist(xsize, ysize), _xcenter, _ycenter))

  nrgf = fltarr(xsize, ysize)
  _mean_profile = fltarr(long(field_radius) - long(occulter_radius) + 1L)
  _stddev_profile = fltarr(long(field_radius) - long(occulter_radius) + 1L)

  for r = long(occulter_radius), long(field_radius) do begin
    pt_indices = where(r eq d, n_pts, /null)

    i = r - long(occulter_radius)
    m = n_elements(mean_profile) eq 0 ? mean(im[pt_indices], /nan) : mean_profile[i]
    _mean_profile[i] = m
    s = n_elements(stddev_profile) eq 0L ? stddev(im[pt_indices], /nan) : stddev_profile[i]
    _stddev_profile[i] = s

    nrgf[pt_indices] = (im[pt_indices] - m) / s
  endfor

  mean_profile = _mean_profile
  stddev_profile = _stddev_profile

  return, nrgf
end
