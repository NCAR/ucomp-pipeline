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
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_promote_header, file, primary_header, data, headers, $
                             run=run, status=status
  compile_opt strictarr

  status = 0L

  ; update primary header

  ucomp_addpar, primary_header, 'LEVEL', 'L1', comment='level 1 calibrated'

  current_time = systime(/utc)
  date_dp = string(bin_date(current_time), $
                   format='(%"%04d-%02d-%02dT%02d:%02d:%02d")')
  ucomp_addpar, primary_header, 'DATE_DP', date_dp, $
                comment='L1 processing date/time [UTC]', $
                after='LEVEL'

  version = ucomp_version(revision=revision, branch=branch, date=code_date)
  ucomp_addpar, primary_header, 'DPSWID',  $
                string(version, revision, $
                       format='(%"%s [%s]")'), $
                comment=string(code_date, branch, $
                       format='(%"L1 processing software (%s) [%s]")'), $
                after='DATE_DP'

  ucomp_addpar, primary_header, 'NUM_WAVE', n_elements(headers), $
                comment='number of wavelengths'
  ucomp_addpar, primary_header, 'NUMSUM', file.numsum, $
                comment='number of camera reads summed together'
  ucomp_addpar, primary_header, 'NREPEAT', file.n_repeats, $
                comment='number of repeats of wavelength scans'
  ucomp_addpar, primary_header, 'NUM_BEAM', 2, $
                comment='number of beams'

  ucomp_addpar, primary_header, 'JUL_DATE', file.julian_date, $
                comment='[days] Julian date', $
                format='F24.16'

  average_radius = ucomp_getpar(primary_header, 'RADIUS')
  center_wavelength_indices = file->get_center_wavelength_indices()
  if (n_elements(center_wavelength_indices) gt 0L) then begin
    center_wavelength_data = data[*, *, *, center_wavelength_indices]
    file.vcrosstalk_metric = ucomp_vcrosstalk_metric(center_wavelength_data, average_radius)
  endif
  ucomp_addpar, primary_header, 'VCROSSTK', file.vcrosstalk_metric, $
                comment='Stokes V crosstalk metric'

  ; update extension headers

  remove_keywords = ['COMMENT', 'ONBAND', 'V_LCVR1', 'V_LCVR2', $
                     'V_LCVR3', 'V_LCVR4', 'V_LCVR5', 'NUMSUM', 'SEQNUM', $
                     'OCCLTR', 'CALOPTIC', 'COVER', 'DIFFUSR', 'DARKSHUT', $
                     'POLANGLE', 'RETANGLE']
  promote_keywords = [{name: 'CONTIN', format: '(A)'}, $
                      {name: 'FRAMERT', format: '(F0.3)'}, $
                      {name: 'EXPTIME', format: '(F0.3)'}]

  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]

    ; remove keywords
    for k = 0L, n_elements(remove_keywords) - 1L do sxdelpar, h, remove_keywords[k]

    ; fix up comments to NAXIS keywords
    ucomp_addpar, h, 'NAXIS1', ucomp_getpar(h, 'NAXIS1'), $
                  comment='[px] width'
    ucomp_addpar, h, 'NAXIS2', ucomp_getpar(h, 'NAXIS2'), $
                  comment='[px] height'
    ucomp_addpar, h, 'NAXIS3', ucomp_getpar(h, 'NAXIS3'), $
                  comment='polarization states: I, Q, U, V'
    headers[e] = h
  endfor

  ; promote keywords to primary header
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
                  comment=comment
  endfor
end
