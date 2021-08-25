; docformat = 'rst'

;+
; Decompose a time string into hours, minutes, seconds.
;
; :Returns:
;   `strarr(3)`, or `float` if `FLOAT` is set
;
; :Params:
;   time : in, required, type=string
;     time in the form 'HHMMSS'
;
; :Keywords:
;   float : in, optional, type=boolean
;     if set, return a floating point time in hours
;-
function ucomp_decompose_time, time, float=float
  compile_opt strictarr

  hours   = strmid(time, 0, 2)
  minutes = strmid(time, 2, 2)
  seconds = strmid(time, 4, 2)

  if (keyword_set(float)) then begin
    return, float(hours) + float(minutes) / 60.0 + float(seconds) / 3600.0
  endif

  return, [hours, minutes, seconds]
end
