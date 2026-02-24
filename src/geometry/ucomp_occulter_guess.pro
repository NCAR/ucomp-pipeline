; docformat = 'rst'

;+
; Determine occulter center guess.
;
; :Returns:
;   `fltarr(2)`
;
; :Params:
;   bkg : in, required, type="fltarr(nx, ny)"
;     background image to use to find occulter
;   camera_index : in, required, type=int
;     camera number: 0 (RCAM) or 1 (TCAM)
;   datetime : in, required, type=string
;     date/time in one of the formats required by `ucomp_run::epoch`
;   occulter_x : in, required, type=float
;     value of the `OCCLTR-X` FITS keyword
;   occulter_y : in, required, type=float
;     value of the `OCCLTR-Y` FITS keyword
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether the center was found (1B), or
;     if the default center of the image was used (0B)
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_occulter_guess, bkg, camera_index, datetime, $
                               occulter_x, occulter_y, $
                               found=found, $
                               run=run
  compile_opt strictarr

  found = 1B

  dims = size(bkg, /dimensions)
  nx = dims[0]
  ny = dims[1]

  threshold = 0.6 * median(bkg)

  ; threshold = 1.6-2.0 for 637
  ;   - RCAM: mean 3.9, median: 3.6
  ;   - TCAM: mean 3.3, median: 3.5

  ; find large connected area of values less than threshold, need about 70-80
  ; structure to remove post
  lr = label_region(morph_open(bkg lt threshold, fltarr(80, 80) + 1))

  ; assume the region in the center of the image is in the under-the-occulter
  ; region
  occulter_region = lr[nx / 2, ny / 2]

  ; find the centroid of the under-the-occulter region
  ind = where(lr eq occulter_region, count)
  xy = array_indices(lr, ind)
  center_guess = reform(mean(xy, dimension=2))

  ; sanity check to make sure algorithm is not fooled too badly
  image_center = ([nx, ny] - 1.0) / 2.0
  if (sqrt(total((image_center - center_guess)^2)) gt 30.0) then begin
    center_guess = image_center
    found = 0B
  endif

  ; initial guess for the center of the image
  return, center_guess
end
