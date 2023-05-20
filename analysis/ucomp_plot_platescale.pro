; docformat = 'rst'

pro ucomp_plot_platescale_wave_region, filename, wave_region, percentile, $
                                       changes=changes
 compile_opt strictarr

  start_date = '2021-05-26'
  end_date = '2022-12-01'

  start_jd = ucomp_dateobs2julday(start_date)
  end_jd = ucomp_dateobs2julday(end_date)

  platescale_range = [2.75, 3.2]

  !null = label_date(date_format='%Y-%N-%D')

  charsize = 0.85

  n_lines = file_lines(filename)
  print, wave_region, n_lines, format='#### %s nm: %d files'

  if (n_lines eq 0L) then begin
    jds = dblarr(2) + !values.f_nan
    image_scale = fltarr(2) + !values.f_nan
    return
  endif else begin
    jds         = dblarr(n_lines)
    image_scale = fltarr(n_lines)
    fit0_chisq  = fltarr(n_lines)
    fit1_chisq  = fltarr(n_lines)

    line = ''
    openr, lun, filename, /get_lun
    for i = 0L, n_lines - 1L do begin
      readf, lun, line

      tokens = strsplit(line, /extract, count=n_tokens)

      jds[i]         = double(tokens[0])
      image_scale[i] = float(tokens[2])
      fit0_chisq[i]  = float(tokens[3])
      fit1_chisq[i]  = float(tokens[4])
    endfor
    free_lun, lun
  endelse

  fit0_percentiles = mg_percentiles(fit0_chisq, percentiles=percentile)
  fit1_percentiles = mg_percentiles(fit1_chisq, percentiles=percentile)
  print, 100.0 * percentile, fit0_percentiles, format='fit 0: %0.1f%% percentile chisq: %0.2f'
  print, 100.0 * percentile, fit1_percentiles, format='fit 1: %0.1f%% percentile chisq: %0.2f'

  fit_condition = fit0_chisq lt fit0_percentiles[-1] and fit1_chisq lt fit1_percentiles[-1]

  for c = 0L, n_elements(changes) - 1L do begin
    if (c eq n_elements(changes) - 1L) then begin
      epoch_condition = jds gt changes[c]
    endif else begin
      epoch_condition = (jds gt changes[c]) and (jds lt changes[c + 1])
    endelse

    condition = epoch_condition and fit_condition
    good_epoch_indices = where(condition, n_good_epoch_files)
    if (n_good_epoch_files gt 2L) then begin
      caldat, changes[c], month, day, year
      print, year, month, day, n_good_epoch_files, median(image_scale[good_epoch_indices]), $
                    format='epoch starting %04d-%02d-%02d [%d files], plate scale: %0.3f arcsec/pixel'
    endif
  endfor
  print

  good_indices = where(fit_condition, /null)

  plot, jds[good_indices], image_scale[good_indices], $
        psym=6, symsize=0.25, charsize=charsize, $
        title=string(wave_region, format='Plate scale for %s nm images'), $
        xstyle=9, xrange=[start_jd, end_jd], xtitle='Dates', xtickformat='label_date', $
        ystyle=9, yrange=platescale_range, ytitle='Plate scale [arcsec/pixel]'
  if (n_elements(changes) gt 0L) then begin
    for c = 0L, n_elements(changes) - 1L do begin
      annotation_xoffset = -3.0
      annotation_yoffset = - 0.1 * (!y.crange[1] - !y.crange[0])
      if (changes[c] gt start_jd) then begin
        plots, fltarr(2) + changes[c], !y.crange, color='0000ff'x
        caldat, changes[c], month, day, year
        date = string(year, month, day, format='%04d-%02d-%02d')
        xyouts, changes[c] + annotation_xoffset, !y.crange[1] + annotation_yoffset, /data, $
                date, alignment=1.0, charsize=0.5 * charsize, $
                color='888888'x
      endif
    endfor
  endif
 end


pro ucomp_plot_platescale, wave_regions, percentile, changes=changes
  compile_opt strictarr

  n_wave_regions = n_elements(wave_regions)

  mg_psbegin, filename=string(100.0 * percentile, format='ucomp.%d.platescale.ps'), $
              xsize=4.0, ysize=5.25, /inches, xoffset=0.25, yoffset=0.0, $
              /image, /retina, decomposed=1

  !p.multi = [0, 1, n_wave_regions]

  for w = 0L, n_wave_regions - 1L do begin
    filename = string(wave_regions[w], format='ucomp.%s.image_scale.txt')
    ucomp_plot_platescale_wave_region, filename, wave_regions[w], percentile, changes=changes
  endfor

  mg_psend
end

; main-level example program
; wave_regions = ['530', '637', '656', '670', '691', '706', '761', '789', $
;                 '802', '991', '1074', '1079', '1083']
wave_regions = ['530', '637', '656', '691', '706', '789', $
                '1074', '1079', '1083']
percentiles = [0.2, 0.5, 0.8]
changes = [julday(5, 26, 2021, 0, 0, 0), julday(2, 2, 2022, 0, 0, 0)]
for p = 0L, n_elements(percentiles) - 1L do begin
  ucomp_plot_platescale, wave_regions, percentiles[p], changes=changes
endfor

end
