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
pro ucomp_l1_apply_gain, file, $
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
  wavelengths  = file.wavelengths

  dims = size(data, /dimensions)
  n_pol_states = dims[2]
  n_cameras = dims[3]

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  r_outer = run->epoch('field_radius', datetime=datetime)
  field_mask = ucomp_field_mask(dims[0:1], r_outer)
  field_mask_indices = where(field_mask, /null)

  opal_radiance = ucomp_opal_radiance(file.wave_region, run=run)

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
                                        coefficient=flat_coefficients, $
                                        sgsdimv=flat_sgsdimv)
    if (~flat_found) then begin
      mg_log, 'flat, or dark for flat, not found for ext %d, skipping', e + 1, $
              name=run.logger_name, /error
      mg_log, 'request %0.2f HST, %0.2f ms, %s gain, %s, %0.3f nm', $
              obsday_hours, exptime, gain_mode, onband, wavelengths[e], $
              name=run.logger_name, /debug
      mg_log, 'error message: %s', error_msg, name=run.logger_name, /debug
      status = 1L
      continue
    endif

    im = data[*, *, *, *, e]

    flat_median = median(dark_corrected_flat)

    zero_indices = where(dark_corrected_flat eq 0.0, n_zeros)
    if (n_zeros gt 0L) then dark_corrected_flat[zero_indices] = 1.0

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
    im *= opal_radiance

    data[*, *, *, *, e] = im

    h = headers[e]
    for fe = 0L, n_elements(master_flat_extensions) - 1L do begin
      ucomp_addpar, h, string(fe + 1L, format='FLTFILE%d'), flat_raw_files[fe], $
                    comment='name of raw flat file used'
      ucomp_addpar, h, string(fe + 1L, format='FLTEXTS%d'), raw_flat_extensions[fe], $
                    comment=string(flat_raw_files[fe], $
                                   format='(%"%s ext used")')
      ucomp_addpar, h, string(fe + 1L, format='MFLTEXT%d'), master_flat_extensions[fe], $
                    comment=string(run.date, file.wave_region, flat_coefficients[fe], $
                                   format='(%"%s.ucomp.%s.flat.fts ext, wt %0.2f")')
    endfor

    ucomp_addpar, h, 'FLATDN', flat_median, $
                  comment='median DN value of the dark-corrected flat used', $
                  format='(F0.2)', $
                  after='BUNIT'
    ; temporarily store the flat SGSDIMV in SKYTRANS
    ucomp_addpar, h, 'SKYTRANS', flat_sgsdimv, $
                  comment='sky transmission correction normalized to gain image', $
                  format='(F0.5)', $
                  after='FLATDN'

    headers[e] = h
  endfor

  ucomp_addpar, primary_header, 'BOPAL', opal_radiance, $
                comment='[B/Bsun] opal radiance', format='(F0.2)', $
                after='LIN_CRCT'
  ucomp_addpar, primary_header, 'BUNIT', '1.0E-06 B/Bsun', $
                comment='brightness with respect to solar disk', $
                after='OBJECT'
end
