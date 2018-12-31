; docformat = 'rst'


;+
; Make a histogram plot of the raw files from the day, color coded by wave
; type.
;
; :Params:
;   output_filename : in, required, type=string
;     filename for output PNG
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   bin_size : in, optional, type=integer, default=15
;     size of bin in minutes
;-
pro ucomp_wave_type_histogram, output_filename, $
                               run=run, $
                               bin_size=bin_size
  compile_opt strictarr

  mg_log, 'producing wave type histgram...', name=run.logger_name, /info

  ; create wave_type histogram

  start_time = 06   ; 24-hour time
  end_time   = 19   ; 24-hour time

  _bin_size  = mg_default(bin_size, 15)   ; minutes
  max_rate   = 1.33                       ; max rate in files/minute

  max_files  = max_rate * _bin_size
  n_bins     = long((end_time  - start_time) / (_bin_size / 60.0))

  wave_types       = run->config('options/wave_types')
  n_wave_types     = n_elements(wave_types)
  histograms       = lonarr(n_wave_types, n_bins)
  n_files_per_type = lonarr(n_wave_types)

  for t = 0L, n_wave_types - 1L do begin
    run->getProperty, files=files, wave_type=wave_types[t], count=n_files
    n_files_per_type[t] = n_files
    if (n_files eq 0L) then continue

    hst_times = fltarr(n_files)
    for f = 0L, n_files - 1L do begin
      hst_times[f] = ucomp_decompose_time(files[f].hst_time, /float)
    endfor

    if (n_elements(hst_times) gt 0L) then begin
      histograms[t, *] = histogram(hst_times, $
                                   min=start_time, $
                                   max=end_time - _bin_size / 60.0, $
                                   nbins=n_bins, $
                                   locations=locations)
    endif
  endfor

  colors = lonarr(n_wave_types)
  for t = 0L, n_wave_types - 1L do begin
    hex_color = run->config(wave_types[t] + '/color')
    reads, hex_color, color, format='(Z)'
    colors[t] = color
  endfor

  ind = where(n_files_per_type gt 0L, n_nonzero_wave_types)
  if (n_nonzero_wave_types eq 0) then begin
    mg_log, 'no files to plot', name=run.logger_name, /warn
    return
  endif
  histograms = histograms[ind, *]
  colors     = colors[ind]
  wave_types = wave_types[ind]
  wave_names = wave_types
  for w = 0L, n_nonzero_wave_types - 1L do begin
    wave_names[w] = run->line(wave_types[w], 'name')
  endfor

  ; display plot

  original_device = !d.name
  set_plot, 'Z'
  device, set_resolution=[600, 120], set_pixel_depth=24, decomposed=1
  tvlct, original_rgb, /get

  sums = total(histograms, 2, /preserve_type)
  mg_stacked_histplot, (_bin_size / 60.0) * findgen(n_bins) + start_time, $
                       histograms, $
                       axis_color='000000'x, $
                       background='ffffff'x, color=colors, /fill, $
                       xstyle=9, xticks=end_time - start_time, xminor=4, $
                       ystyle=9, yrange=[0, max_files], yticks=4, $
                       charsize=0.85, $
                       xtitle='Time (HST)', ytitle='# of files', $
                       position=[0.075, 0.25, 0.75, 0.95]

  square = mg_usersym(/square, /fill)
  mg_legend, item_name=wave_types + ' (' + wave_names + ') '+ strtrim(sums, 2), $
             item_color=colors, $
             item_psym=square, $
             item_symsize=1.5, $
             color='000000'x, $
             charsize=0.85, $
             gap=0.075, $
             position=[0.775, 0.15, 0.95, 0.95]

  im = tvrd(true=1)
  tvlct, original_rgb
  set_plot, original_device

  ; make directory for output file, if it doesn't already exist
  dir_name = file_dirname(output_filename)
  if (~file_test(dir_name, /directory)) then begin
    file_mkdir, dir_name
    ucomp_fix_permissions, dir_name, /directory, logger_name=run.logger_name
  endif

  write_png, output_filename, im
end
