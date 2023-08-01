; docformat = 'rst'

;+
; Calculate an summed value from level 1 data.
;
; :Returns:
;   `fltarr(nx, ny)`
;
; :Params:
;   data : in, required, type=`fltarr(nx, ny, n_wavelengths)`
;     level 1 data to integrate
;
; :Keywords:
;   center_index : in, optional, type=integer, default=n_wavelengths/2
;     index of center wavelength, if not present, assumed to be center index of
;     the dimension
;   gaussian : in, optional, type=boolean
;     set to use gaussian weighted wavelengths, i.e., 0.3-0.7-0.3
;-
function ucomp_integrate, data, center_index=center_index, gaussian=gaussian
  compile_opt strictarr

  if (n_elements(center_index) eq 0L) then begin
    dims = size(data, /dimensions)
    _center_index = dims[2] / 2L
  endif else begin
    _center_index = center_index
  endelse

  n_weights = 3L
  if (keyword_set(gaussian)) then begin
    weights = [0.3, 0.7, 0.3]
  endif else begin
    weights = (fltarr(n_weights) + 1.0)/ 2.0
  endelse

  weighted = data[*, *, _center_index - n_weights / 2:_center_index + n_weights / 2]
  for w = 0L, n_weights - 1L do weighted[*, *, w] *= weights[w]
  summed = total(weighted, 3)

  return, summed
end
