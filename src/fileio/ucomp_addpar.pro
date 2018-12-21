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
;   after : in, optional, type=string
;     keyword name to place this keyword before
;   format : in, optional, type=string
;     IDL format code to use for value
;-
pro ucomp_addpar, header, name, value, $
                  comment=comment, $
                  before=before, after=after, $
                  format=format
  compile_opt strictarr

  ; add a leading space to comment, if it's not already there
  if (n_elements(comment) gt 0L) then begin
    if (strmid(comment, 0, 1) eq ' ') then begin
      _comment = comment
    endif else begin
      _comment = ' ' + comment
    endelse
  endif

  fxaddpar, header, name, value, _comment, $
            before=before, after=after, format=format, /null
end
