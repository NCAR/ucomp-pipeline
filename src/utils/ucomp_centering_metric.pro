; docformat = 'rst'

;+
; Compute correlation between images in a test annulus region.
;
; :Returns:
;   correlation between images as a `float`
;
; :Params:
;   rcam : in, required, type="fltarr(nx, ny)"
;     RCAM intensity image
;   tcam : in, required, type="fltarr(nx, ny)"
;     TCAM intensity image
;   occulter_radius : in, required, type=float
;     occulter radius in pixels
;
; :Keywords:
;   difference_median : out, optional, type=float
;     set to a named variable to retrieve the median absolute difference in the
;     test annulus
;   rcam_median : out, optional, type=float
;     set to a named variable to retrieve the median RCAM value in the test
;     annulus
;   tcam_median : out, optional, type=float
;     set to a named variable to retrieve the median TCAM value in the test
;     annulus
;-
function ucomp_centering_metric, rcam, tcam, occulter_radius, $
                                 difference_median=difference_median, $
                                 rcam_median=rcam_median, $
                                 tcam_median=tcam_median
  compile_opt strictarr

  inner_radius = 1.03 * occulter_radius
  outer_radius = 1.13 * occulter_radius

  dims = size(rcam, /dimensions)

  test_annulus = ucomp_annulus(inner_radius, outer_radius, dimensions=dims)
  good_values = rcam gt 0.0 and rcam lt 100.0 and tcam gt 0.0 and tcam lt 100.0
  annulus_indices = where(test_annulus and good_values, n_annulus_points)

  if (n_annulus_points eq 0L) then begin
    difference_median = !values.f_nan
    rcam_median = !values.f_nan
    tcam_median = !values.f_nan
    return, !values.f_nan
  endif

  difference_median = median((abs(rcam - tcam))[annulus_indices])
  rcam_median = median(rcam[annulus_indices])
  tcam_median = median(tcam[annulus_indices])

  return, correlate(rcam[annulus_indices], tcam[annulus_indices])
end
