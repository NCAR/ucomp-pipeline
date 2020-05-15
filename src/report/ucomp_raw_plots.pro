; docformat = 'rst'

pro ucomp_raw_plots, run=run
  compile_opt strictarr

  ; TODO: these files are not in chronological order
  files = run->get_files(count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no raw files to plot, skipping', name=run.logger_name, /info
    goto, done
  endif else begin
    mg_log, 'plotting %d raw files', n_files, name=run.logger_name, /info
  endelse

  n_plots = 4L

  ; save original graphics settings
  original_device = !d.name
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get

  ; setup graphics device
  set_plot, 'Z'
  device, decomposed=0, $
          set_resolution=[800, n_plots * 300]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 0, 0, 255, 3
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  camera0_color    = 2
  camera1_color    = 3

  times = fltarr(n_files)
  for f = 0L, n_files - 1L do times[f] = files[f].obsday_hours
  t_c0arr = fltarr(n_files)
  for f = 0L, n_files - 1L do t_c0arr[f] = files[f].cam0_arr_temp
  t_c0pcb = fltarr(n_files)
  for f = 0L, n_files - 1L do t_c0pcb[f] = files[f].cam0_pcb_temp
  t_c1arr = fltarr(n_files)
  for f = 0L, n_files - 1L do t_c1arr[f] = files[f].cam1_arr_temp
  t_c1pcb = fltarr(n_files)
  for f = 0L, n_files - 1L do t_c1pcb[f] = files[f].cam1_pcb_temp

  tarr_min =  9.0 < floor(min([t_c0arr, t_c1arr]))
  tarr_max = 11.0 > ceil(max([t_c0arr, t_c1arr]))
  tpcb_min = 25.0 < floor(min([t_c0pcb, t_c1pcb]))
  tpcb_max = 27.0 > ceil(max([t_c0pcb, t_c1pcb]))

  start_time = 06   ; 24-hour time in observing day
  end_time   = 19   ; 24-hour time in observing day
  end_time  >= ceil(max(times))

  charsize = 2.0
  symsize  = 0.50

  ; plot of temperatures T_C{0,1}ARR and T_C{0,1}PCB per dark

  !p.multi = [0, 1, n_plots]

  plot, times, t_c0arr, /nodata, $
        title='Raw sensor array temperatures', charsize=charsize, $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=[start_time, end_time], xticks=end_time - start_time, $
        ytitle='Temperature [C]', $
        ystyle=1, yrange=[tarr_min, tarr_max]
  oplot, times, t_c0arr, $
         psym=6, symsize=symsize, $
         linestyle=0, color=camera0_color
  oplot, times, t_c1arr, $
         psym=6, symsize=symsize, $
         linestyle=0, color=camera1_color

  xyouts, 0.95, 0.75 + 0.80 * 0.25, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.75 + 0.75 * 0.25, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  plot, times, t_c0pcb, /nodata, $
        title='Raw PCB board temperatures', charsize=charsize, $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=[start_time, end_time], xticks=end_time - start_time, $
        ytitle='Temperature [C]', $
        ystyle=1, yrange=[tpcb_min, tpcb_max]
  oplot, times, t_c0pcb, $
         psym=6, symsize=symsize, $
         linestyle=0, color=camera0_color
  oplot, times, t_c1pcb, $
         psym=6, symsize=symsize, $
         linestyle=0, color=camera1_color

  xyouts, 0.95, 0.50 + 0.80 * 0.25, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.50 + 0.75 * 0.25, /normal, $
          'camera 1', alignment=1.0, color=camera1_color


  ; save plots image file
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(run.date), $
                     root=run->config('engineering/basedir'))
  if (~file_test(eng_dir, /directory)) then ucomp_mkdir, eng_dir
  output_filename = filepath(string(run.date, format='(%"%s.ucomp.raw.gif")'), $
                             root=eng_dir)
  write_gif, output_filename, tvrd(), r, g, b

  done:
  !p.multi = 0
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
