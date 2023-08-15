; docformat = 'rst'

;+
; Read a UCoMP raw data file.
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
;   ext_data : out, optional, type="fltarr(nx, ny, n_polstates, n_cameras, n_exts)"
;     set to a named variable to retrieve the extension data
;   ext_headers : out, optional, type="list of strarr(n_ext_keywords)"
;     set to a named variable to retrieve the extension headers
;   n_extensions : out, optional, type=long
;     set to a named variable to retrieve the number of extensions
;   repair_routine : in, optional, type=string
;     call procedure given by this keyword to repair data, if present
;   badframes : in, optional, type=array of structures
;     to set specific frames to NaNs, set to an array of structures of the form:
;
;         replicate({filename: '', camera: 0L, extension: 0L, polstate: 0L}, $
;                   n_badframes)
;
;   all_zero : out, optional, type=byte
;     set to a named variable to retrieve whether any extension of the file was
;     identically zero
;   logger : in, optional, type=string
;     name of logger to output to
;-
pro ucomp_read_raw_data, filename, $
                         primary_data=primary_data, $
                         primary_header=primary_header, $
                         ext_data=ext_data, $
                         ext_headers=ext_headers, $
                         n_extensions=n_extensions, $
                         repair_routine=repair_routine, $
                         badframes=badframes, $
                         all_zero=all_zero, $
                         logger=logger
  compile_opt strictarr
  on_error, 2

  all_zero = 0B

  fits_open, filename, fcb, /no_abort, message=msg
  if (msg ne '') then message, msg

  n_extensions = fcb.nextend
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
    for e = 1L, n_extensions do begin
      fits_read, fcb, data, header, exten_no=e, /no_abort, message=msg
      if (msg ne '') then message, msg

      if (arg_present(all_zero)) then begin
        ext_all_zero = array_equal(data, 0US)
        if (ext_all_zero gt 0) then begin
          mg_log, '%s ext %d all zero', $
                  file_basename(filename), e, $
                  name=logger, /warn
        endif
        all_zero or= ext_all_zero
      endif

      numsum = ucomp_getpar(header, 'NUMSUM')
      data = float(data) / numsum

      ; need to setup arrays the first time
      if (e eq 1 && arg_present(ext_data)) then begin
        type = 4   ; always convert to float
        dims = size(data, /dimensions)

        ext_data = make_array(dimension=[dims, n_extensions], type=type)
      endif

      if (arg_present(ext_data)) then ext_data[0, 0, 0, 0, e - 1] = data
      if (arg_present(ext_headers)) then ext_headers->add, header
    endfor
  endif

  fits_close, fcb

  n_file_badframes = 0L
  n_invalid_frames = 0L

  if (n_elements(badframes) gt 0L) then begin
    file_indices = where(badframes.filename eq file_basename(filename), n_file_badframes)
    if (n_file_badframes ne 0L) then begin
      file_badframes = badframes[file_indices]

      ; warn about invalid bad frame specifications
      invalid_frames_indices = where((file_badframes.polstate ge 4) $
                                       or (file_badframes.camera ge 2) $
                                       or (file_badframes.extension gt n_extensions), $
                                     n_invalid_frames)
      if (n_invalid_frames gt 0L) then begin
        mg_log, 'found %d invalid bad frame specification%s', $
                n_invalid_frames, $
                n_invalid_frames gt 1 ? 's' : '', $
                name=logger, /warn
        invalid_badframes = file_badframes[invalid_frames_indices]
        for i = 0L, n_invalid_frames - 1L do begin
          mg_log, 'invalid bad frame @ camera: %d, polstate: %d, ext: %d', $
                  (invalid_badframes[i]).camera, $
                  (invalid_badframes[i]).polstate, $
                  (invalid_badframes[i]).extension, $
                  name=logger, /warn
        endfor
      endif

      if (n_invalid_frames eq 0L) then begin
        ; log bad frames removed
        for f = 0L, n_file_badframes - 1L do begin
          mg_log, '%s: removing pol state %d, camera %d, ext %d', $
                  file_basename(filename), $
                  (file_badframes.polstate)[f], $
                  (file_badframes.camera)[f], $
                  (file_badframes.extension)[f], $
                  name=logger, /debug
        endfor
        ext_data[*, *, file_badframes.polstate, file_badframes.camera, file_badframes.extension - 1] = !values.f_nan
      endif
    endif
  endif

  if (arg_present(primary_header)) then begin
    dims = size(ext_data, /dimensions)
    n_total_frames = product(dims[2:*], /preserve_type)
    ucomp_addpar, primary_header, 'NFRAME', n_total_frames, $
                  comment='total number of image frames in file', $
                  after='RCAMNUC'
    n_bad_frames = n_invalid_frames eq 0L ? n_file_badframes : 0L
    ucomp_addpar, primary_header, 'REMFRAME', n_bad_frames, $
                  comment='number of bad frames removed', $
                  after='NFRAME'
  endif

  ; repair data
  for r = 0L, n_elements(repair_routine) - 1L do begin
    call_procedure, repair_routine[r], primary_header, ext_data, ext_headers
  endfor
end


; main-level example program

; date = '20220302'
; date = '20220310'
date = '20220219'
; raw_basename = '20220302.211521.32.ucomp.l0.fts'
; raw_basename = '20220302.174547.40.ucomp.l0.fts'
; raw_basename = '20220310.180408.94.ucomp.1074.l0.fts'
raw_basename = '20220219.212350.63.ucomp.637.l0.fts'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

raw_basedir = run->config('raw/basedir')
raw_filename = filepath(raw_basename, subdir=date, root=raw_basedir)

ucomp_read_raw_data, raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     badframes=run.badframes, $
                     all_zero=all_zero
print, raw_filename
print, raw_basename, all_zero ? 'YES' : 'NO', format='%s all zero: %s'

obj_destroy, run

end
