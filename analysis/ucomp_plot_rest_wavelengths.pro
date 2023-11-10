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
    rest_wavelengths[i] = float(tokens[2]) - wave_offset[i]
  endfor

  ; c = 299792.458D
  ; rest_wavelengths *= c / nominal_center_wavelength

  title = string(program, format='Rest wavelength for 1074 nm (%s)')

  ; TODO: use Steve's plotting parameters
  ;   - date in decimal years (from 2000)
  ;   - overplot synoptic and waves
  ;   - fit line to data

  ; rest_wavelength_range = [-700.0, -400.0]
  rest_wavelength_range = [1072.5, 1073.0]

  good_indices = where(finite(rest_wavelengths), /null)
  coeffs = linfit(years[good_indices], rest_wavelengths[good_indices])
  print, coeffs

  !null = label_date(date_format='%Y-%N-%D')
  window, xsize=1326/2, ysize=898/2, $
          title=string(basename, format='Rest wavelength for 1074 nm - %s'), $
          /free
  plot, years, rest_wavelengths, $
        title=title, $
        psym=4, symsize=1.5, charsize=1.75, $
        color='000000'x, background='ffffff'x, $
        xstyle=1, xtitle='Date', $;xtickformat='label_date', $
        ystyle=1, yrange=rest_wavelength_range, ytitle='Rest wavelength - offset [nm]'
  oplot, years, coeffs[0] + years * coeffs[1], color='000000'x
  xyouts, 0.5, 0.25, /normal, alignment=0.5, $
          string(coeffs[1], format='%0.2f nm/year'), $
          charsize=1.5, color='000000'x
end

; main-level example program

ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh40.median.synoptic.txt'
ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh40.median.waves.txt'
ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh10.median.synoptic.txt'
ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.wavoff.thresh10.median.waves.txt'

end
