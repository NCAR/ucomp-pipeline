; docformat = 'rst'

;+
; Create mask of an annulus centered at the center of the image.
;
; :Returns:
;   `bytarr` with the same size as `DIMENSIONS`
;
; :Params:
;   inner_radius : in, required, type=float
;     inner radius of the annulus [pixels]
;   outer_radius : in, required, type=float
;     outer radius of the annulus [pixels]
;
; :Keywords:
;   dimensions : in, required, type=lonarr(2)
;     dimensions of the image
;-
function ucomp_annulus, inner_radius, outer_radius, $
                        dimensions=dims
  compile_opt strictarr

  x = rebin(reform(findgen(dims[0]), dims[0], 1), dims[0], dims[1]) - (dims[0] - 1.0) / 2.0
  y = rebin(reform(findgen(dims[1]), 1, dims[1]), dims[0], dims[1]) - (dims[1] - 1.0) / 2.0
  r = sqrt(x^2 + y^2)

  return, r gt inner_radius and r lt outer_radius
end
