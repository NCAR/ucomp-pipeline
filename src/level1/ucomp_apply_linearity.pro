; docformat = 'rst'

;+
; Apply camera linearity correction to an image.
;
; :Returns:
;   corrected image as `fltarr(nx, ny)`
;
; :Params:
;   im : in, required, type="fltarr(nx, ny)"
;     image to correct
;   coeffs : in, required, type="fltarr(nx, ny, n_degree)"
;     polynomial coeffients for linearity correction
;-
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
