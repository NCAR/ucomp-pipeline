; docformat = 'rst'

;+
; Calculate a summed value from the central wavelengths from level 1 data.
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
;-
function ucomp_integrate, data, center_index=center_index
  compile_opt strictarr

  ; set default for center index if not passed in
  if (n_elements(center_index) eq 0L) then begin
    dims = size(data, /dimensions)
    _center_index = dims[2] / 2L
  endif else begin
    _center_index = center_index
  endelse

  ; set weight for middle n_weights wavelengths
  n_weights = 3L
  weights = (fltarr(n_weights) + 1.0) / 2.0

  ; weight the middle n_weights wavelengths and sum them up
  weighted = data[*, *, _center_index - n_weights / 2:_center_index + n_weights / 2]
  for w = 0L, n_weights - 1L do weighted[*, *, w] *= weights[w]
  summed = total(weighted, 3, /preserve_type)

  return, summed
end
