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

  mg_log, 'producing wave region histogram...', name=run.logger_name, /info

  start_time = 06   ; 24-hour time in observing day
  end_time   = 18   ; 24-hour time in observing day

  all_files = run->get_files()
  if (n_elements(all_files) eq 0L) then begin
    mg_log, 'no files in inventory, skipping', name=run.logger_name, /warn
    goto, done
  endif
  last_hst_time = all_files[-1].hst_time
  end_time >= 24L * (run.date ne all_files[-1].hst_date) $
                + long(strmid(last_hst_time, 0, 2)) $
                + (strmid(last_hst_time, 2, 2) ne '00')

  _bin_size  = mg_default(bin_size, 15)   ; minutes
  max_rate   = 1.33                       ; max rate in files/minute

  max_files  = max_rate * _bin_size
  n_bins     = long((end_time - start_time) / (_bin_size / 60.0))

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

  lines = run->all_lines()

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
    endif else if (wave_regions[w] eq '') then begin
      wave_names[w] = 'darks'
    endif else begin
      wave_names[w] = 'unknown'
    endelse
  endfor

  wave_region_names = wave_regions
  wave_region_names[where(wave_regions eq '', /null)] = '-'
  item_names = wave_region_names + ' [' + wave_names + ']'

  ; display plot
  ucomp_timeline_histogram, output_filename, $
                            histograms, $
                            _bin_size, $
                            item_names, $
                            start_time=start_time, $
                            end_time=end_time, $
                            ymax=max_files, $
                            colors=colors, $
                            logger_name=run.logger_name

  done:
end


; main-level example program

date = '20210312'
config_filename = filepath('ucomp.production.cfg', $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'eod', config_filename, /no_log)
run->make_raw_inventory

engineering_basedir = run->config('engineering/basedir')
ucomp_wave_region_histogram, filepath(string(run.date, $
                                             format='(%"%s.ucomp.daily.wave_regions.png")'), $
                                      subdir=ucomp_decompose_date(run.date), $
                                      root=engineering_basedir), $
                             run=run
obj_destroy, run

end
