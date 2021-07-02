; docformat = 'rst'

;+
; Apply the dark and gain.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, nexts)"
;     extension data
;   headers : in, requiredd, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_apply_dark, file, primary_header, data, headers, run=run
  compile_opt strictarr

  n_exts = n_elements(headers)

  obsday_hours = file.obsday_hours
  exptime = file.exptime
  gain_mode = file.gain_mode
  wavelengths = file.wavelengths

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  cal = run.calibration

  ; for each extension in file
  for e = 0L, n_exts - 1L do begin
    numsum = ucomp_getpar(headers[e], 'NUMSUM')

    science_dark = cal->get_dark(obsday_hours, exptime, gain_mode, found=dark_found, $
                                 extensions=dark_extensions, coefficients=dark_coefficients)
    if (~dark_found) then begin
      mg_log, 'dark not found for ext %d, skipping', e + 1, $
              name=run.logger_name, /warn
      continue
    endif
    science_dark = mean(science_dark, dimension=3)

    im = data[*, *, *, *, e]
    for p = 0L, n_pol_states - 1L do begin
      im[*, *, p, *] -= numsum * science_dark
    endfor

    data[*, *, *, *, e] = im

    h = headers[e]
    for de = 0L, n_elements(dark_extensions) - 1L do begin
      ucomp_addpar, h, string(de + 1, format='(%"DARKEXT%d")'), dark_extensions[de], $
                    comment=string(run.date, dark_coefficients[de], $
                                   format='(%"ext in %s.ucomp.dark.fts used, wt %0.2f")')
    endfor
    headers[e] = h
  endfor
end
