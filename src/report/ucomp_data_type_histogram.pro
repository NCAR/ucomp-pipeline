; docformat = 'rst'


;+
; Make a histogram plot of the raw files from the day, color coded by data
; type, i.e., dark, flat, cal pol, or sci.
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
pro ucomp_data_type_histogram, output_filename, $
                               run=run, $
                               bin_size=bin_size
  compile_opt strictarr

  mg_log, 'producing data type histogram...', name=run.logger_name, /info

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

  data_types = ['dark', 'flat', 'cal', 'sci']
  n_data_types = n_elements(data_types)
  colors = ['000000'x, 'ca7140'x, '4059ca'x, '40ca4a'x]

  histograms       = lonarr(n_data_types, n_bins)
  n_files_per_type = lonarr(n_data_types)

  for d = 0L, n_data_types - 1L do begin
    files = run->get_files(data_type=data_types[d], count=n_files)

    n_files_per_type[d] = n_files
    if (n_files eq 0L) then continue

    hst_times = fltarr(n_files)
    for f = 0L, n_files - 1L do begin
      hst_times[f] = ucomp_decompose_time(files[f].hst_time, /float)
    endfor

    if (n_elements(hst_times) gt 0L) then begin
      histograms[d, *] = histogram(hst_times, $
                                   min=start_time, $
                                   max=end_time - _bin_size / 60.0, $
                                   nbins=n_bins, $
                                   locations=locations)
    endif
  endfor

  ind = where(n_files_per_type gt 0L, n_nonzero_wave_regions)
  if (n_nonzero_wave_regions eq 0) then begin
    mg_log, 'no files to plot', name=run.logger_name, /warn
    return
  endif

  histograms   = histograms[ind, *]
  data_types   = data_types[ind]
  colors       = colors[ind]

  ; display plot
  ucomp_timeline_histogram, output_filename, $
                            histograms, $
                            _bin_size, $
                            data_types, $
                            start_time=start_time, $
                            end_time=end_time, $
                            ymax=max_files, $
                            colors=colors, $
                            logger_name=run.logger_name

  done:
end
