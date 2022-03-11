; docformat = 'rst'

;+
; Format observing day hours for plots. Times 24 and greater are mod 24, i.e.,
; they are wrapped to the next day. To display minutes or seconds for a plot,
; make call before passing it to `[XY]TICKFORMAT` keyword with `MINUTES` and/or
; `SECONDS` set to `0` or `1`. For example::
;
;   IDL> !null = ucomp_hours_format(/seconds)
;   IDL> plot, t, values, xtickformat='ucomp_hours_format'
;
; Times in the plot will be formatted like::
;
;   IDL: print, ucomp_hours_format(0, 1, 25 + 27.0/60.0 + 17.0/60.0/60.0)
;   01:27:17
;
; :Returns:
;   string
;
; :Params:
;   axis : in, required, type=integer
;     axis: 0 for x-axis, 1 for y-axis, and 2 for z-axis
;   index : in, required, type=integer
;     tick mark index, starting at 0
;   value : in, required, type=double
;     date value for the tick mark
;
; :Keywords:
;   minutes : in, optional, type=boolean
;     set to `0` or `1` to use minutes in following calls
;   seconds : in, optional, type=boolean
;     set to `0` or `1` to use seconds in following calls, automatically sets
;     `MINUTES` if it is set to `1`
;-
function ucomp_hours_format, axis, index, value, $
                             minutes=minutes, seconds=seconds
  compile_opt strictarr
  common ucomp_hours_format_common, use_minutes, use_seconds

  if (n_elements(minutes) gt 0L) then use_minutes = keyword_set(minutes)
  if (n_elements(seconds) gt 0L) then use_seconds = keyword_set(seconds)

  ; quit if this call was just to set MINUTES or SECONDS
  if (n_elements(value) eq 0L) then return, ''

  hours = long(value)
  fractional = value - hours
  minutes = long(fractional * 60.0)
  seconds = long((fractional * 60.0 - minutes) * 60.0)

  ; wrap around a day past midnight
  hours mod= 24L

  case 1 of
    keyword_set(use_seconds): tick_value = string(hours, minutes, seconds, $
                                                  format='(%"%02d:%02d:%02d")')
    keyword_set(use_minutes): tick_value = string(hours, minutes, $
                                                  format='(%"%02d:%02d")')
    else: tick_value = string(hours, format='(%"%02d")')
  endcase

  return, tick_value
end
