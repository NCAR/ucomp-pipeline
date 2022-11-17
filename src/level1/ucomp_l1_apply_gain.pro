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

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  r_outer = run->epoch('field_radius', datetime=datetime)
  field_mask = ucomp_field_mask(dims[0], dims[1], r_outer)
  field_mask_indices = where(field_mask, /null)

  cal = run.calibration

  center_indices = file->get_center_wavelength_indices()

  ; for each extension in file
  for e = 0L, n_exts - 1L do begin
    onband = ucomp_getpar(headers[e], 'ONBAND')

    dark_corrected_flat = cal->get_flat(obsday_hours, $
                                        exptime, $
                                        gain_mode, $
                                        onband, $
                                        wavelengths[e], $
                                        found=flat_found, $
                                        error_msg=error_msg, $
                                        times_found=flat_times, $
                                        master_extensions=master_flat_extensions, $
                                        raw_extensions=raw_flat_extensions, $
                                        raw_filenames=flat_raw_files, $
                                        coefficient=flat_coefficients)
    if (~flat_found) then begin
      mg_log, 'flat, or dark for flat, not found for ext %d, skipping', e + 1, $
              name=run.logger_name, /error
      mg_log, 'request %0.2f HST, %0.2f ms, %s gain, %s, %0.2f nm', $
              obsday_hours, exptime, gain_mode, onband, wavelengths[e], $
              name=run.logger_name, /warn
      mg_log, 'error message: %s', error_msg, name=run.logger_name, /warn
      status = 1L
      continue
    endif

    ; mg_log, 'dark corrected flat mean by camera: %0.3f, %0.3f', $
    ;         mean(mean(dark_corrected_flat, dimension=1), dimension=1), $
    ;         name=run.logger_name, /debug

    im = data[*, *, *, *, e]

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

    ; record center wavelength dark corrected flat median values
    if (total(e eq center_indices, /integer) gt 0L) then begin
      rcam_image = dark_corrected_flat[*, *, 0]
      tcam_image = dark_corrected_flat[*, *, 1]

      if (onband eq 'rcam') then begin
        file.flat_rcam_median_linecenter = median(rcam_image[field_mask_indices])
        file.flat_tcam_median_continuum = median(tcam_image[field_mask_indices])
      endif

      if (onband eq 'tcam') then begin
        file.flat_tcam_median_linecenter = median(tcam_image[field_mask_indices])
        file.flat_rcam_median_continuum = median(rcam_image[field_mask_indices])
      endif
    endif

    ; make flat a gain
    opal_radiance = ucomp_opal_radiance(file.wave_region, run=run)
    im *= opal_radiance

    data[*, *, *, *, e] = im

    h = headers[e]
    for fe = 0L, n_elements(master_flat_extensions) - 1L do begin
      ucomp_addpar, h, string(fe + 1L, format='FLTFILE%d'), flat_raw_files[fe], $
                    comment='name of raw flat file used'
      ucomp_addpar, h, string(fe + 1L, format='FLTEXTS%d'), raw_flat_extensions[fe], $
                    comment=string(flat_raw_files[fe], $
                                   format='(%"ext in %s used")')
      ucomp_addpar, h, string(fe + 1L, format='MFLTEXT%d'), master_flat_extensions[fe], $
                    comment=string(run.date, file.wave_region, flat_coefficients[fe], $
                                   format='(%"ext in %s.ucomp.flat.%s.fts, wt %0.2f")')
    endfor

    ucomp_addpar, h, 'BOPAL', opal_radiance, $
                  comment='[B/Bsun] opal radiance', format='(F0.2)'
    ucomp_addpar, h, 'BUNIT', '1.0E-06 B/Bsun', $
                  comment='brightness with respect to solar disk', $
                  after='BOPAL'
    headers[e] = h
  endfor
end
