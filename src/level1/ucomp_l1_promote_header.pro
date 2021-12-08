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
;   headers : in, requiredd, type=list
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
  ; TODO: this is in the extensions
  ; ucomp_addpar, primary_header, 'FLATFILE', flat_file, $
  ;               comment='name of flat field file'
  ucomp_addpar, primary_header, 'JUL_DATE', file.julian_date, $
                comment='[days] Julian date', $
                format='F24.16'

  file->getProperty, p_angle=p_angle, b0=b0, semidiameter=semidiameter
  ucomp_addpar, primary_header, 'SOLAR_P', float(p_angle), $
                comment='[deg] solar P-Angle'
  ucomp_addpar, primary_header, 'SOLAR_B', float(b0), $
                comment='[deg] solar B-Angle'
  ; TODO: how do I find this? I don't see a SECZ routine in SSW or Steve's code
  ; ucomp_addpar, primary_header, 'SECANT_Z', float(sec_z), $
  ;               comment='secant of the Zenith Distance'
  ucomp_addpar, primary_header, 'SEMIDIAM', float(semidiameter), $
                comment='[arcsec] solar semi-diameter'

  ; ucomp_addpar, primary_header, 'IMAGESCL', float(image_scale), $
  ;               comment='[arcsec/pixel] image scale at focal plane'
  ; ucomp_addpar, primary_header, 'XOFFSET0', float(x_offset_0), $
  ;               comment='[px] occulter x-Offset 0'
  ; ucomp_addpar, primary_header, 'YOFFSET0', float(y_offset_0), $
  ;               comment='[px] occulter y-offest 0'
  ; ucomp_addpar, primary_header, 'RADIUS0', float(radius_0), $
  ;               comment='[px] occulter radius 0'
  ; ucomp_addpar, primary_header, 'FITCHI0', float(chisq_0), $
  ;               comment='[px] chi-squared for image 0 center fit'
  ; ucomp_addpar, primary_header, 'XOFFSET1', float(x_offset_1), $
  ;               comment='[px] occulter x-offset 1'
  ; ucomp_addpar, primary_header, 'YOFFSET1', float(y_offset_1), $
  ;               comment='[px] occulter y-offest 1'
  ; ucomp_addpar, primary_header, 'RADIUS1', float(radius_1), $
  ;               comment='[px] occulter radius 1'
  ; ucomp_addpar, primary_header, 'FITCHI1', float(chisq_1), $
  ;               comment='[px] chi-squared for image 1 center fit'
  ; ucomp_addpar, primary_header, 'MED_BACK', float(med_back), $
  ;               comment='[ppm] median of background'
  ; ucomp_addpar, primary_header, 'RADIUS', float(radius), $
  ;               comment='[px] occulter average radius'
  ; ucomp_addpar, primary_header, 'POST_ANG', float(post_ang), $
  ;               comment='[deg] post angle CCW from north'
  ; ucomp_addpar, primary_header, 'VCROSSTK', float(ctalk), $
  ;               comment='Stokes V crosstalk metric'

  ; update extension headers

  remove_keywords = ['COMMENT', 'ONBAND', 'CONTIN', 'V_LCVR1', 'V_LCVR2', $
                     'V_LCVR3', 'V_LCVR4', 'V_LCVR5', 'NUMSUM']
  for e = 0L, n_elements(headers) - 1L do begin
    h = headers[e]
    for k = 0L, n_elements(remove_keywords) - 1L do sxdelpar, h, remove_keywords[k]
    headers[e] = h
  endfor
end