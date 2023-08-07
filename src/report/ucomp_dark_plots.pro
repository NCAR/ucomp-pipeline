; docformat = 'rst'

;+
; Make an engineering plot of the dark values and temperatures.
;
; :Params:
;   dark_info : in, required, type=array of structures
;   dark_images : in, required, type="fltarr(nx, ny, n_darks)"
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_dark_plots, dark_info, dark_images, run=run
  compile_opt strictarr

  mg_log, 'making dark plots', name=run.logger_name, /info

  n_darks = n_elements(dark_info.times)
  if (n_darks eq 0L) then begin
    mg_log, 'no darks to plot', name=run.logger_name, /info
    goto, done
  endif

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[800, 5 * 300]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 0, 0, 255, 3
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  camera0_color    = 2
  camera1_color    = 3

  camera0_psym     = 6
  camera1_psym     = 4
  symsize          = 0.75

  tarr_range = run->epoch('dark_arr_temp_range', datetime=run.date)
  tpcb_range = run->epoch('dark_pcb_temp_range', datetime=run.date)

  time_range = [16.0, 28.0]
  time_ticks = time_range[1] - time_range[0]

  charsize = 2.0

  n_plots = 5

  ; plot of temperatures T_C{0,1}ARR and T_C{0,1}PCB per dark

  p = 0
  !p.multi = [0, 1, n_plots]

  plot, [dark_info.times + 10.0], [dark_info.t_c0arr], /nodata, $
        title='Dark sensor array temperatures', charsize=charsize, $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=time_range, xticks=12, $
        xtickformat='ucomp_hours_format', $
        ytitle='Temperature [C]', $
        ystyle=1, yrange=tarr_range
  mg_range_oplot, [dark_info.times], [dark_info.t_c0arr], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times], [dark_info.t_c1arr], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  xyouts, 0.95, (n_plots - p - 0.20) / n_plots, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, (n_plots - p - 0.25) / n_plots, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  p = 1
  plot, [dark_info.times + 10.0], [dark_info.t_c0pcb], /nodata, $
        title='Dark PCB temperatures', charsize=charsize, $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=time_range, xticks=time_ticks, $
        xtickformat='ucomp_hours_format', $
        ytitle='Temperature [C]', $
        ystyle=1, yrange=tpcb_range
  mg_range_oplot, [dark_info.times + 10.0], [dark_info.t_c0pcb], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times + 10.0], [dark_info.t_c1pcb], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  xyouts, 0.95, (n_plots - p - 0.20) / n_plots, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, (n_plots - p - 0.25) / n_plots, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  ; plot intensity (mean or median?) vs temperature

  n_dims = size(dark_images, /n_dimensions)
  dims = size(dark_images, /dimensions)

  if (n_darks gt 1L) then begin
    cam0_dark_means   = fltarr(n_darks)
    cam1_dark_means   = fltarr(n_darks)
    cam0_dark_medians = fltarr(n_darks)
    cam1_dark_medians = fltarr(n_darks)
    cam0_dark_stddev  = fltarr(n_darks)
    cam1_dark_stddev  = fltarr(n_darks)
    for d = 0, n_darks - 1L do begin
      cam0_dark_means[d]  = mean(dark_images[*, *, 0, d])
      cam1_dark_means[d]  = mean(dark_images[*, *, 1, d])
      cam0_dark_medians[d] = median(dark_images[*, *, 0, d])
      cam1_dark_medians[d] = median(dark_images[*, *, 1, d])
      cam0_dark_stddev[d] = stddev(dark_images[*, *, 0, d])
      cam1_dark_stddev[d] = stddev(dark_images[*, *, 1, d])
    endfor
  endif else begin
    cam0_dark_means   = mean(dark_images[*, *, 0])
    cam1_dark_means   = mean(dark_images[*, *, 1])
    cam0_dark_medians = median(dark_images[*, *, 0])
    cam1_dark_medians = median(dark_images[*, *, 1])
    cam0_dark_stddev  = stddev(dark_images[*, *, 0])
    cam1_dark_stddev  = stddev(dark_images[*, *, 1])
  endelse

  ; max_dark_stddev = max(abs([cam0_dark_stddev, cam0_dark_stddev]))
  ; dark_min    = min(dark_images, max=dark_max)
  ; dark_range  = [dark_min - max_dark_stddev, dark_max + max_dark_stddev]

  dark_range  = run->epoch('dark_value_range', datetime=run.date)

  p = 2
  !p.multi = [(n_plots - p) * 2, 2, n_plots]

  plot, [dark_info.t_c0arr], [cam0_dark_medians], /nodata, $
        charsize=charsize, title='Dark sensor temperature vs. median counts', $
        psym=camera0_psym, symsize=symsize, $
        color=color, background=background_color, $
        xtitle='Sensor array temperature [C]', $
        xstyle=1, xrange=tarr_range, $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'
  mg_range_oplot, [dark_info.t_c0arr], [cam0_dark_medians], $
                  psym=camera0_psym, symsize=symsize, $
                  color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.t_c1arr], [cam1_dark_medians], $
                  psym=camera1_psym, symsize=symsize, $
                  color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  plot, [dark_info.t_c1pcb], [cam1_dark_medians], /nodata, $
        charsize=charsize, title='Dark PCB temperature vs. median counts', $
        psym=camera0_psym, symsize=symsize, $
        color=color, background=background_color, $
        xtitle='PCB temperature [C]', $
        xstyle=1, xrange=tpcb_range, $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'
  mg_range_oplot, [dark_info.t_c0pcb], [cam0_dark_medians], $
                  psym=camera0_psym, symsize=symsize, $
                  color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.t_c1pcb], [cam1_dark_medians], $
                  psym=camera1_psym, symsize=symsize, $
                  color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0


  ; plot of dark means, std devs, quartiles by time per camera
  p = 3
  !p.multi = [n_plots - p, 1, n_plots]

  ; use a horizontal dash for quartile values
  usersym, 2.0 * [-1.0, 1.0], fltarr(2)

  plot, [dark_info.times + 10.0], [cam0_dark_means], /nodata, $
        charsize=charsize, title='Dark mean counts vs. time', $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=time_range, xticks=time_ticks, $
        xtickformat='ucomp_hours_format', $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, $
        yrange=dark_range[0] + [0.0, 4.0 * (dark_range[1] - dark_range[0])], $
        ytickformat='ucomp_dn_format'

  mg_range_oplot, [dark_info.times], [cam0_dark_means], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times], [cam1_dark_means], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  xyouts, 0.95, (n_plots - p - 0.20) / n_plots, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, (n_plots - p - 0.25) / n_plots, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  p = 4

  plot, [dark_info.times + 10.0], [cam0_dark_medians], /nodata, $
        charsize=charsize, title='Dark median counts vs. time', $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=time_range, xticks=time_ticks, $
        xtickformat='ucomp_hours_format', $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'

  mg_range_oplot, [dark_info.times], $
                  dark_range[0] > [cam0_dark_medians] < dark_range[1], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times], $
                  dark_range[0] > [cam0_dark_medians - cam0_dark_stddev] < dark_range[1], $
                  psym=8, symsize=0.5 * symsize, $
                  linestyle=1, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times], $
                  dark_range[0] > [cam0_dark_medians + cam0_dark_stddev] < dark_range[1], $
                  psym=8, symsize=0.5 * symsize, $
                  linestyle=1, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0

  ; offset camera 1 times so you can see them if they overlap with camera 0
  cam1_offset = 0.025

  mg_range_oplot, [dark_info.times] + cam1_offset, $
         dark_range[0] > [cam1_dark_medians] < dark_range[1], $
         psym=camera0_psym, symsize=symsize, $
         linestyle=0, color=camera1_color, $
         clip_color=camera1_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times] + cam1_offset, $
         dark_range[0] > [cam1_dark_medians - cam1_dark_stddev] < dark_range[1], $
         psym=8, symsize=0.5 * symsize, $
         linestyle=1, color=camera1_color, $
         clip_color=camera1_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, [dark_info.times] + cam1_offset, $
         dark_range[0] > [cam1_dark_medians + cam1_dark_stddev] < dark_range[1], $
         psym=8, symsize=0.5 * symsize, $
         linestyle=1, color=camera1_color, $
         clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  xyouts, 0.95, (n_plots - p - 0.20) / n_plots, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, (n_plots - p - 0.25) / n_plots, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  ; save plots image file
  output_filename = filepath(string(run.date, format='(%"%s.ucomp.darks.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device

  mg_log, 'done', name=run.logger_name, /info
end
