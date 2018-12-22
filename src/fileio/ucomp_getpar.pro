; docformat = 'rst'

;+
; Wrapper to retrieve UCoMP keyword values more conveniently.
;
; :Returns:
;   value of keyword to look up, `!null` if not found
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;   name : in, required, type=string
;     name of FITS keyword to retrieve
;
; :Keywords:
;   float : in, optional, type=boolean
;     set to return the float value of the FITS keyword
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether the value was found
;   comment : out, optional, type=string
;     set to a named variable to retrieve the comment associated with the
;     keyword
;-
function ucomp_getpar, header, name, float=float, found=found, comment=comment, $
                       _extra=e
  compile_opt strictarr

  value = fxpar(header, name, comment=comment, /null, count=count, _extra=e)

  found = count gt 0L
  if (n_elements(comment) gt 0L) then comment = strtrim(comment, 2)

  if (keyword_set(float) && size(value, /type) eq 7) then begin
    value = float(value)
  endif

  return, value
end
