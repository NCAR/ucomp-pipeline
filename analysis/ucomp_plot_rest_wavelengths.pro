; docformat = 'rst'

pro ucomp_plot_rest_wavelengths, filename
  compile_opt strictarr

  nominal_center_wavelength = 1074.7

  tokens = strsplit(file_basename(filename), '.', /extract)
  program = tokens[3]

  n_lines = file_lines(filename)
  dates = dblarr(n_lines)
  rest_wavelengths = fltarr(n_lines)
  data = strarr(n_lines)

  openr, lun, filename, /get_lun
  readf, lun, data
  free_lun, lun

  for i = 0L, n_lines - 1L do begin
    tokens = strsplit(data[i], /extract)
    date_parts = long(ucomp_decompose_date(tokens[0]))
    dates[i] = julday(date_parts[1], date_parts[2], date_parts[0], 0.0, 0.0, 0.0)
    rest_wavelengths[i] = float(tokens[2]) - nominal_center_wavelength
  endfor

  c = 299792.458D
  rest_wavelengths *= c / nominal_center_wavelength

  title = string(program, format='Rest wavelength for 1074 nm (%s)')

  ; TODO: use Steve's plotting parameters
  ;   - date in decimal years (from 2000)
  ;   - overplot synoptic and waves

  !null = label_date(date_format='%Y-%N-%D')
  window, xsize=900, ysize=300, title=title, /free
  plot, dates, rest_wavelengths, $
        title=title, $
        psym=4, symsize=0.3, $
        xstyle=1, xtitle='Date', xtickformat='label_date', $
        ystyle=1, yrange=[-50.0, 50.0], ytitle='Rest wavelength [km/s]'
end

; main-level example program

ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.median.synoptic.txt'
ucomp_plot_rest_wavelengths, 'ucomp.rstwvl.median.waves.txt'

end
