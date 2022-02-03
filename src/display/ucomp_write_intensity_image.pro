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
pro ucomp_write_intensity_image, file, data, run=run
  compile_opt strictarr

  occulter_annotation=run->config('centering/annotated_gifs')
  center_wavelength_only = run->config('intensity/center_wavelength_gifs_only')

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  if (center_wavelength_only) then begin
    intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                       format='(%"%s.int.gif")')
    intensity_filename_format = filepath(intensity_basename_format, $
                                         root=l1_dirname)
  endif else begin
    intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                       format='(%"%s.int.ext%%02d.gif")')
    intensity_filename_format = mg_format(filepath(intensity_basename_format, $
                                                   root=l1_dirname))
  endelse

  display_min   = run->line(file.wave_region, 'intensity_display_min')
  display_max   = run->line(file.wave_region, 'intensity_display_max')
  display_gamma = run->line(file.wave_region, 'intensity_display_gamma')
  display_power = run->line(file.wave_region, 'intensity_display_power')

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  date_stamp = ucomp_dt2stamp(datetime)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[nx, ny]

  n_colors = 252
  ucomp_loadct, 'intensity', n_colors=n_colors
  gamma_ct, display_gamma, /current

  text_color = 252
  tvlct, 255, 255, 255, text_color
  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 0, 0, inflection_color

  tvlct, r, g, b, /get

  charsize = 1.2

  wavelengths = file.wavelengths
  for e = 1L, file.n_extensions do begin
    if (center_wavelength_only) then begin
      diff = wavelengths[e - 1L] - run->line(file.wave_region, 'center_wavelength')
      if (abs(diff) gt 0.01) then continue
    endif

    if (file.n_extensions gt 1L) then begin
      im = reform(data[*, *, 0, e - 1L])
    endif else begin
      im = reform(data[*, *, 0])
    endelse

    dims = size(im, /dimensions)

    field_mask = ucomp_field_mask(dims[0], $
                                  dims[1], $
                                  run->epoch('field_radius'))

    scaled_im = bytscl((im * field_mask)^display_power, $
                       min=display_min, $
                       max=display_max, $
                       top=n_colors - 1L, $
                       /nan)

    tv, scaled_im

    xyouts, 15, dims[1] - 2.0 * 15.0, /device, $
            string(run->line(file.wave_region, 'ionization'), $
                   file.wave_region, $
                   format='(%"%s %s nm")'), $
            charsize=charsize, color=text_color
    xyouts, 15, 15, /device, alignment=0.0, $
            string(date_stamp, e, format='(%"%s ext: %d")'), $
            charsize=charsize, color=text_color
    xyouts, nx - 15, 15, /device, alignment=1.0, $
            string(display_min, display_max, display_gamma, display_power, $
                   format='(%"min/max: %0.2f/%0.1f, gamma: %0.1f, exp: %0.2f")'), $
            charsize=charsize, color=text_color

    if (keyword_set(occulter_annotation)) then begin
      ; TODO: draw occulter on GIF image, use center of image and the mean
      ; of the two geometry radii
    endif

    if (center_wavelength_only) then begin
      intensity_filename = intensity_filename_format
    endif else begin
      intensity_filename = string(e, format=intensity_filename_format)
    endelse
    write_gif, intensity_filename, tvrd(), r, g, b
  endfor

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


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

ucomp_write_intensity_image, file, data, run=run

obj_destroy, file
obj_destroy, run

end
