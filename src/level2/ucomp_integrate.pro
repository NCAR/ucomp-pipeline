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
;   indices : in, optional, type=integer, default="[n_wavelengths/2 + [-1, 0, 1]]"
;     indices to weight and sum
;-
function ucomp_integrate, data, indices=indices, weights=weights
  compile_opt strictarr
  on_error, 2

  n_wavelengths = 3L

  n_indices = n_elements(indices)
  n_weights = n_elements(weights)

  if (n_indices gt 0L && n_indices ne 3) then begin
    message, string(n_indices, format='invalid number of indices %d')
  endif

  if (n_weights gt 0L && n_weights ne 3) then begin
    message, string(n_weights, format='invalid number of weights %d')
  endif

  ; set default for center index if not passed in
  if (n_elements(indices) eq 0L) then begin
    dims = size(data, /dimensions)
    _indices = (lindgen(n_wavelengths) - 1L) + dims[2] / 2L
  endif else begin
    _indices = indices
  endelse

  ; set weight for middle n_weights wavelengths
  _weights = n_elements(weights) eq 0L ? (fltarr(n_wavelengths) + 1.0) / 2.0 : weights

  ; weight the middle n_weights wavelengths and sum them up
  weighted = data[*, *, _indices]
  for w = 0L, n_wavelengths - 1L do weighted[*, *, w] *= _weights[w]
  summed = total(weighted, 3, /preserve_type)

  return, summed
end
