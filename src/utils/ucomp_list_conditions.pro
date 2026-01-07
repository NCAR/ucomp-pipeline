; docformat = 'rst'

;+
; Returns string list of conditions that failed.
;
; :Returns:
;   string
;
; :Params:
;   bitmask : in, required, type=unsigned long
;     quality/GBU bitmask
;   conditions : in, required, type=array of structures
;     array of structures of conditions with fields "mask" and "name"
;-
function ucomp_list_conditions, bitmask, conditions
  compile_opt strictarr

  bad_condition_indices = where(bitmask and conditions.mask, /null)
  bad_conditions = strjoin(conditions[bad_condition_indices].name, '|')

  return, bad_conditions
end
