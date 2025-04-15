; docformat = 'rst'

;+
; Wrapper to retrieve UCoMP keyword values more conveniently. Removes trailing
; spaces of string values.
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
;   _extra : in, optional, type=keywords
;     keywords to `FXPAR`
;-
function ucomp_getpar, header, name, $
                       float=float, $
                       found=found, $
                       comment=comment, $
                       _extra=e
  compile_opt strictarr
  on_error, 2

  value = fxpar(header, name, comment=comment, /null, count=count, _extra=e)

  found = count gt 0L
  if (~found) then value = keyword_set(float) !values.f_nan : !null

  ; if keyword is not found and not asking whether keyword is present, then
  ; crash -- we are in an unknown state
  if (~arg_present(found) && ~found) then begin
    message, string(name, format='(%"FITS keyword %s not found")')
  endif

  if (n_elements(comment) gt 0L) then comment = strtrim(comment, 2)

  if (keyword_set(float)) then begin
    case size(value, /type) of
      0: value = !values.f_nan
      7: value = float(value)
      else:
    endcase
  endif

  if (size(value, /type) eq 7) then value = strtrim(value)

  return, value
end
