; docformat = 'rst'

;+
; Read a UCoMP level 0 data file.
;
; :Params:
;   filename : in, required, type=string
;     FITS filename of UCoMP raw data file
;
; :Keywords:
;   primary_data : out, optional, type=float
;     set to a named variable to retrieve the data in the primary extension
;     (should always be 0.0)
;   primary_header : out, optional, type=strarr(n_keywords)
;     set to a named variable to retrieve the primary header
;   ext_data : out, optional, type="fltarr(nx, ny, n_polstates, n_exts)"
;     set to a named variable to retrieve the extension data
;   ext_headers : out, optional, type="list of strarr(n_ext_keywords)"
;     set to a named variable to retrieve the extension headers
;   background_data : out, optional, type="fltarr(nx, ny, n_polstates, n_exts)"
;     set to a named variable to retrieve the background data
;   background_headers : out, optional, type="list of strarr(n_ext_keywords)"
;     set to a named variable to retrieve the background headers
;   n_wavelengths : out, optional, type=long
;     set to a named variable to retrieve the number of wavelengths
;-
pro ucomp_read_l1_data, filename, $
                        primary_data=primary_data, $
                        primary_header=primary_header, $
                        ext_data=ext_data, $
                        ext_headers=ext_headers, $
                        background_data=background_data, $
                        background_headers=background_headers, $
                        n_wavelengths=n_wavelengths
  compile_opt strictarr
  on_error, 2

  fits_open, filename, fcb, /no_abort, message=msg
  if (msg ne '') then message, msg

  n_extensions = fcb.nextend
  n_wavelengths = n_extensions / 2L
  if (n_extensions lt 1) then begin
    message, string(filename, $
                    format='(%"%s contains no extensions")')
  endif

  ; read primary header if requested
  if (arg_present(primary_header) || arg_present(primary_data)) then begin
    fits_read, filename, primary_data, primary_header, exten_no=0, $
               /header_only, /no_abort, message=msg
    if (msg ne '') then message, msg
  endif

  ; read extensions if requested
  if (arg_present(ext_data) || arg_present(ext_headers)) then begin
    if (arg_present(ext_headers)) then ext_headers = list()
    if (arg_present(background_headers)) then background_headers = list()

    for e = 1L, n_wavelengths do begin
      fits_read, fcb, data, header, exten_no=e, /no_abort, /no_pdu, message=msg
      if (msg ne '') then message, msg

      ; need to setup arrays the first time
      if (e eq 1 && arg_present(ext_data)) then begin
        type = 4   ; always convert to float
        dims = size(data, /dimensions)

        ext_data = make_array(dimension=[dims, n_wavelengths], type=type)
      endif

      if (arg_present(ext_data)) then ext_data[0, 0, 0, e - 1] = data
      if (arg_present(ext_headers)) then ext_headers->add, header
    endfor
    for e = n_wavelengths + 1L, n_extensions do begin
      fits_read, fcb, data, header, exten_no=e, /no_abort, /no_pdu, message=msg
      if (msg ne '') then message, msg

      ; need to setup arrays the first time
      if ((e eq n_wavelengths + 1L) && arg_present(background_data)) then begin
        type = 4   ; always convert to float
        dims = size(data, /dimensions)

        background_data = make_array(dimension=[dims, n_wavelengths], $
                                     type=type)
      endif

      if (arg_present(background_data)) then background_data[0, 0, 0, e - 1 - n_wavelengths] = data
      if (arg_present(background_headers)) then background_headers->add, header
    endfor
  endif

  fits_close, fcb
end


; main-level example program

date = '20221123'
config_basename = 'ucomp.991.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l1_basename = '20221123.193016.ucomp.991.l1.p3.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))
obj_destroy, run
print, l1_filename
ucomp_read_l1_data, l1_filename, $
                    primary_data=primary_data, $
                    primary_header=primary_header, $
                    ext_data=ext_data, $
                    ext_headers=ext_headers, $
                    background_data=background_data, $
                    background_headers=background_headers, $
                    n_wavelengths=n_wavelengths

end
