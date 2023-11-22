; docformat = 'rst'

pro ucomp_plot_rest_wavelengths, filename
  compile_opt strictarr

  basename = file_basename(filename)

  nominal_center_wavelength = 1074.7

  tokens = strsplit(file_basename(filename), '.', /extract)
  program = tokens[5]

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
    tokens = strsplit(data[i], /extract)
    date_parts = long(ucomp_decompose_date(tokens[0]))
    dates[i] = julday(date_parts[1], date_parts[2], date_parts[0], 0.0, 0.0, 0.0)
    years[i] = date_parts[0] - 2000.0 + mg_ymd2doy(date_parts[0], date_parts[1], date_parts[2]) / 365.0
    wave_offset[i] = float(tokens[4])
    ;rest_wavelengths[i] = float(tokens[2]) - nominal_center_wavelength - wave_offset[i]
    rest_wavelengths[i] = float(tokens[2]) - wave_offset[i] + 1.89
  endfor

  year_cutoff = 21.65
  keep_indices = where(years gt year_cutoff, /null)
  years = years[keep_indices]
  rest_wavelengths = rest_wavelengths[keep_indices]
  wave_offset = wave_offset[keep_indices]

  ; c = 299792.458D
  ; rest_wavelengths *= c / nominal_center_wavelength

  title = string(program, format='Rest wavelength for 1074 nm (%s)')

  ; rest_wavelength_range = [-700.0, -400.0]
  ; rest_wavelength_range = [1072.5, 1073.0]
  rest_wavelength_range = [1074.2, 1075.0]

  window, xsize=1326/2, ysize=898/2, $
          title=string(basename, format='Rest wavelength for 1074 nm - %s'), $
          /free

  plot, years, rest_wavelengths, /nodata, $
        title=title, $
        psym=4, symsize=1.5, charsize=1.75, $
        color='000000'x, background='ffffff'x, $
        xstyle=1, xtitle='Date', $
        ystyle=1, yrange=rest_wavelength_range, $
        ytitle='Rest wavelength - offset [nm]'

  good_indices = where(finite(rest_wavelengths), /null, ncomplement=n_bad_points)

  years = years[good_indices]
  rest_wavelengths = rest_wavelengths[good_indices]
  print, n_bad_points, format='removed %d bad points'

  degree = 1L

  coeffs = poly_fit(years, rest_wavelengths, degree, chisq=best_chisqr)
  print, strjoin(string(coeffs, format='(F0.6)'), ', '), best_chisqr, $
         format='initial coeffs: %s, chi sqr: %0.5f'

  tolerance = [0.1]
  n = 100.0
  tolerance = 1.0 / (findgen(n) + 10.0)
  tolerance = 0.1 * exp(- 0.2 * findgen(n))
  tolerance = [0.1, 0.05, 0.02, 0.01, 0.0075]

  for t = 0L, n_elements(tolerance) - 1L do begin
    print
    print, tolerance[t], format='tolerance: %0.3f'
    differences = abs(poly(years, coeffs) - rest_wavelengths)
    good_indices = where(differences lt tolerance[t], $
      n_good_indices, complement=bad_indices, ncomplement=n_bad_points)

    oplot, [years[bad_indices]], [rest_wavelengths[bad_indices]], $
           psym=4, symsize=0.75, color='0000ff'x
    if (n_bad_points gt 0L) then begin
      print, strjoin(string(differences[bad_indices], format='(F0.3)'), ', '), $
             format='differences removed: %s'
    endif

    years = years[good_indices]
    rest_wavelengths = rest_wavelengths[good_indices]
    print, n_bad_points, format='removed %d bad points'

    coeffs = poly_fit(years, rest_wavelengths, degree, chisq=chisqr)
    print, t + 1, strjoin(string(coeffs, format='(F0.6)'), ', '), chisqr, n_good_indices, $
           format='%d. coeffs: %s, chi sqr: %0.5f (%d points)'
    if (chisqr gt best_chisqr) then begin
      print, 'worse, stopping'
      break
    endif else best_chisqr = chisqr
    wait, 1.0
  endfor

  oplot, years, rest_wavelengths, psym=4, symsize=1.5, color='000000'x
  oplot, years, poly(years, coeffs), color='000000'x, thick=2.0
  if (degree eq 1) then begin
    xyouts, 0.5, 0.25, /normal, alignment=0.5, $
            string(coeffs[1], format='%0.3f nm/year'), $
            charsize=1.5, color='000000'x
    ; TODO: print stddev on plot
  endif
end

; main-level example program

; ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh40.median.synoptic.txt'
; ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh40.median.waves.txt'
; ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh10.median.synoptic.txt'
; ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh10.median.waves.txt'

ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh40.median.combined-sorted.txt'

end
