; docformat = 'rst'


function ucomp_write_composite_image_channel, file, data, radius, run=run
  compile_opt strictarr

  dims = size(data, /dimensions)
  center_indices = file->get_center_wavelength_indices()
  im = data[*, *, 0, center_indices[0]]

  display_min   = run->line(file.wave_region, 'intensity_display_min')
  display_max   = run->line(file.wave_region, 'intensity_display_max')
  display_gamma = run->line(file.wave_region, 'intensity_display_gamma')
  display_power = run->line(file.wave_region, 'intensity_display_power')

  if (run->config('display/mask')) then begin
    field_mask = ucomp_field_mask(dims[0], $
                                  dims[1], $
                                  run->epoch('field_radius'))
  endif else begin
    field_mask = bytarr(dims[0], dims[1]) + 1B
  endelse
  
  scaled_im = bytscl((im * field_mask)^display_power, $
                     min=display_min, $
                     max=display_max, $
                     /nan)

  if (run->config('display/mask')) then begin
    occulter_mask = ucomp_occulter_mask(dims[0], dims[1], file.occulter_radius)
    scaled_im *= occulter_mask

    ; TODO: find read post angle
    post_mask = ucomp_post_mask(dims[0], dims[1], 0.0)
    scaled_im *= post_mask
  endif

  ; TODO: scale size? i.e., stretch to normalize radius
  scaled_im = rot(scaled_im, 0.0, radius / file.occulter_radius)

  return, scaled_im
end


pro ucomp_write_composite_image, red_file, red_data, $
                                 green_file, green_data, $
                                 blue_file, blue_data, $
                                 run=run
  compile_opt strictarr

  radius = min([red_file.occulter_radius, green_file.occulter_radius, blue_file.occulter_radius])

  red = ucomp_write_composite_image_channel(red_file, red_data, radius, run=run)
  green = ucomp_write_composite_image_channel(green_file, green_data, radius, run=run)
  blue = ucomp_write_composite_image_channel(blue_file, blue_data, radius, run=run)
  im = [[[red]], [[green]], [[blue]]]

  mg_image, im, /new
 end


; main-level example program

date = '20220221'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

; red: 706, green: 1074, blue: 789
;times = date + '.' + ['230819', '231854', '231337']

; red: 1074, green: 789, blue: 637
times = date + '.' + ['231854', '231337', '230302']

files = list()
data_arrays = list()
for t = 0L, n_elements(times) - 1L do begin
  raw_filenames = file_search(filepath(times[t] + '.*.fts', $
                                       subdir=date, $
                                       root=run->config('raw/basedir')))
  file = ucomp_file(raw_filenames[0], run=run)

  l1_filenames = file_search(filepath(times[t] + '.ucomp.*.l1.*.fts', $
                                      subdir=[date, 'level1'], $
                                      root=run->config('processing/basedir')))
  ucomp_read_l1_data, l1_filenames[0], $
                      ext_data=ext_data, $
                      n_extensions=n_extensions, $
                      primary_header=primary_header
  file.n_extensions = n_extensions
  rcam_geometry = ucomp_geometry()
  rcam_geometry.occulter_radius = ucomp_getpar(primary_header, 'RADIUS0')
  tcam_geometry = ucomp_geometry()
  tcam_geometry.occulter_radius = ucomp_getpar(primary_header, 'RADIUS1')
  file.rcam_geometry = rcam_geometry
  file.tcam_geometry = tcam_geometry

  files->add, file
  data_arrays->add, ext_data
endfor

ucomp_write_composite_image, files[0], data_arrays[0], $
                             files[1], data_arrays[1], $
                             files[2], data_arrays[2], $
                             run=run

foreach f, files do obj_destroy, f
obj_destroy, files

obj_destroy, data_arrays
obj_destroy, run

end
