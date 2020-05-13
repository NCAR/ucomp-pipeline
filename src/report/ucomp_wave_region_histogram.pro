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
pro ucomp_wave_region_histogram, output_filename, $
                                 run=run, $
                                 bin_size=bin_size
  compile_opt strictarr

  mg_log, 'producing wave region histgram...', name=run.logger_name, /info

  ; create wave_region histogram

  start_time = 06   ; 24-hour time in observing day
  end_time   = 19   ; 24-hour time in observing day

  all_files = run->get_files()
  last_hst_time = all_files[-1].hst_time
  end_time >= 24L * (run.date ne all_files[-1].hst_date) $
                + long(strmid(last_hst_time, 0, 2)) $
                + (strmid(last_hst_time, 2, 2) ne '00')

  ut_start_time = start_time + 10L
  ut_end_time = end_time + 10L

  _bin_size  = mg_default(bin_size, 15)   ; minutes
  max_rate   = 1.33                       ; max rate in files/minute

  max_files  = max_rate * _bin_size
  n_bins     = long((end_time  - start_time) / (_bin_size / 60.0))

  ;wave_regions     = run->config('options/wave_regions')
  run->getProperty, all_wave_regions=wave_regions
  n_wave_regions   = n_elements(wave_regions)
  histograms       = lonarr(n_wave_regions, n_bins)
  n_files_per_type = lonarr(n_wave_regions)

  for t = 0L, n_wave_regions - 1L do begin
    files = run->get_files(wave_region=wave_regions[t], count=n_files)

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

  lines = run->line()

  colors = lonarr(n_wave_regions)
  for t = 0L, n_wave_regions - 1L do begin
    if (mg_in(lines, wave_regions[t])) then begin
      hex_color = run->config(wave_regions[t] + '/color')
    endif else begin
      hex_color = '000000'
    endelse
    reads, hex_color, color, format='(Z)'
    colors[t] = color
  endfor

  ind = where(n_files_per_type gt 0L, n_nonzero_wave_regions)
  if (n_nonzero_wave_regions eq 0) then begin
    mg_log, 'no files to plot', name=run.logger_name, /warn
    return
  endif
  histograms   = histograms[ind, *]
  colors       = colors[ind]
  wave_regions = wave_regions[ind]
  wave_names   = wave_regions
  for w = 0L, n_nonzero_wave_regions - 1L do begin
    if (mg_in(lines, wave_regions[w])) then begin
      wave_names[w] = run->line(wave_regions[w], 'name')
    endif else begin
      wave_names[w] = 'unknown'
    endelse
  endfor

  ; display plot

  original_device = !d.name
  set_plot, 'Z'
  device, set_resolution=[600, 200], set_pixel_depth=24, decomposed=1
  tvlct, original_rgb, /get

  sums = total(histograms, 2, /preserve_type)
  mg_stacked_histplot, ((_bin_size / 60.0) * findgen(n_bins) + start_time), $
                       histograms, $
                       axis_color='000000'x, $
                       background='ffffff'x, color=colors, /fill, $
                       xstyle=9, xticks=end_time - start_time, xminor=4, $
                       ystyle=9, yrange=[0, max_files], yticks=4, $
                       charsize=0.85, $
                       xtitle='Time (HST)', ytitle='# of files', $
                       position=[0.075, 0.20, 0.75, 0.80]
  axis, start_time, max_files, xaxis=1, /data, $
        color='000000'x, charsize=0.85, $
        xticks=end_time - start_time, xminor=4, $
        xrange=[ut_start_time, ut_end_time], $
        xtitle='Time (UT)', $
        xtickname=strtrim((lindgen(n_bins / 4 + 1L) + ut_start_time) mod 24, 2)

  square = mg_usersym(/square, /fill)
  mg_legend, item_name=wave_regions + ' [' + wave_names + ']: '+ strtrim(sums, 2), $
             item_color=colors, $
             item_psym=square, $
             item_symsize=1.5, $
             color='000000'x, $
             charsize=0.85, $
             gap=0.075, $
             line_bump=0.2125, $
             position=[0.7825, 0.10, 0.9575, 0.90]

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
