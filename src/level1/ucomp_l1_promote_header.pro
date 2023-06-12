; docformat = 'rst'

;+
; Update the primary and extension headers for being an L1 header.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol_states, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_promote_header, file, $
                             primary_header, data, headers, backgrounds, $
                             run=run, status=status
  compile_opt strictarr

  status = 0L

  ; update primary header

  ; add some headers to keywords from the level 0
  ucomp_addpar, primary_header, 'COMMENT', 'Basic info', $
                after='EXTEND', /title
  ucomp_addpar, primary_header, 'COMMENT', 'Observing info', $
                before='OBSERVER', /title
  ; ucomp_addpar, primary_header, 'COMMENT', 'Hardware positions', $
  ;               before='OCCLTR', /title
  ucomp_addpar, primary_header, 'COMMENT', 'Temperatures', $
                before='T_RACK', /title

  after = 'DATE-OBS'
  ucomp_addpar, primary_header, 'DATE-BEG', file.date_begin, $
                comment='[UT] date/time when obs was started', after=after
  ucomp_addpar, primary_header, 'DATE-END', file.date_end, $
                comment='[UT] date/time when obs ended', after=after

  sxdelpar, primary_header, 'LEVEL'
  after = 'OBJECT'
  ucomp_addpar, primary_header, 'LEVEL', 'L1', comment='level 1 calibrated', $
                after=after
  ucomp_addpar, primary_header, 'DOI', run->line(file.wave_region, 'doi'), $
                comment='Digital Object Identifier', $
                after=after

  current_time = systime(/utc)
  date_dp = string(bin_date(current_time), $
                   format='(%"%04d-%02d-%02dT%02d:%02d:%02d")')
  ucomp_addpar, primary_header, 'DATE_DP', date_dp, $
                comment='[UT] L1 processing date/time', $
                after=after
  version = ucomp_version(revision=revision, branch=branch, date=code_date)
  ucomp_addpar, primary_header, 'DPSWID',  $
                string(version, revision, $
                       format='(%"%s [%s]")'), $
                comment=string(code_date, branch, $
                       format='(%"L1 processing software (%s) [%s]")'), $
                after=after
  ucomp_addpar, primary_header, 'COMMENT', 'Level 1 processing info', $
                before='LEVEL', /title

  after = 'CAMERAS'
  ucomp_addpar, primary_header, 'NUM_WAVE', n_elements(headers), $
                comment='number of wavelengths', after=after
  ucomp_addpar, primary_header, 'NUMSUM', file.numsum, $
                comment='number of camera reads summed together', after=after
  ucomp_addpar, primary_header, 'NREPEAT', file.n_repeats, $
                comment='number of repeats of wavelength scans', after=after
  ucomp_addpar, primary_header, 'NUM_BEAM', 2, $
                comment='number of beams', after=after
  ucomp_addpar, primary_header, 'COMMENT', 'Counts', before='NUM_WAVE', /title

  average_radius = ucomp_getpar(primary_header, 'RADIUS')
  center_wavelength_indices = file->get_center_wavelength_indices()
  if (n_elements(center_wavelength_indices) gt 0L) then begin
    center_wavelength_data = data[*, *, *, center_wavelength_indices]
    file.vcrosstalk_metric = ucomp_vcrosstalk_metric(center_wavelength_data, average_radius)
  endif

  ; quality metrics
  ucomp_addpar, primary_header, 'VCROSSTK', file.vcrosstalk_metric, $
                comment='Stokes V crosstalk metric', after=after

  radius = ucomp_getpar(primary_header, 'RADIUS')
  background = backgrounds[*, *, file.n_unique_wavelengths / 2L]
  annulus_mask = ucomp_annulus(1.1 * radius, 1.5 * radius, $
                               dimensions=size(background, /dimensions))
  annulus_indices = where(annulus_mask, n_annulus_pts)
  median_background = median(background[annulus_indices])
  file.median_background = median_background
  ucomp_addpar, primary_header, 'MED-BKG', median_background, $
                comment='[ppm] median of background, i.e., continuum', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'COMMENT', 'Quality metrics', $
                before='VCROSSTK', /title

  ; update extension headers

  remove_keywords = ['COMMENT', 'ONBAND', 'V_LCVR1', 'V_LCVR2', $
                     'V_LCVR3', 'V_LCVR4', 'V_LCVR5', 'NUMSUM', 'SEQNUM', $
                     'OCCLTR', 'CALOPTIC', 'COVER', 'DIFFUSR', 'DARKSHUT', $
                     'POLANGLE', 'RETANGLE', 'DATE-BEG', 'O1ND']

  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]

    ; remove keywords
    for k = 0L, n_elements(remove_keywords) - 1L do sxdelpar, h, remove_keywords[k]

    ; fix up comments to NAXIS keywords
    ucomp_addpar, h, 'NAXIS1', ucomp_getpar(h, 'NAXIS1'), $
                  comment='[pixels] width'
    ucomp_addpar, h, 'NAXIS2', ucomp_getpar(h, 'NAXIS2'), $
                  comment='[pixels] height'
    ucomp_addpar, h, 'NAXIS3', ucomp_getpar(h, 'NAXIS3'), $
                  comment='polarization states: I, Q, U, V'
    headers[e] = h
  endfor

  ; promote keywords to primary header
  promote_keywords = [{name: 'FRAMERT', format: '(F0.3)', after: 'OCCLTRID'}, $
                      {name: 'EXPTIME', format: '(F0.3)', after: 'OCCLTRID'}]
  for k = 0L, n_elements(promote_keywords) - 1L do begin
    for e = 0L, n_elements(headers) - 1L do begin
      h = headers[e]
      new_value = ucomp_getpar(h, promote_keywords[k].name, comment=comment)
      sxdelpar, h, promote_keywords[k].name
      headers[e] = h

      ; make sure value is consistent before promoting
      if (e eq 0L) then begin
        value = new_value
      endif else begin
        if (~ucomp_same(value, new_value)) then begin
          mg_log, 'keyword %s not consistent across extensions', $
                  promote_keywords[k].name, $
                  name=run.logger_name, /warn
        endif
      endelse
    endfor

    ucomp_addpar, primary_header, promote_keywords[k].name, value, $
                  format=promote_keywords[k].format, $
                  comment=comment, after=promote_keywords[k].after
  endfor

  ucomp_addpar, primary_header, 'COMMENT', 'Camera info', $
                before='EXPTIME', /title

  continuum_offset = run->line(file.wave_region, 'continuum_offset')
  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    ucomp_addpar, h, 'CONTOFF', continuum_offset, $
                  format='(F0.5)', $
                  comment='[nm] distance from WAVELNG for continuum wavelength', $
                  after='CONTIN'
    headers[e] = h
  endfor

  ; promote SGS values to primary header after the temperatures
  sgs_keywords = ['SGSSCINT', $
                  'SGSDIMV', 'SGSDIMS', $
                  'SGSSUMV', 'SGSSUMS', $
                  'SGSRAV', 'SGSRAS', $
                  'SGSDECV', 'SGSDECS', $
                  'SGSLOOP', $
                  'SGSRAZR', 'SGSDECZR']
  sgs_values = fltarr(n_elements(sgs_keywords), n_elements(header))
  sgs_comments = strarr(n_elements(sgs_keywords))
  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    for s = 0L, n_elements(sgs_keywords) - 1L do begin
      sgs_values[s, e] = ucomp_getpar(h, sgs_keywords[s], comment=comment, /float)
      if (e eq 0L) then sgs_comments[e] = comment
      sxdelpar, h, sgs_keywords[s]
    endfor
    headers[e] = h
  endfor
  sgs_values = mean(values, dimension=1)

  after = 'T_C1PCB'
  for s = 0L, n_elements(sgs_keywords) - 1L do begin
    ucomp_addpar, primary_header, sgs_keywords[s], sgs_values[s], $
                  format='(F0.5)', comment=sgs_comments[s], $
                  after=after
  endfor
  ucomp_addpar, primary_header, 'COMMENT', 'SGS info', $
                before='SGSSCINT', /title

  ; add HISTORY of processing of the file
  ; TODO: update when continuum correction and sky transmission are performed
  history = [{text: '', include: 1B}, $
             {text: 'Level 1 calibration and processing steps:', include: 1B}, $
             {text: '  - quality check to determine if the file should be processed', include: 1B}, $
             {text: '  - average level 0 data with same onband and wavelength', include: 1B}, $
             {text: '  - apply dark', include: 1B}, $
             {text: '  - apply gain', include: 1B}, $
             {text: '  - camera corrections such as hot pixel correction', include: 1B}, $
             ;{text: '  - correct continuum', include: 1B}, $
             {text: '  - demodulation', include: 1B}, $
             {text: '  - distortion correction', include: 1B}, $
             {text: '  - find the occulter position and radius', include: 1B}, $
             {text: '  - subtract continuum', $
              include: run->line(file.wave_region, 'subtract_continuum')}, $
             {text: '  - deband', include: 1B}, $
             {text: '  - center images using occulter position and rotate to north up', include: 1B}, $
             {text: '  - combine the cameras', include: 1B}, $
             {text: '  - polarimetric correction', include: 1B}, $
             ;{text: '  - correct for sky transmission', include: 1B}, $
             {text: '  - update FITS keywords', include: 1B}]
  for h = 0L, n_elements(history) - 1L do begin
    if (history[h].include) then begin
      if (strlen('HISTORY  ' + history[h].text) gt 80L) then begin
        mg_log, 'too long: %s', history[h].text, name=run.logger_name, /warn
      endif
      ucomp_addpar, primary_header, 'HISTORY', history[h].text
    endif
  endfor
end


; main-level example program

date = '20220901'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

basename = '20220901.174648.65.ucomp.1074.l0.fts'
filename = filepath(basename, $
                    subdir=date, $
                    root=run->config('raw/basedir'))

file = ucomp_file(filename, run=run)

ucomp_read_raw_data, file.raw_filename, $
                     primary_header=primary_header, $
                     ext_data=data, $
                     ext_headers=headers, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     all_zero=all_zero

data = reform(data[*, *, *, 0, *])
backgrounds = reform(data[*, *, 0, *])

ucomp_addpar, primary_header, 'LIN_CRCT', boolean(file.linearity_corrected), $
              comment='camera linearity corrected', after='OBJECT'

datetime = strmid(file_basename(file.raw_filename), 0, 15)
dmatrix_coefficients = run->get_dmatrix_coefficients(datetime=datetime, info=demod_info)
demod_basename = run->epoch('demodulation_coeffs_basename', datetime=datetime)
ucomp_addpar, primary_header, 'DEMOD_C', demod_basename, $
              comment=string(ucomp_idlsave2dateobs(demod_info.date), $
                             format='demod coeffs created %s'), $
              after='LIN_CRCT'

cameras = 'both'
ucomp_addpar, primary_header, 'CAMERAS', cameras, $
            comment=string(cameras eq 'both' ? 's' : '', $
                           format='(%"camera%s used in processing")'), $
            after='DEMOD_C'

ucomp_addpar, primary_header, 'RADIUS', $
              333.195, $
              comment='[px] occulter average radius', $
              format='(F0.3)'

ucomp_l1_promote_header, file, $
                         primary_header, data, headers, backgrounds, $
                         run=run, status=status

obj_destroy, [file, run]

end
