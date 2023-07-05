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
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_promote_header, file, $
                             primary_header, $
                             data, headers, $
                             backgrounds, background_headers, $
                             run=run, status=status
  compile_opt strictarr

  status = 0L

  ; update primary header

  ; add some headers to keywords from the level 0
  ucomp_addpar, primary_header, 'COMMENT', 'Basic info', $
                after='EXTEND', /title
  ucomp_addpar, primary_header, 'COMMENT', 'Observing info', $
                before='OBSERVER', /title
  ucomp_addpar, primary_header, 'COMMENT', 'Hardware settings', $
                before='FLCVNEG', /title
  ucomp_addpar, primary_header, 'COMMENT', 'Temperatures', $
                before='T_RACK', /title

  ucomp_addpar, primary_header, 'OBSSWID', $
                ucomp_getpar(primary_header, 'OBSSWID'), $
                comment='data collection software ID'

  after = 'DATE-OBS'
  ucomp_addpar, primary_header, 'DATE-END', file.date_end, $
                comment='[UT] date/time when obs ended', after=after

  ucomp_addpar, primary_header, 'OBJECT', 'SUN', comment=' '

  after = 'R_SUN'
  sxdelpar, primary_header, 'LEVEL'
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

  after = 'REMFRAME'
  ucomp_addpar, primary_header, 'NUM_WAVE', n_elements(headers), $
                comment='number of wavelengths', after=after
  ucomp_addpar, primary_header, 'NUMSUM', file.numsum, $
                comment='number of camera reads summed in an image frame', $
                after=after
  ucomp_addpar, primary_header, 'NREPEAT', file.n_repeats, $
                comment='number of repeats of wavelength scans', after=after
  ucomp_addpar, primary_header, 'NUM_BEAM', 2, $
                comment='number of beams', after=after
  ucomp_addpar, primary_header, 'COMMENT', $
                '  NFRAME = NUM_WAVE * NREPEAT * NUM_BEAM * 2(Cameras) * 4(Polarizations)', $
                after='NUM_BEAM'
  ucomp_addpar, primary_header, 'COMMENT', $
                'Total camera reads in this file = NFRAME * NUMSUM where', $
                after='NUM_BEAM'

  average_radius = ucomp_getpar(primary_header, 'RADIUS')
  center_wavelength_indices = file->get_center_wavelength_indices()
  if (n_elements(center_wavelength_indices) gt 0L) then begin
    center_wavelength_data = data[*, *, *, center_wavelength_indices]
    file.vcrosstalk_metric = ucomp_vcrosstalk_metric(center_wavelength_data, average_radius)
  endif

  ; quality metrics
  after = 'BUNIT'
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
                comment='[ppm] median of line center background annulus', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'COMMENT', 'Quality metrics', $
                before='VCROSSTK', /title

  ; update extension headers

  remove_keywords = ['COMMENT', 'ONBAND', 'V_LCVR1', 'V_LCVR2', $
                     'V_LCVR3', 'V_LCVR4', 'V_LCVR5', 'NUMSUM', 'SEQNUM', $
                     'OCCLTR', 'CALOPTIC', 'COVER', 'DIFFUSR', 'DARKSHUT', $
                     'POLANGLE', 'RETANGLE', 'DATE-BEG', 'O1ND', 'O1FOCUS']

  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    b = background_headers[e]

    ; remove keywords
    for k = 0L, n_elements(remove_keywords) - 1L do begin
      sxdelpar, h, remove_keywords[k]
      sxdelpar, b, remove_keywords[k]
    endfor

    ; fix up comments to NAXIS keywords
    ucomp_addpar, h, 'NAXIS1', ucomp_getpar(h, 'NAXIS1'), $
                  comment='[pixels] width'
    ucomp_addpar, b, 'NAXIS1', ucomp_getpar(b, 'NAXIS1'), $
                  comment='[pixels] width'

    ucomp_addpar, h, 'NAXIS2', ucomp_getpar(h, 'NAXIS2'), $
                  comment='[pixels] height'
    ucomp_addpar, b, 'NAXIS2', ucomp_getpar(b, 'NAXIS2'), $
                  comment='[pixels] height'

    ucomp_addpar, h, 'NAXIS3', ucomp_getpar(h, 'NAXIS3'), $
                  comment='polarization states: I, Q, U, V'

    headers[e] = h
    background_headers[e] = b
  endfor

  ; deleted O1FOCUS from extension headers above, can now rename O1FOCUSE to
  ; O1FOCUS in primary header
  o1focus_value = ucomp_getpar(primary_header, 'O1FOCUSE', comment=o1focus_comment)
  ucomp_addpar, primary_header, 'O1FOCUS', o1focus_value, $
                comment=o1focus_comment, after='O1FOCUSE', format='(F0.3)'
  sxdelpar, primary_header, 'O1FOCUSE'

  ; promote keywords to primary header
  promote_keywords = [{name: 'FRAMERT', format: '(F0.3)', after: 'OCCLTRID'}, $
                      {name: 'EXPTIME', format: '(F0.3)', after: 'OCCLTRID'}]
  for k = 0L, n_elements(promote_keywords) - 1L do begin
    for e = 0L, n_elements(headers) - 1L do begin
      h = headers[e]
      b = background_headers[e]

      new_value = ucomp_getpar(h, promote_keywords[k].name, comment=comment)
      sxdelpar, h, promote_keywords[k].name
      sxdelpar, b, promote_keywords[k].name

      headers[e] = h
      background_headers[e] = b

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

  ucomp_movepar, primary_header, 'GAIN', after='FRAMERT'
  ucomp_movepar, primary_header, 'SAVEALL', after='GAIN'

  hardware_keywords = ['DARKID', 'O1ID', 'DIFFSRID', 'OCCLTRID']
  for k = 0L, n_elements(hardware_keywords) - 1L do begin
    ucomp_movepar, primary_header, hardware_keywords[k], before='FLCVNEG'
  endfor

  continuum_comment = 'Continuum can be "red", "blue", or "both": "both" gives equal weight to red and blue sides, "red" measures the continuum on the red side of the WAVELNG by CONTOFF, "blue" measures the continuum on the blue side of the WAVELNG by CONTOFF'
  continuum_comment = mg_strwrap(continuum_comment, width=72)

  continuum_offset = run->line(file.wave_region, 'continuum_offset')
  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    ucomp_addpar, h, 'CONTIN', ucomp_getpar(h, 'CONTIN'), $
                  comment='[both/blue/red] location of continuum'
    for i = n_elements(continuum_comment) - 1L, 0L, -1L do begin
      ucomp_addpar, h, 'COMMENT', continuum_comment[i], after='CONTIN'
    endfor
    ucomp_addpar, h, 'CONTOFF', continuum_offset, $
                  format='(F0.5)', $
                  comment='[nm] distance from WAVELNG for continuum wavelength', $
                  after='CONTIN'
    headers[e] = h
  endfor

  ; update DATATYPE and OBJECT keywords
  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    b = background_headers[e]

    ucomp_addpar, h, 'DATATYPE', 'science', $
                  comment='[sci/cal/dark/flat] science or calibration'

    ucomp_addpar, b, 'DATATYPE', 'science', $
                  comment='[sci/cal/dark/flat] science or calibration'
    ucomp_addpar, b, 'OBJECT', ucomp_getpar(b, 'OBJECT'), $
                  comment='continuum emission'

    headers[e] = h
    background_headers[e] = b
  endfor

  ; promote SGS values to primary header after the temperatures
  sgs_keywords = ['SGSSCINT', $
                  'SGSDIMV', 'SGSDIMS', $
                  'SGSSUMV', 'SGSSUMS', $
                  'SGSRAV', 'SGSRAS', $
                  'SGSDECV', 'SGSDECS', $
                  'SGSLOOP', $
                  'SGSRAZR', 'SGSDECZR']
  sgs_values = fltarr(n_elements(sgs_keywords), n_elements(headers))
  sgs_comments = strarr(n_elements(sgs_keywords))
  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    b = background_headers[e]
    for s = 0L, n_elements(sgs_keywords) - 1L do begin
      sgs_values[s, e] = ucomp_getpar(h, sgs_keywords[s], comment=comment, /float)
      if (e eq 0L) then sgs_comments[s] = comment
      sxdelpar, h, sgs_keywords[s]
      sxdelpar, b, sgs_keywords[s]
    endfor
    headers[e] = h
    background_headers[e] = b
  endfor
  sgs_values = mean(sgs_values, dimension=2)

  after = 'T_C1PCB'
  for s = 0L, n_elements(sgs_keywords) - 1L do begin
    ucomp_addpar, primary_header, sgs_keywords[s], sgs_values[s], $
                  format='(F0.5)', comment=sgs_comments[s], $
                  after=after
  endfor
  ucomp_addpar, primary_header, 'COMMENT', 'SGS info', $
                before='SGSSCINT', /title

  after = 'MED-BKG'
  ucomp_addpar, primary_header, $
                'WNDSPD', $
                ucomp_getpar(primary_header, 'WNDSPD'), $
                comment='[mph] wind speed', $
                format='(F0.3)', $
                after=after
  ucomp_addpar, primary_header, $
                'WNDDIR', $
                ucomp_getpar(primary_header, 'WNDSPD'), $
                comment='[deg] wind direction', $
                format='(F0.3)', $
                after=after
  ucomp_addpar, primary_header, 'COMMENT', 'Weather info', $
                before='WNDSPD', /title

  ; add HISTORY of processing of the file
  ; TODO: update when continuum correction and sky transmission are performed
  history = [{text: '', include: 1B}, $
             {text: 'Level 1 calibration and processing steps:', include: 1B}, $
             {text: '  - quality check to determine if the file should be processed', include: 1B}, $
             {text: '  - average level 0 data with same onband and wavelength', include: 1B}, $
             {text: '  - apply dark correction', include: 1B}, $
             {text: '  - find the occulter position and radius', $
              include: run->config('centering/step_order') eq 'pre-gaincorrection'}, $
             {text: '  - apply gain correction', include: 1B}, $
             {text: '  - camera corrections such as hot pixel correction', include: 1B}, $
             ;{text: '  - correct continuum', include: 1B}, $
             {text: '  - demodulation', include: 1B}, $
             {text: '  - distortion correction', include: 1B}, $
             {text: '  - find the occulter position and radius', $
              include: run->config('centering/step_order') eq 'post-distortion'}, $
             {text: '  - subtract continuum', $
              include: run->line(file.wave_region, 'subtract_continuum')}, $
             {text: '  - remove hoizontal/vertical bands', include: 1B}, $
             {text: '  - center images using occulter position and rotate to north up', $
              include: 1B}, $
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
