; docformat = 'rst'

;+
; Read a UCoMP raw data file.
;
; :Params:
;   filename : in, required, type=string
;     FITS filename of UCoMP raw data file
;
; :Keywords:
;   primary_header : out, optional, type=strarr(n_keywords)
;     set to a named variable to retrieve the primary header
;   ext_data : out, optional, type="fltarr(nx, ny, n_exts)"
;     set to a named variable to retrieve the extension data
;   ext_headers : out, optional, type="strarr(n_ext_keywords, n_exts)"
;     set to a named variable to retrieve the extension headers
;   repair_routine : in, optional, type=string
;     call procedure given by this keyword to repair data, if present
;-
pro ucomp_read_raw_data, filename, $
                         primary_header=primary_header, $
                         ext_data=ext_data, $
                         ext_headers=ext_headers, $
                         repair_routine=repair_routine
  compile_opt strictarr
  on_error, 2

  fits_open, filename, fcb

  n_extensions = fcb.nextend
  if (n_extensions le 1) then begin
    message, string(filename, n_extensions, $
                    format='(%"%s contains only %d extensions")')
  endif

  ; read primary header if requested
  if (arg_present(primary_header)) then begin
    fits_read, filename, primary_data, primary_header, exten_no=0, $
               /header_only, /no_abort, message=msg
    if (msg ne '') then message, msg
  endif

  ; read extensions if requested
  if (arg_present(ext_data) || arg_present(ext_headers)) then begin
    for e = 1L, n_extensions do begin
      fits_read, fcb, data, header, exten_no=e, /no_abort, message=msg
      if (msg ne '') then message, msg

      ; need to setup arrays the first time
      if (e eq 1) then begin
        n_ext_keywords = n_elements(header)
        type = size(data, /type)
        dims = size(data, /dimensions)

        ext_data = make_array(dimension=[dims, n_extensions], type=type)
        ext_headers = strarr(n_ext_keywords, n_extensions)
      endif

      ext_data[0, 0, e - 1] = data
      ext_headers[0, e - 1] = header
    endfor
  endif

  fits_close, fcb

  ; repair data
  if (n_elements(repair_routine) gt 0L) then begin
    call_procedure, repair_routine, primary_header, ext_data, ext_headers
  endif
end
