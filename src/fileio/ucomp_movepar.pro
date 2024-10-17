; docformat = 'rst'

;+
; Move a FITS keyword to a different location in a header. Use `AFTER` or
; `BEFORE` to specify the new location. If neither is specified, the keyword
; will be moved to the end of the header.
;
; :Params:
;   header : in, out, required, type=strarr
;     FITS header
;   name : in, required, type=string
;     name of FITS keyword to move
;
; :Keywords:
;   after : in, optional, type=string
;     name of keyword to place the given keyword behind
;   before : in, optional, type=string
;     name of keyword to place the given keyword before
;-
pro ucomp_movepar, header, name, after=after, before=before
  compile_opt strictarr
  on_error, 2

  if ((n_elements(after) gt 0L) && (n_elements(before) gt 0L)) then begin
    message, 'AFTER and BEFORE cannot both be specified'
  endif

  end_line = 'END' + string(bytarr(77) + (byte(' '))[0])
  end_index = (where(strmatch(header, end_line), n_ends))[0]

  indices = findgen(n_elements(header))
  src_index = (where(strmatch(header, string(name, format='%-8s=*'))))[0]

  if (n_elements(after) gt 0L) then begin
    dst_index = (where(strmatch(header, string(after, format='%-8s=*'))))[0]
    indices[src_index] = dst_index + 0.5
  endif

  if (n_elements(before) gt 0L) then begin
    dst_index = (where(strmatch(header, string(before, format='%-8s=*'))))[0]
    indices[src_index] = dst_index - 0.5
  endif

  if ((n_elements(after) eq 0L) && (n_elements(before) eq 0L)) then begin
    if (n_ends eq 0L) then begin
      message, 'no location specificed with AFTER or BEFORE and no END of header'
    endif
    
    dst_index = end_index - 0.5
    indices[src_index] = dst_index
  endif

  header = header[sort(indices)]
end
