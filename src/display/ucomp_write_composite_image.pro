; docformat = 'rst'


function ucomp_write_composite_image_channel, filename, $
                                              wave_region=wave_region, $
                                              radius=occulter_radius, $
                                              run=run
  compile_opt strictarr

  fits_open, filename, fcb
  n_extensions = fcb.nextend
  fits_read, fcb, !null, primary_header, exten_no=0
  fits_read, fcb, data, header, exten_no=n_extensions / 2 + 1
  fits_close, fcb

  wave_region = ucomp_getpar(primary_header, 'FILTER')
  occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

  display_min   = run->line(wave_region, 'intensity_display_min')
  display_max   = run->line(wave_region, 'intensity_display_max')
  display_gamma = run->line(wave_region, 'intensity_display_gamma')  ; TODO: how to use?
  display_power = run->line(wave_region, 'intensity_display_power')

  dims = size(data, /dimensions)
  intensity = reform(data[*, *, 0])

  field_mask = ucomp_field_mask(dims[0], $
                                dims[1], $
                                run->epoch('field_radius'))
  scaled_intensity = bytscl((intensity * field_mask)^display_power, $
                            min=display_min, $
                            max=display_max, $
                            /nan)

  occulter_mask = ucomp_occulter_mask(dims[0], dims[1], occulter_radius)
  post_mask = ucomp_post_mask(dims[0], dims[1], 0.0)
  scaled_intensity *= occulter_mask * post_mask

  return, scaled_intensity
end


function ucomp_write_composite_image_annotation, im, $
                                                 wave_regions=wave_regions, $
                                                 radii=radii, $
                                                 run=run
  compile_opt strictarr

  dims = size(im, /dimensions)
  nx = dims[1]
  ny = dims[2]

  max_radius = max(radii)
  for w = 0L, n_elements(wave_regions) - 1L do begin
    im[w, *, *] = rot(reform(im[w, *, *]), 0.0, max_radius / radii[w], $
                      /interp, cubic=-0.5, missing=0.0)
  endfor

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  device, decomposed=1, $
          set_pixel_depth=24, $
          set_resolution=dims[1:2]

  tv, im, true=1

  x_margin = 12
  y_margin = 12
  line_height = 12
  charsize = 1.5
  text_color = 'ffffff'x

  xyouts, x_margin, ny - y_margin - line_height, /device, $
          string(ucomp_decompose_date(run.date), $
                 format='MLSO UCoMP Daily Temperature Image!C%s-%s-%s'), $
          charsize=charsize, color=text_color

  rgb = ['Red', 'Green', 'Blue']
  legend = strarr(n_elements(wave_regions) + 1L)
  for w = 0L, n_elements(wave_regions) - 1L do begin
    log_temperature_range = run->line(wave_regions[w], 'log_temperature_range')
    ionization = run->line(wave_regions[w], 'ionization')

    legend[w] = string(rgb[w], wave_regions[w], ionization, log_temperature_range, $
                       format='%s: %s nm %s, log(Teff) = %0.2f-%0.2f')
  endfor
  legend[-1] = 'Teff=effective temperature'

  xyouts, x_margin, $
          y_margin + (n_elements(wave_regions) + 1L) * line_height, $
          /device, $
          strjoin(legend, '!C'), $
          charsize=charsize, color=text_color

  if (wave_regions[0] eq '1074') then begin
    xyouts, nx - x_margin, ny - y_margin - line_height, /device, $
            alignment=1.0, $
            'Corona coolest in regions colored blue', $
            charsize=charsize, color=text_color
  endif else begin
    xyouts, nx - x_margin, ny - y_margin - 2 * line_height, /device, $
            alignment=1.0, $
            strjoin(['Corona hottest in regions colored white or red', $
                     'Corona coolest in regions colored blue'], '!C'), $
            charsize=charsize, color=text_color
  endelse

  annotated_image = tvrd(true=1)

  done:
  device, decomposed=original_decomposed
  set_plot, original_device

  return, annotated_image
end


pro ucomp_write_composite_image, filenames, run=run
  compile_opt strictarr

  files_exist = file_test(filenames, /regular)
  if (total(files_exist, /integer)) then begin
    mg_log, 'missing file(s) for composite image channel(s)', $
            name=run.logger_name, /warn
    goto, done
  endif

  wave_regions = strarr(3)
  radii = fltarr(3)

  red = ucomp_write_composite_image_channel(filenames[0], $
                                            wave_region=wave_region, $
                                            radius=radius, $
                                            run=run)
  wave_regions[0] = wave_region
  radii[0] = radius

  green = ucomp_write_composite_image_channel(filenames[1], $
                                              radius=radius, $
                                              wave_region=wave_region, $
                                              run=run)
  wave_regions[1] = wave_region
  radii[1] = radius

  blue = ucomp_write_composite_image_channel(filenames[2], $
                                             radius=radius, $
                                             wave_region=wave_region, $
                                             run=run)
  wave_regions[2] = wave_region
  radii[2] = radius

  dims = size(red, /dimensions)
  im = bytarr(3, dims[0], dims[1])
  im[0, *, *] = red
  im[1, *, *] = green
  im[2, *, *] = blue

  annotated_image = ucomp_write_composite_image_annotation(im, $
                                                           wave_regions=wave_regions, $
                                                           radii=radii, $
                                                           run=run)

  output_basename = string(run.date, wave_regions, $
                           format='%s.ucomp.%s-%s-%s.daily_temperature.png')
  output_filename = filepath(output_basename, $
                             subdir=[run.date, 'level2'], $
                             root=run->config('processing/basedir'))

  write_png, output_filename, annotated_image

  done:
end


; main-level example program

date = '20220901'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)


mean_basenames = ['20220901.ucomp.1074.synoptic.mean.fts', $
                  '20220901.ucomp.789.synoptic.mean.fts', $
                  '20220901.ucomp.637.synoptic.mean.fts']
; mean_basenames = ['20220901.ucomp.706.synoptic.mean.fts', $
;                   '20220901.ucomp.1074.synoptic.mean.fts', $
;                   '20220901.ucomp.789.synoptic.mean.fts']
mean_filenames = filepath(mean_basenames, $
                          subdir=[date, 'level2'], $
                          root=run->config('processing/basedir'))

ucomp_write_composite_image, mean_filenames, run=run

obj_destroy, run

end
