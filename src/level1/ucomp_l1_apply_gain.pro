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
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_apply_gain, file, primary_header, data, headers, run=run, status=status
  compile_opt strictarr

  status = 0L

  n_exts = n_elements(headers)

  obsday_hours = file.obsday_hours
  exptime      = file.exptime
  gain_mode    = file.gain_mode
  wavelengths  = file.wavelengths

  dims = size(data, /dimensions)
  n_pol_states = dims[2]
  n_cameras = dims[3]

  cal = run.calibration

  ; for each extension in file
  for e = 0L, n_exts - 1L do begin
    onband = ucomp_getpar(headers[e], 'ONBAND')

    flat = cal->get_flat(obsday_hours, exptime, gain_mode, onband, wavelengths[e], $
                         found=flat_found, time_found=flat_time, $
                         master_extension=master_flat_extension, $
                         raw_extension=raw_flat_extension, raw_file=flat_raw_file)
    if (~flat_found) then begin
      mg_log, 'flat not found for ext %d, skipping', e + 1, $
              name=run.logger_name, /error
      mg_log, 'request %0.2f HST, %0.2f ms, %s gain, %s, %0.2f nm', $
              obsday_hours, exptime, gain_mode, onband, wavelengths[e], $
              name=run.logger_name, /warn
      status = 1L
      continue
    endif

    flat_dark = cal->get_dark(flat_time, exptime, gain_mode, found=flat_dark_found)
    if (~flat_dark_found) then begin
      mg_log, 'dark not found for flat for ext %d, skipping', e + 1, $
              name=run.logger_name, /error
      status = 2L
      continue
    endif

    im = data[*, *, *, *, e]

    dark_corrected_flat = flat - flat_dark
    zero_indices = where(dark_corrected_flat eq 0.0, n_zeros)
    if (n_zeros gt 0L) then dark_corrected_flat[zero_indices] = 1.0

    ; fix hot pixels before applying the flat
    for c = 0L, n_cameras - 1L do begin
      run->get_hot_pixels, gain_mode, c, hot=hot, adjacent=adjacent
      dark_corrected_flat[*, *, c] = ucomp_fix_hot(dark_corrected_flat[*, *, c], $
                                                   hot=hot, $
                                                   adjacent=adjacent)
    endfor

    ; apply flat
    for p = 0L, n_pol_states - 1L do begin
      p_im = im[*, *, p, *] / dark_corrected_flat
      if (n_zeros gt 0L) then p_im[zero_indices] = !values.f_nan
      im[*, *, p, *] = p_im
    endfor

    ; make flat a gain
    opal_radiance = ucomp_opal_radiance(file.wave_region, run=run)
    im *= opal_radiance

    data[*, *, *, *, e] = im

    h = headers[e]
    ucomp_addpar, h, 'FLATFILE', flat_raw_file, $
                  comment='name of raw flat file used'
    ucomp_addpar, h, 'FLATEXTS', raw_flat_extension, $
                  comment=string(flat_raw_file, $
                                 format='(%"ext(s) in %s used for flat correction")'), $
                  after='FLATFILE'
    ucomp_addpar, h, 'MFLATEXT', master_flat_extension, $
                  comment=string(run.date, file.wave_region, $
                                 format='(%"ext in %s.ucomp.flat.%s.fts used")'), $
                  after='FLATEXT'

    ucomp_addpar, h, 'BOPAL', opal_radiance, $
                  comment='[B/Bsun] opal radiance', format='(F0.2)'
    ucomp_addpar, h, 'BUNIT', '1.0E-06 B/Bsun', $
                  comment='brightness with respect to solar disk', $
                  after='BOPAL'
    headers[e] = h
  endfor
end
