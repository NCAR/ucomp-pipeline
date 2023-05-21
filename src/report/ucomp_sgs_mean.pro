; docformat = 'rst'

;+
; Find the mean of an array of SGS values.
;
; :Returns:
;   float, `NaN` allowed
;
; :Params:
;   sgs_values : in, optional, type=fltarr(n)
;     SGS values to find mean of, undefined variable and `NaN`s allowed
;-
function ucomp_sgs_mean, sgs_values
  compile_opt strictarr

  if (n_elements(sgs_values) eq 0L) then return, !values.f_nan

  return, mean(sgs_values)
end
