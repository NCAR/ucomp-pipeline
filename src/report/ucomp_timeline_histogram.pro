; docformat = 'rst'

;+
; Produce an end-of-day stacked histogram plot showing the timeline of various
; types of files, e.g., the distribution of the files by wave region.
;
; :Params:
;   output_filename : in, required, type=string
;     full path to output filename
;   histograms : in, required, type="lonarr(n_files, n_categories)"
;     data for stacked histogram
;   bin_size : in, required, type=float
;     size, in minutes, of the bins in the histogram
;   item_names : in, required, type=strarr
;     names of the various categories in the stacked histogram
;
; :Keywords:
;   start_time : in, required, type=float, default=6
;     local time for start of plot
;   end_time : in, required, type=float, default=19
;     local time for end of plot
;   ymax : in, optional, type=float
;     maximum y-axis value to plot, default is the total over the first
;     dimension of `histograms`
;   colors : in, required, type=lonarr
;     array of colors to use for the various categories in the histogram
;   logger_name : in, optional, type=string
;     name of logger to send messages to
;-
pro ucomp_timeline_histogram, output_filename, $
                              histograms, $
                              bin_size, $
                              item_names, $
                              start_time=start_time, $
                              end_time=end_time, $
                              ymax=ymax, $
                              colors=colors, $
                              logger_name=logger_name
  compile_opt strictarr

  hist_dims = size(histograms, /dimensions)
  n_types = hist_dims[0]
  n_bins = hist_dims[1]

  _start_time = mg_default(start_time, 06)   ; 24-hour time in observing day
  _end_time   = mg_default(end_time, 19)     ; 24-hour time in observing day

  ut_start_time = _start_time + 10L
  ut_end_time   = _end_time + 10L

  original_device = !d.name
  set_plot, 'Z'
  device, set_resolution=[600, 200], set_pixel_depth=24, decomposed=1
  tvlct, original_rgb, /get

  sums = total(histograms, 2, /preserve_type)
  _ymax = mg_default(ymax, 0L)
  _ymax >= max(total(histograms, 1, /preserve_type))

  mg_stacked_histplot, ((bin_size / 60.0) * findgen(n_bins) + _start_time), $
                       histograms, $
                       axis_color='000000'x, $
                       background='ffffff'x, color=colors, /fill, $
                       xstyle=9, xticks=_end_time - _start_time, xminor=4, $
                       ystyle=1, yrange=[0, _ymax], yticks=4, $
                       charsize=0.85, $
                       xtitle='Time (HST)', ytitle='# of files', $
                       position=[0.075, 0.20, 0.75, 0.80]
  axis, _start_time, _ymax, xaxis=1, /data, $
        color='000000'x, charsize=0.85, $
        xticks=_end_time - _start_time, xminor=4, $
        xrange=[ut_start_time, ut_end_time], $
        xtitle='Time (UT)', $
        xtickname=strtrim((lindgen(n_bins / 4 + 1L) + ut_start_time) mod 24, 2)

  square = mg_usersym(/square, /fill)
  legend_position = [0.7825, 0.90 - 0.1 * n_types, 0.9575, 0.90]

  mg_legend, item_name=item_names + ': ' + strtrim(sums, 2), $
             item_color=colors, $
             item_psym=square, $
             item_symsize=1.5, $
             color='000000'x, $
             charsize=0.85, $
             gap=0.075, $
             line_bump=0.2125, $
             position=legend_position

  im = tvrd(true=1)
  tvlct, original_rgb
  set_plot, original_device

  ; make directory for output file, if it doesn't already exist
  dir_name = file_dirname(output_filename)
  ucomp_mkdir, dir_name, logger_name=logger_name

  write_png, output_filename, im
end
