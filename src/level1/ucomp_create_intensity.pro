; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_create_intensity, file, data, run=run, occulter_annotation=occulter_annotation
  compile_opt strictarr

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                     format='(%"%s.int.cam%%d.ext%%02d.gif")')
  intensity_filename_format = mg_format(filepath(intensity_basename_format, $
                                                 root=l1_dirname))

  display_min   = run->line(file.wave_region, 'intensity_display_min')
  display_max   = run->line(file.wave_region, 'intensity_display_max')
  display_gamma = run->line(file.wave_region, 'intensity_display_gamma')

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_resolution=[nx, ny]

  n_colors = 255
  loadct, 0, /silent, ncolors=n_colors
  gamma_ct, display_gamma, /current
  occulter_color = 255
  tvlct, 255, 255, 0, occulter_color

  tvlct, r, g, b, /get

  for e = 1L, file.n_extensions do begin
    for c = 0L, 1L do begin
      if (file.n_extensions gt 1L) then begin
        im = reform(data[*, *, *, c, e - 1L])
      endif else begin
        im = reform(data[*, *, *, c])
      endelse
      im = total(im, 3, /preserve_type)

      scaled_im = bytscl(im, min=display_min, max=display_max, top=n_colors - 1L)
      mg_log, 'scaled_im: max: %d', max(scaled_im), name=run.logger_name, /debug
      tv, scaled_im
      xyouts, 15, 15, /device, alignment=0.0, $
              string(e, format='(%"ext: %d")')
      xyouts, nx - 15, 15, /device, alignment=1.0, $
              string(display_min, display_max, display_gamma, $
                     format='(%"min/max: %0.1f/%0.1f, gamma: %0.1f")')
  
      if (keyword_set(occulter_annotation)) then begin
        case c of
          0: begin
              x0 = file.rcam_xcenter
              y0 = file.rcam_ycenter
              radius = file.rcam_radius
            end
          1: begin
              x0 = file.tcam_xcenter
              y0 = file.tcam_ycenter
              radius = file.tcam_radius
            end
        endcase
        t = findgen(360) * !dtor
        x = radius * cos(t) + x0
        y = radius * sin(t) + y0
        plots, x, y, /device, color=occulter_color
        plots, x0, y0, /device, color=occulter_color, psym=1
      endif
      write_gif, string(c, e, format=intensity_filename_format), tvrd(), r, g, b
    endfor
  endfor

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
