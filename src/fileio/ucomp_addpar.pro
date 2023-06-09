; docformat = 'rst'

;+
; Add a keyword to or modify an existing keyword of a FITS header.
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;   name : in, required, type=string
;     FITS keyword name
;   value : in, optional, type=any
;     value of keyword
;
; :Keywords:
;   comment : in, optional, type=string
;     value of comment
;   before : in, optional, type=string
;     keyword name to place this keyword before
;   after : in, out, optional, type=string
;     keyword name to place this keyword after; if a named variable is passed,
;     then the AFTER value is updated to use for the next add
;   format : in, optional, type=string
;     IDL format code to use for value
;   title : in, optional, type=boolean
;     set to indicate that value is a comment header name
;-
pro ucomp_addpar, header, name, value, $
                  comment=comment, $
                  before=before, after=after, $
                  format=format, $
                  title=title
  compile_opt strictarr
  on_error, 2

  if (size(value, /n_dimensions) gt 0L) then begin
    message, string(name, format='value for %s is not a non-structure scalar')
  endif

  ; add a leading space to comment, if it's not already there
  if (n_elements(comment) gt 0L) then begin
    if (strmid(comment, 0, 1) eq ' ') then begin
      _comment = comment
    endif else if (name ne 'COMMENT') then begin
      _comment = ' ' + comment
    endif
    fxaddpar, header, name, value, _comment, $
              before=before, after=after, format=format, /null
  endif else begin
    _value = keyword_set(title) ? string(value, format='--- %s ---') : value
    fxaddpar, header, name, _value, $
              before=before, after=after, format=format, /null
  endelse

  ; new AFTER is current keyword name
  after = name
end
