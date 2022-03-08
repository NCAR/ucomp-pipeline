; docformat = 'rst'

;+
; Find means of polar coordinate grid for a single annulus at a given solar
; radii.
;
; :Returns:
;   `fltarr(nbins)`
;
; :Params:
;   image : in, required, type="fltarr(xsize, ysize)"
;     image to find the annular grid means from
;   radius : in, required, type=float
;     number of solar radii to create annulus at
;   sun_pixels : in, required, type=float
;     number of pixels corresponding to a solar radius
;
; :Keywords:
;   nbins : in, optional, type=integer, default=720
;     number of azimuthal bins
;   width : in, optional, type=float, default=0.02
;     width of annulus in Rsun
;-
function ucomp_annulus_gridmeans, image, radius, sun_pixels, $
                                  nbins=nbins, $
                                  width=width
  compile_opt strictarr

  _width = n_elements(width) eq 0L ? 0.02 : width
  _nbins = n_elements(nbins) eq 0L ? 720L : nbins

  gridmeans = fltarr(_nbins)

  dims = size(image, /dimensions)
  !null = mg_dist(dims[0], dims[1], /center, theta=theta)

  annulus_mask = ucomp_annulus(sun_pixels * (radius - _width), $
                               sun_pixels * (radius + _width), $
                               dimensions=dims)
  annulus_indices = where(annulus_mask, n_annulus_pts)
  h = histogram(theta[annulus_indices], $
                nbins=_nbins, $
                min=0.0, $
                binsize=2.0 * !pi / _nbins, $
                reverse_indices=ri)

  for i = 0L, _nbins - 1L do begin
    if (ri[i] ne ri[i + 1]) then begin
      gridmeans[i] = mean(image[annulus_indices[ri[ri[i]:ri[i + 1] - 1]]])
    endif
  endfor

  return, gridmeans
end
