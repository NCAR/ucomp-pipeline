; docformat = 'rst'

;+
; Determine if two variables have the same type, dimensions, and value.
;
; :Returns:
;   1B if the same, 0B otherwise
;
; :Params:
;   a : in, required, type=any
;     first variable to check
;   b : in, required, type=any
;     second variable to check
;-
function ucomp_same, a, b
  compile_opt strictarr

  if (size(a, /type) ne size(b, /type)) then return, 0B
  if (size(a, /n_dimensions) ne size(b, /n_dimensions)) then return, 0B
  if (size(a, /n_dimensions) gt 0L) then begin
    if (~array_equal(size(a, /dimensions), size(b, /dimensions))) then return, 0B
    if (~array_equal(a, b)) then return, 0B
  endif else begin
    if (a ne b) then return, 0B
  endelse
  return, 1B
end
