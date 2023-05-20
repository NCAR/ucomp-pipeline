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
;   enhanced : in, optional, type=boolean
;     set to enhance the intensity image when displayed
;   nrgf : in, optional, type=boolean
;     set to use the NGRF on the intensity image when displayed
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_write_composite_image_channel, filename, $
                                              wave_region=wave_region, $
                                              radius=occulter_radius, $
                                              enhanced=enhanced, $
                                              nrgf=nrgf, $
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
  if (keyword_set(enhanced)) then begin
    intensity = ucomp_enhanced_intensity(intensity, $
                                         !null, !null, $
                                         primary_header, $
                                         radius=run->line(wave_region, 'enhanced_intensity_radius'), $
                                         amount=run->line(wave_region, 'enhanced_intensity_amount'), $
                                         /mask)
  endif

  if (keyword_set(nrgf)) then begin
    intensity = ucomp_nrgf(intensity, occulter_radius)
    display_min   = 0.0
    display_max   = 256.0
    display_gamma = 1.0
    display_power = 1.0
  endif else begin
    prefix = keyword_set(enhanced) ? 'enhanced_' : ''
    display_min   = run->line(wave_region, prefix + 'intensity_display_min')
    display_max   = run->line(wave_region, prefix + 'intensity_display_max')
    display_gamma = run->line(wave_region, prefix + 'intensity_display_gamma')  ; TODO: how to use?
    display_power = run->line(wave_region, prefix + 'intensity_display_power')
  endelse

  field_mask = ucomp_field_mask(dims[0:1], run->epoch('field_radius'))
  scaled_intensity = bytscl((intensity * field_mask)^display_power, $
                            min=display_min, $
                            max=display_max, $
                            /nan)

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
  charsize = 1.4
  line_height = 16 * charsize
  text_color = 'ffffff'x

  xyouts, x_margin, ny - y_margin - line_height, /device, $
          'MLSO UCoMP Daily Temperature Image', $
          charsize=charsize, color=text_color
  xyouts, x_margin, ny - y_margin - 2 * line_height, /device, $
          string(ucomp_decompose_date(run.date), $
                 format='%s-%s-%s'), $
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

  for i = 0L, n_elements(legend) - 1L do begin
    xyouts, x_margin, $
            y_margin + (n_elements(legend) - i - 1L) * line_height, $
            /device, $
            legend[i], $
            charsize=charsize, color=text_color
  endfor

  if (wave_regions[0] eq '1074') then begin
    xyouts, nx - x_margin, ny - y_margin - line_height, /device, $
            alignment=1.0, $
            'Corona coolest in regions colored blue', $
            charsize=charsize, color=text_color
  endif else begin
    xyouts, nx - x_margin, ny - y_margin - line_height, /device, $
            alignment=1.0, $
            'Corona hottest in regions colored white or red', $
            charsize=charsize, color=text_color
    xyouts, nx - x_margin, ny - y_margin - 2 * line_height, /device, $
            alignment=1.0, $
            'Corona coolest in regions colored blue', $
            charsize=charsize, color=text_color
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
;   enhanced : in, optional, type=boolean
;     set to produce enhanced intensity channels
;   nrgf : in, optional, type=boolean
;     set to use the NRGF on the intensity channels
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_composite_image, filenames, enhanced=enhanced, nrgf=nrgf, run=run
  compile_opt strictarr

  channels = ['R', 'G', 'B']
  files_exist = file_test(filenames, /regular)
  if (total(files_exist, /integer) ne n_elements(filenames)) then begin
    missing_indices = where(files_exist eq 0, /null)
    mg_log, 'missing %s channel%s for composite image', $
            strjoin(strtrim(channels[missing_indices], 2)), $
            n_elements(missing_indices) gt 2 ? 's' : '', $
            name=run.logger_name, /warn
    goto, done
  endif

  wave_regions = strarr(3)
  radii = fltarr(3)

  red = ucomp_write_composite_image_channel(filenames[0], $
                                            wave_region=wave_region, $
                                            radius=radius, $
                                            enhanced=enhanced, nrgf=nrgf, $
                                            run=run)
  wave_regions[0] = wave_region
  radii[0] = radius

  green = ucomp_write_composite_image_channel(filenames[1], $
                                              wave_region=wave_region, $
                                              radius=radius, $
                                              enhanced=enhanced, nrgf=nrgf, $
                                              run=run)
  wave_regions[1] = wave_region
  radii[1] = radius

  blue = ucomp_write_composite_image_channel(filenames[2], $
                                             wave_region=wave_region, $
                                             radius=radius, $
                                             enhanced=enhanced, nrgf=nrgf, $
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

date = '20220325'

config_basename = 'ucomp.regression.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

enhanced = 0B
nrgf = 0B

wave_regions = ['1074', '789', '637']
mean_basenames = date + '.ucomp.' + wave_regions + '.synoptic.mean.fts'
mean_filenames = filepath(mean_basenames, $
                          subdir=[date, 'level2'], $
                          root=run->config('processing/basedir'))
ucomp_write_composite_image, mean_filenames, enhanced=enhanced, run=run

wave_regions = ['706', '1074', '789']
mean_basenames = date + '.ucomp.' + wave_regions + '.synoptic.mean.fts'
mean_filenames = filepath(mean_basenames, $
                          subdir=[date, 'level2'], $
                          root=run->config('processing/basedir'))
ucomp_write_composite_image, mean_filenames, enhanced=enhanced, nrgf=nrgf, run=run

obj_destroy, run

end
