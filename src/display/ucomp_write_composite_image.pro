; docformat = 'rst'


;+
; Scale one channel of a composite image from the intensity in the given level
; 1 or mean/median file and return as an array.
;
; :Returns:
;   scaled image as `bytarr(nx, ny)`
;
; :Params:
;   filename : in, required, type=string
;     filename of level 1 or mean/median file
;
; :Keywords:
;   wave_region : in, required, type=string
;     wave_region, e.g., "1074"
;   radius : out, optional, type=float
;     set to a named variable to retrieve the occulter radius
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_write_composite_image_channel, filename, $
                                              wave_region=wave_region, $
                                              run=run
  compile_opt strictarr

  fits_open, filename, fcb
  n_extensions = fcb.nextend
  n_wavelengths = n_extensions / 2L
  fits_read, fcb, !null, primary_header, exten_no=0
  fits_read, fcb, data, header, exten_no=n_wavelengths / 2 + 1
  fits_close, fcb

  wave_region = ucomp_getpar(primary_header, 'FILTER')
  occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
  post_angle = ucomp_getpar(primary_header, 'POST_ANG')
  p_angle = ucomp_getpar(primary_header, 'SOLAR_P0')

  dims = size(data, /dimensions)
  intensity = reform(data[*, *, 0])
  enhanced = run->line(wave_region, 'temperature_enhancement')
  if (keyword_set(enhanced)) then begin
    intensity = ucomp_enhanced_intensity(intensity, $
                                         radius=run->line(wave_region, 'enhanced_intensity_radius'), $
                                         amount=run->line(wave_region, 'enhanced_intensity_amount'), $
                                         occulter_radius=occulter_radius, $
                                         post_angle=post_angle, $
                                         field_radius=run->epoch('field_radius'), $
                                         /mask)
  endif

  prefix = keyword_set(enhanced) ? 'enhanced_' : ''
  display_min   = run->line(wave_region, prefix + 'intensity_display_min')
  display_max   = run->line(wave_region, prefix + 'intensity_display_max')
  display_gamma = run->line(wave_region, prefix + 'intensity_display_gamma')
  display_power = run->line(wave_region, prefix + 'intensity_display_power')

  field_mask = ucomp_field_mask(dims[0:1], run->epoch('field_radius'))
  scaled_intensity = bytscl((intensity * field_mask)^display_power, $
                            min=display_min^display_power, $
                            max=display_max^display_power, $
                            /nan)

  ; apply gamma
  gamma_indices = byte(256.0 * (findgen(256)/256.0)^display_gamma)
  scaled_intensity = gamma_indices[scaled_intensity]

  mask = ucomp_mask(dims[0:1], $
                    occulter_radius=occulter_radius, $
                    post_angle=post_angle, $
                    p_angle=p_angle)
  scaled_intensity *= mask

  return, scaled_intensity
end


;+
; Annotate a given display image.
;
; :Returns:
;   display image as `bytarr(3, nx, ny)` array
;
; :Params:
;   im : in, required, type='bytarr(3, nx, ny)'
;     input composite image
;
; :Keywords:
;   wave_regions : in, required, type=strarr(3)
;     array of wave regions corresponding to the channels of the input
;     composite image
;   radii : in, required, type=fltarr(3)
;     radii of the 3 channels of the input image used to scale the size of the
;     channels to match
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_write_composite_image_annotation, im, $
                                                 wave_regions=wave_regions, $
                                                 run=run
  compile_opt strictarr

  dims = size(im, /dimensions)
  nx = dims[1]
  ny = dims[2]

  plate_scales = fltarr(n_elements(wave_regions))
  for w = 0L, n_elements(wave_regions) - 1L do begin
    plate_scales[w] = run->line(wave_regions[w], 'plate_scale')
  endfor

  min_plate_scale = min(plate_scales)
  for w = 0L, n_elements(wave_regions) - 1L do begin
    im[w, *, *] = rot(reform(im[w, *, *]), $
                      0.0, $
                      plate_scales[w] / min_plate_scale, $
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
  charsize = 1.3
  title_charsize = 1.75
  detail_charsize = 1.2
  line_height = 16 * charsize
  text_color = 'ffffff'x

  mlso_height = 0.62
  date_height = 0.59
  title_height = 0.54

  xyouts, 0.5, mlso_height, /normal, alignment=0.5, $
          'MLSO UCoMP', $
          charsize=charsize, color=text_color
  xyouts, 0.5, date_height, /normal, alignment=0.5, $
          string(ucomp_decompose_date(run.date), $
                 format='%s-%s-%s'), $
          charsize=charsize, color=text_color
  xyouts, 0.5, title_height, /normal, alignment=0.5, $
          'Daily Temperature Image', $
          charsize=title_charsize, color=text_color

  rgb = ['Red', 'Green', 'Blue']
  legend = strarr(n_elements(wave_regions) + 1L)
  for w = 0L, n_elements(wave_regions) - 1L do begin
    log_temperature_range = run->line(wave_regions[w], 'log_temperature_range')
    ionization = run->line(wave_regions[w], 'ionization')

    legend[w] = string(rgb[w], wave_regions[w], ionization, log_temperature_range, $
                       format='%s: %s nm %s, log(Teff) = %0.2f-%0.2f')
  endfor
  legend[-1] = 'Teff=effective temperature'

  for i = 0L, n_elements(legend) - 1L do begin
    xyouts, x_margin, $
            y_margin + (n_elements(legend) - i - 1L) * line_height, $
            /device, $
            legend[i], $
            charsize=detail_charsize, color=text_color
  endfor

  note_height = 0.4 * ny
  if (wave_regions[0] eq '1074') then begin
    xyouts, nx / 2, note_height, /device, $
            alignment=0.5, $
            'Corona coolest in regions colored blue', $
            charsize=detail_charsize, color=text_color
  endif else begin
    xyouts, nx / 2, note_height, /device, $
            alignment=0.5, $
            'Corona hottest in regions colored white or red', $
            charsize=detail_charsize, color=text_color
    xyouts, nx / 2, note_height - line_height, /device, $
            alignment=0.5, $
            'Corona coolest in regions colored blue', $
            charsize=detail_charsize, color=text_color
  endelse

  annotated_image = tvrd(true=1)

  done:
  device, decomposed=original_decomposed
  set_plot, original_device

  return, annotated_image
end


;+
; Write a composite image given 3 level 1 or mean/median filenames.
;
; :Params:
;   filenames : in, required, type=strarr(3)
;     three level 1 filenames
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_composite_image, filenames, run=run
  compile_opt strictarr

  channels = ['R', 'G', 'B']
  files_exist = file_test(filenames, /regular)
  if (total(files_exist, /integer) ne n_elements(filenames)) then begin
    missing_indices = where(files_exist eq 0, /null)
    mg_log, 'missing %s channel%s for composite image', $
            strjoin(strtrim(channels[missing_indices], 2)), $
            n_elements(missing_indices) gt 2 ? 's' : '', $
            name=run.logger_name, /warn
    for m = 0L, n_elements(missing_indices) - 1L do begin
      mg_log, '%s: %s', $
              channels[missing_indices[m]], $
              file_basename(filenames[missing_indices[m]]), $
              name=run.logger_name, /warn
    endfor
    goto, done
  endif

  wave_regions = strarr(3)
  radii = fltarr(3)

  red = ucomp_write_composite_image_channel(filenames[0], $
                                            wave_region=wave_region, $
                                            run=run)
  wave_regions[0] = wave_region

  green = ucomp_write_composite_image_channel(filenames[1], $
                                              wave_region=wave_region, $
                                              run=run)
  wave_regions[1] = wave_region

  blue = ucomp_write_composite_image_channel(filenames[2], $
                                             wave_region=wave_region, $
                                             run=run)
  wave_regions[2] = wave_region

  dims = size(red, /dimensions)
  im = bytarr(3, dims[0], dims[1])
  im[0, *, *] = red
  im[1, *, *] = green
  im[2, *, *] = blue

  annotated_image = ucomp_write_composite_image_annotation(im, $
                                                           wave_regions=wave_regions, $
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

;date = '20211003'
date = '20220901'

config_basename = 'ucomp.publish.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

enhanced = 0B
nrgf = 0B

wave_regions = ['1074', '789', '637']
mean_basenames = date + '.ucomp.' + wave_regions + '.l2.synoptic.mean.fts'
mean_filenames = filepath(mean_basenames, $
                          subdir=[date, 'level2'], $
                          root=run->config('processing/basedir'))
ucomp_write_composite_image, mean_filenames, run=run

wave_regions = ['706', '1074', '789']
mean_basenames = date + '.ucomp.' + wave_regions + '.l2.synoptic.mean.fts'
mean_filenames = filepath(mean_basenames, $
                          subdir=[date, 'level2'], $
                          root=run->config('processing/basedir'))
ucomp_write_composite_image, mean_filenames, run=run

obj_destroy, run

end
