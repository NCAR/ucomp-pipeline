; docformat = 'rst'

;+
; Decompose a time string into hours, minutes, seconds.
;
; :Returns:
;   `strarr(3)`
;
; :Params:
;   time : in, required, type=string
;     time in the form 'HHMMSS'
;-
function ucomp_decompose_time, time
  compile_opt strictarr

  hours = strmid(time, 0, 2)
  minutes = strmid(time, 2, 2)
  seconds = strmid(time, 4, 2)

  return, [hours, minutes, seconds]
end
