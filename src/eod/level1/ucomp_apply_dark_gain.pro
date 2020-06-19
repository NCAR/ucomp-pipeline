; docformat = 'rst'

;+
; Apply the dark and gain.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, nx, nexts)"
;     extension data
;   headers : in, requiredd, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_apply_dark_gain, file, primary_header, data, headers, run=run
  compile_opt strictarr

  n_exts = n_elements(headers)

  obsday_hours = file.obsday_hours
  exptime = file.exptime
  gain_mode = file.gain_mode
  wavelengths = file.wavelengths

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  ; for each extension in file
  for e = 0L, n_exts - 1L do begin
    science_dark = run->get_dark(obsday_hours, exptime, gain_mode, found=dark_found, $
                                extensions=dark_extensions, coefficients=dark_coefficients)
    if (~dark_found) then begin
      mg_log, 'dark not found for ext %d', e + 1, $
              name=run.logger_name, /warn
    endif

    flat = run->get_flat(obsday_hours, exptime, gain_mode, wavelengths[e], $
                         found=flat_found, time_found=flat_time, $
                         extension=flat_extension, raw_file=flat_raw_file)
    if (~flat_found) then begin
      mg_log, 'flat not found for ext %d', e + 1, $
              name=run.logger_name, /warn
      mg_log, 'request %0.2f HST, %0.2f ms, %s gain, %0.2f nm', $
              obsday_hours, exptime, gain_mode, wavelengths[e], $
              name=run.logger_name, /warn
    endif

    flat_dark = run->get_dark(flat_time, exptime, gain_mode, found=dark_found)
    if (~dark_found) then begin
      mg_log, 'dark not found for ext %d', e + 1, $
              name=run.logger_name, /warn
    endif

    im = data[*, *, *, *, e]
    for p = 0L, n_pol_states - 1L do begin
      im[*, *, p, *] = (im[*, *, p, *] - science_dark) / (flat[*, *, p, *] - flat_dark)
    endfor
    ;im *= gain_transmission
    data[*, *, *, *, e] = im

    h = headers[e]
    for de = 0L, n_elements(dark_extensions) - 1L do begin
      sxaddpar, h, string(de + 1, format='(%"DARKEXT%d")'), dark_extensions[de], $
                string(run.date, format='(%" extension in %s.ucomp.dark.fts used")')
      sxaddpar, h, string(de + 1, format='(%"DARKWGT%d")'), dark_coefficients[de], $
                string(de + 1, format='(%" weighting coefficient for dark %d")')
    endfor
    sxaddpar, h, 'FLATFILE', flat_raw_file, ' name of raw flat file'
    sxaddpar, h, 'FLATEXT', flat_extension, $
              string(run.date, ucomp_wave_region(wavelengths[e]), $
                     format='(%" extension in %s.ucomp.flat.%s.fts used")')
    headers[e] = h
  endfor
end
