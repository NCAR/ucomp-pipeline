; docformat = 'rst'

;+
; Write an L1 file.
;
; :Params:
;   filename : in, required, type=string
;     filename to write output to
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, required, type="fltarr(nx, ny, nexts)"
;     extension data
;   ext_headers : in, required, type=list
;     list of `strarr`, each a header for the corresponding extension
;-
pro ucomp_write_l1_file, filename, primary_header, ext_data, ext_headers
  compile_opt strictarr
  on_error, 2

  dims = size(ext_data, /dimensions)
  n_extensions = dims[2]

  fits_open, filename, fcb, /write
  fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  for e = 1L, n_extensions do begin
    extname = 'test'  ; TODO: query ext_headers[e - 1] to determine name
    fits_write, fcb, $
                ext_data[*, *, e - 1], $
                ext_headers[e - 1], $
                extname=extname, /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg
  endfor
  fits_close, fcb
end
