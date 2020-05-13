; docformat = 'rst'

pro ucomp_dark_plots, dark_info, run=run
  compile_opt strictarr

  n_plots = 4L

  ; save original graphics settings
  original_device = !d.name
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get

  ; setup graphics device
  set_plot, 'Z'
  device, decomposed=0, $
          ;set_pixel_depth=24, $
          set_resolution=[800, n_plots * 300]
  !p.multi = [0, 1, n_plots]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 0, 0, 255, 3
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  camera0_color    = 2
  camera1_color    = 3

  tarr_min =  9.0 < floor(min([dark_info.t_c0arr, dark_info.t_c1arr]))
  tarr_max = 11.0 > ceil(max([dark_info.t_c0arr, dark_info.t_c1arr]))
  tpcb_min = 25.0 < floor(min([dark_info.t_c0pcb, dark_info.t_c1pcb]))
  tpcb_max = 27.0 > ceil(max([dark_info.t_c0pcb, dark_info.t_c1pcb]))

  start_time = 06   ; 24-hour time in observing day
  end_time   = 19   ; 24-hour time in observing day
  end_time  >= ceil(max(dark_info.times))

  charsize = 2.0
  symsize = 0.75

  ; plot of temperatures T_C{0,1}ARR and T_C{0,1}PCB per dark, one plot per camera
  plot, dark_info.times, dark_info.t_c0arr, /nodata, $
        title='Dark array temperatures', charsize=charsize, $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=[start_time, end_time], xticks=end_time - start_time, $
        ytitle='Temperature [C]', $
        ystyle=1, yrange=[tarr_min, tarr_max]
  oplot, dark_info.times, dark_info.t_c0arr, $
         psym=-6, symsize=symsize, $
         linestyle=0, color=camera0_color
  oplot, dark_info.times, dark_info.t_c1arr, $
         psym=-6, symsize=symsize, $
         linestyle=0, color=camera1_color
  xyouts, 0.95, 0.75 + 0.80 * 0.25, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.75 + 0.75 * 0.25, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  plot, dark_info.times, dark_info.t_c0pcb, /nodata, $
        title='Dark PCB temperatures', charsize=charsize, $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=[start_time, end_time], xticks=end_time - start_time, $
        ytitle='Temperature [C]', $
        ystyle=1, yrange=[tpcb_min, tpcb_max]
  oplot, dark_info.times, dark_info.t_c0pcb, $
         psym=-6, symsize=symsize, $
         linestyle=0, color=camera0_color
  oplot, dark_info.times, dark_info.t_c1pcb, $
         psym=-6, symsize=symsize, $
         linestyle=0, color=camera1_color
  xyouts, 0.95, 0.50 + 0.80 * 0.25, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.50 + 0.75 * 0.25, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  ; plot of dark means, std devs, quartiles by time per camera

  ; save plots image file
  output_filename = filepath(string(run.date, format='(%"%s.ucomp.darks.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  !p.multi = 0
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
