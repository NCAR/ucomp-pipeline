; docformat = 'rst'

;+
; Convert a date/time string in the form "YYYYMMDD.HHMMSS" into a date stamp of
; the form "YYYY-MM-DDTHH:MM:SSZ".
;
; :Returns:
;   string
;
; :Params:
;   datetime : in, required, type=string
;     date/time string in the form "YYYYMMDD.HHMMSS"
;-
function ucomp_dt2stamp, datetime
  compile_opt strictarr

  date_tokens = ucomp_decompose_date(strmid(datetime, 0, 8))

  if (strlen(datetime) lt 15L) then begin
    return, string(date_tokens, format='(%"%s-%s-%s")')
  endif else begin
    time_tokens = ucomp_decompose_time(strmid(datetime, 9, 6))
    return, string(date_tokens, time_tokens, format='(%"%s-%s-%sT%s:%s:%sZ")')
  endelse
end
