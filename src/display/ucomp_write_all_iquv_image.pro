; docformat = 'rst'

;+
; Produce a plot of all the images in a UCoMP science file.
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
pro ucomp_write_all_iquv_image, file, data, run=run
  compile_opt strictarr

  reduce_dims_factor = 4L

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  iquv_basename = string(file_basename(file.l1_basename, '.fts'), $
                         format='(%"%s.iquv.all.png")')
  iquv_filename = filepath(iquv_basename, root=l1_dirname)

  intensity_display_min   = run->line(file.wave_region, 'intensity_display_min')
  intensity_display_max   = run->line(file.wave_region, 'intensity_display_max')
  intensity_display_gamma = run->line(file.wave_region, 'intensity_display_gamma')
  intensity_display_power = run->line(file.wave_region, 'intensity_display_power')

  quv_display_min   = run->line(file.wave_region, 'quv_display_min')
  quv_display_max   = run->line(file.wave_region, 'quv_display_max')
  quv_display_gamma = run->line(file.wave_region, 'quv_display_gamma')
  quv_display_power = run->line(file.wave_region, 'quv_display_power')

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  date_stamp = ucomp_dt2stamp(datetime)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=24, $
          set_resolution=[file.n_unique_wavelengths * nx, 4L * ny] / reduce_dims_factor

  n_colors = 252

  text_color = 252
  tvlct, 255, 255, 255, text_color
  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 0, 0, inflection_color

  tvlct, r, g, b, /get

  xmargin = 0.05
  ymargin = 0.03
  charsize = 1.0

  pol_states = ['I', 'Q', 'U', 'V']
  for e = 1L, file.n_extensions do begin
    if (file.n_extensions gt 1L) then begin
      ext_data = reform(data[*, *, *, e - 1L])
    endif else begin
      ext_data = reform(data[*, *, *])
    endelse

    dims = size(ext_data, /dimensions)

    for p = 0L, dims[2] - 1L do begin
      if (p eq 0) then begin
        display_min = intensity_display_min
        display_max = intensity_display_max
        display_gamma = intensity_display_gamma
        display_power = intensity_display_power
        ct_name = 'intensity'
      endif else begin
        display_min = quv_display_min
        display_max = quv_display_max
        display_gamma = quv_display_gamma
        display_power = quv_display_power
        ct_name = 'quv'
        ;ct_name = 'intensity'
      endelse

      ucomp_loadct, ct_name, n_colors=n_colors
      gamma_ct, display_gamma, /current

      im = rebin(ext_data[*, *, p], $
                 dims[0] / reduce_dims_factor, $
                 dims[1] / reduce_dims_factor)
      field_mask = ucomp_field_mask(dims[0] / reduce_dims_factor, $
                                    dims[1] / reduce_dims_factor, $
                                    run->epoch('field_radius') / reduce_dims_factor)
      scaled_im = bytscl((im * field_mask)^display_power, $
                         min=display_min, $
                         max=display_max, $
                         top=n_colors - 1L, $
                         /nan)

      tv, scaled_im, p * file.n_unique_wavelengths + e - 1L

      if (p eq 0L and e eq 1L) then begin
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (dims[2] - 2.5 * ymargin) * dims[1] / reduce_dims_factor, $
                /device, $
                string(run->line(file.wave_region, 'ionization'), $
                       file.wave_region, $
                       format='(%"%s!C%s nm")'), $
                charsize=charsize, color=text_color
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (dims[2] - 1.0 + ymargin) * dims[1] / reduce_dims_factor, $
                /device, $
                date_stamp, $
                charsize=charsize, color=text_color
      endif

      w = (e - 1L) mod file.n_unique_wavelength
      if (p eq 0L) then begin
        xyouts, (w + 0.5) * dims[0] / reduce_dims_factor, $
                (dims[2] - 3.0 * ymargin) * dims[1] / reduce_dims_factor, $
                /device, alignment=0.5, $
                string(file.wavelengths[w], format='(%"%0.2f nm")'), $
                charsize=charsize, color=text_color
      endif
      if (w eq file.n_unique_wavelength - 1L) then begin
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (dims[2] - p - 0.5 - 0.5 * ymargin) * dims[1] / reduce_dims_factor, $, $
                /device, $
                pol_states[p], $
                charsize=charsize, color=text_color
      endif
    endfor
  endfor

  ;write_gif, iquv_filename, tvrd(), r, g, b
  write_png, iquv_filename, tvrd(true=1)

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


; main-level example program

;date = '20220105'
date = '20211213'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

;l0_basename = '20220105.204523.49.ucomp.1074.l0.fts'
l0_basename = '20211213.190812.67.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

;l1_basename = '20220105.204523.ucomp.1074.l1.5.fts'
l1_basename = '20211213.190812.ucomp.1074.l1.5.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, ext_data=data, n_extensions=n_extensions
file.n_extensions = n_extensions

ucomp_write_all_iquv_image, file, data, run=run

obj_destroy, file
obj_destroy, run

end