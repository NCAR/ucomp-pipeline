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
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : type=undefined
;     not used in this step
;   background_headers : in, required, type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_apply_dark, file, $
                         primary_header, $
                         data, headers, $
                         backgrounds, background_headers, $
                         run=run, status=status
  compile_opt strictarr

  status = 0L

  n_exts = n_elements(headers)

  obsday_hours = file.obsday_hours
  exptime      = file.exptime
  gain_mode    = file.gain_mode
  nuc          = file.nuc
  nuc_values   = run->epoch('nuc_values')
  nuc_index    = ucomp_nuc2index(nuc, values=nuc_values)

  wavelengths = file.wavelengths

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  cal = run.calibration

  ; for each extension in file
  for e = 0L, n_exts - 1L do begin
    science_dark = cal->get_dark(obsday_hours, exptime, gain_mode, nuc_index, $
                                 found=dark_found, $
                                 master_extensions=master_dark_extensions, $
                                 raw_filenames=raw_dark_filenames, $
                                 coefficients=dark_coefficients)
    if (~dark_found) then begin
      mg_log, 'dark not found for ext %d, skipping', e + 1, $
              name=run.logger_name, /error
      status = 1L
      continue
    endif

    ; mg_log, 'science dark mean by camera: %0.3f, %0.3f', $
    ;         mean(mean(science_dark, dimension=1), dimension=1), $
    ;         name=run.logger_name, /debug

    im = data[*, *, *, *, e]
    for p = 0L, n_pol_states - 1L do begin
      im[*, *, p, *] -= science_dark
    endfor

    data[*, *, *, *, e] = im

    h = headers[e]
    for de = 0L, n_elements(master_dark_extensions) - 1L do begin
      ucomp_addpar, h, string(de + 1, format='(%"RAWDARK%d")'), raw_dark_filenames[de], $
                    comment=string(dark_coefficients[de], $
                                   format='(%"raw dark filename used, wt %0.2f")')
      ucomp_addpar, h, string(de + 1, format='(%"DARKEXT%d")'), master_dark_extensions[de], $
                    comment=string(run.date, dark_coefficients[de], $
                                   format='(%"%s.ucomp.dark.fts ext used, wt %0.2f")')
    endfor
    headers[e] = h
  endfor
end
