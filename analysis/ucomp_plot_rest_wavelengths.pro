; docformat = 'rst'

pro ucomp_plot_rest_wavelengths, filename, $
                                 wave_region, program_name, threshold, $
                                 nominal_center_wavelength, rest_wavelength_range
  compile_opt strictarr

  basename = file_basename(filename)

  tokens = strsplit(file_basename(filename), '.', /extract)

  n_lines = file_lines(filename)
  dates = dblarr(n_lines)
  years = fltarr(n_lines)
  rest_wavelengths = fltarr(n_lines)
  wave_offset = fltarr(n_lines)
  data = strarr(n_lines)

  openr, lun, filename, /get_lun
  readf, lun, data
  free_lun, lun

  for i = 0L, n_lines - 1L do begin
    tokens = strsplit(data[i], ', ', /extract)
    date_parts = long(ucomp_decompose_date(tokens[2]))
    dates[i] = julday(date_parts[1], date_parts[2], date_parts[0], 0.0, 0.0, 0.0)
    years[i] = date_parts[0] - 2000.0 + mg_ymd2doy(date_parts[0], date_parts[1], date_parts[2]) / 365.0
    wave_offset[i] = float(tokens[6])
    rest_wavelengths[i] = float(tokens[4]) - wave_offset[i] + 1.89
  endfor

  ; mg_ymd2doy(2021, 7, 15) / 365.0 = 0.536986
  year_cutoff = 21.536986
  keep_indices = where(years gt year_cutoff, /null)
  years = years[keep_indices]
  rest_wavelengths = rest_wavelengths[keep_indices]
  wave_offset = wave_offset[keep_indices]

  ; c = 299792.458D
  ; rest_wavelengths *= c / nominal_center_wavelength

  title = string(wave_region, program_name, threshold, $
                 format='Rest wavelength for %s nm [%s] (threshold: %0.1f)')
  charsize = 0.90
  symsize = 0.75

  to_ps = 1B
  if (keyword_set(to_ps)) then begin
    original_device = !d.name
    set_plot, 'Z'
    device, set_resolution=[800, 500], $
            decomposed=1, $
            set_pixel_depth=24
  endif else begin
    window, xsize=1326/2, ysize=898/2, $
            title=string(wave_region, basename, format='Rest wavelength for %s nm - %s'), $
            /free
  endelse

  plot, years, rest_wavelengths, /nodata, $
        title=title, $
        psym=4, symsize=symsize, charsize=charsize, $
        color='000000'x, background='ffffff'x, $
        xstyle=1, xtitle='Date', $
        ystyle=1, yrange=rest_wavelength_range, $
        ytitle='Rest wavelength - offset [nm]'

  good_indices = where(finite(rest_wavelengths), /null, ncomplement=n_bad_points)

  dates = dates[good_indices]
  years = years[good_indices]
  rest_wavelengths = rest_wavelengths[good_indices]
  print, n_bad_points, format='removed %d bad points'

  degree = 2L

  coeffs = poly_fit(years, rest_wavelengths, degree, chisq=best_chisqr)
  print, strjoin(string(coeffs, format='(F0.6)'), ', '), best_chisqr, $
         format='initial coeffs: %s, chi sqr: %0.5f'

  ; tolerance = [0.1, 0.05, 0.02, 0.01, 0.0075]
  tolerance = [10.0, 1.0, 0.1, 0.05, 0.02, 0.01, 0.0075]

  for t = 0L, n_elements(tolerance) - 1L do begin
    print
    print, tolerance[t], format='tolerance: %0.3f'
    differences = abs(poly(years, coeffs) - rest_wavelengths)
    good_indices = where(differences lt tolerance[t], $
      n_good_indices, complement=bad_indices, ncomplement=n_bad_points)

    oplot, [years[bad_indices]], [rest_wavelengths[bad_indices]], $
           psym=4, symsize=symsize, color='0000ff'x
    for p = 0L, n_bad_points - 1L do begin
      caldat, dates[bad_indices[p]], month, day, year
      print, year, month, day, differences[bad_indices[p]], $
             format='%04d%02d%02d [difference: %0.3f]'

    endfor

    dates = dates[good_indices]
    years = years[good_indices]
    rest_wavelengths = rest_wavelengths[good_indices]
    print, n_bad_points, format='removed %d bad points'

    coeffs = poly_fit(years, rest_wavelengths, degree, chisq=chisqr, status=status)
    print, t + 1, strjoin(string(coeffs, format='(F0.6)'), ', '), chisqr, n_good_indices, $
           format='%d. coeffs: %s, chi sqr: %0.5f (%d points)'
    if (chisqr gt best_chisqr) then begin
      print, 'worse, stopping'
      break
    endif else best_chisqr = chisqr
    wait, 1.0
  endfor

  oplot, years, rest_wavelengths, psym=4, symsize=symsize, color='000000'x
  oplot, years, poly(years, coeffs), color='000000'x, thick=2.0
  if (degree eq 1) then begin
    xyouts, 0.5, 0.25, /normal, alignment=0.5, $
            string(coeffs[1], format='%0.3f nm/year'), $
            charsize=charsize, color='000000'x
    ; [TODO]: print stddev on plot
    ; [TODO]: print coefficients on plot
  endif

  if (keyword_set(to_ps)) then begin
    im = tvrd(true=1)
    set_plot, original_device
    output_filename = file_basename(filename, '.txt') + '.png'
    write_png, output_filename, im
  endif
end

; main-level example program

thresholds = [1.0, 4.0]
output_basename_format = 'ucomp.rstwvl.%s.wavoff.thresh%02d.median.%s.txt'

program_names = ['synoptic', 'waves']
wave_region = '1074'
nominal_center_wavelength = 1074.7
rest_wavelength_range = [1074.2, 1075.0]
for t = 0L, n_elements(thresholds) - 1L do begin
  ucomp_plot_rest_wavelengths, string(wave_region, 10.0 * thresholds[t], 'synoptic', $
                                      format=output_basename_format), $
                               wave_region, 'synoptic', thresholds[t], $
                               nominal_center_wavelength, rest_wavelength_range
  ucomp_plot_rest_wavelengths, string(wave_region, 10.0 * thresholds[t], 'waves', $
                                      format=output_basename_format), $
                               wave_region, 'waves', thresholds[t], $
                               nominal_center_wavelength, rest_wavelength_range
endfor

wave_region = '789'
nominal_center_wavelength = 789.4
rest_wavelength_range = [788.0, 791.0]
for t = 0L, n_elements(thresholds) - 1L do begin
  ucomp_plot_rest_wavelengths, string(wave_region, 10.0 * thresholds[t], 'synoptic', $
                                      format=output_basename_format), $
                               wave_region, 'synoptic', thresholds[t], $
                               nominal_center_wavelength, rest_wavelength_range
endfor


end
