; docformat = 'rst'

function ucomp_apply_linearity, im, coeffs
  compile_opt strictarr

  dims = size(coeffs, /dimensions)
  n_poly = dims[2]

  result = reform(coeffs[*, *, 0])   ; constant coefficients
  for d = 1L, n_poly - 1L do begin
    ; TODO: use Horner's method or POLY
  endfor

  return, float(result)
end

