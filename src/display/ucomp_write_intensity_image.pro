; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;   primary_header : in, required, type=strarr
;     primary header
;
; :Keywords:
;   enhanced : in, optional, type=boolean
;     set to produce an enhanced intensity image
;   grid : in, optional, type=boolean
;     set to display a grid on the image
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_intensity_image, file, data, primary_header, $
                                 enhanced=enhanced, grid=grid, $
                                 run=run
  compile_opt strictarr

  occulter_annotation = run->config('centering/annotated_gifs')
  center_wavelength_only = run->config('intensity/center_wavelength_gifs_only')

  if (keyword_set(enhanced)) then begin
    option_prefix = 'enhanced_'
    title = 'Enhanced intensity'
  endif else begin
    option_prefix = ''
    title = 'Intensity'
  endelse

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  intensity_basename_format = file_basename(file.l1_basename, '.fts')
  if (keyword_set(enhanced)) then begin
    intensity_basename_format += '.enhanced_intensity'
  endif else begin
    intensity_basename_format += '.intensity'
  endelse
  if (~center_wavelength_only) then intensity_basename_format += '.ext%02d'
  intensity_basename_format += '.gif'
  intensity_filename_format = filepath(intensity_basename_format, root=l1_dirname)

  display_min   = run->line(file.wave_region, option_prefix + 'intensity_display_min')
  display_max   = run->line(file.wave_region, option_prefix + 'intensity_display_max')
  display_gamma = run->line(file.wave_region, option_prefix + 'intensity_display_gamma')
  display_power = run->line(file.wave_region, option_prefix + 'intensity_display_power')

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
  ucomp_loadct, option_prefix + 'intensity', n_colors=n_colors
  mg_gamma_ct, display_gamma, /current, n_colors=n_colors

  text_color = 252
  tvlct, 255, 255, 255, text_color
  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 128, 128, inflection_color

  tvlct, r, g, b, /get

  mlso_charsize = 1.25
  ionization_charsize = 1.75
  title_charsize = 2.5
  date_charsize = 1.9
  detail_charsize = 1.25

  n_divisions = 4L

  wavelengths = file.wavelengths
  for e = 1L, file.n_extensions do begin
    if (center_wavelength_only) then begin
      diff = wavelengths[e - 1L] - run->line(file.wave_region, 'center_wavelength')
      if (abs(diff) gt 0.01) then continue
    endif

    im = reform(data[*, *, 0, e - 1L])

    if (keyword_set(enhanced)) then begin
      im = ucomp_enhanced_intensity(im, $
                                    radius=run->line(file.wave_region, 'enhanced_intensity_radius'), $
                                    amount=run->line(file.wave_region, 'enhanced_intensity_amount'), $
                                    occulter_radius=file.occulter_radius, $
                                    post_angle=file.post_angle, $
                                    field_radius=run->epoch('field_radius'), $
                                    mask=run->config('display/mask_l1'))
    endif

    dims = size(im, /dimensions)
    if (run->config('display/mask_l1') || run->line(file.wave_region, 'mask_l1')) then begin
      mask = ucomp_mask(dims[0:1], $
                        field_radius=run->epoch('field_radius'), $
                        occulter_radius=file.occulter_radius, $
                        post_angle=file.post_angle, $
                        p_angle=file.p_angle)
    endif else if (run->line(file.wave_region, 'mask_l1_occulter')) then begin
      mask = ucomp_mask(dims[0:1], $
                        field_radius=run->epoch('field_radius'), $
                        occulter_radius=file.occulter_radius, $
                        p_angle=file.p_angle)
    endif else begin
      mask = bytarr(dims[0], dims[1]) + 1B
    endelse

    scaled_im = bytscl(mg_signed_power(im * mask, display_power), $
                       min=mg_signed_power(display_min, display_power), $
                       max=mg_signed_power(display_max, display_power), $
                       top=n_colors - 1L, $
                       /nan)

    tv, scaled_im

    if (keyword_set(occulter_annotation) and ~keyword_set(enhanced)) then begin
        file.rcam_geometry->display, 0, $
                                     occulter_color=occulter_color, $
                                     guess_color=guess_color, $
                                     inflection_color=inflection_color, $
                                     /final_only
        file.tcam_geometry->display, 1, $
                                     occulter_color=occulter_color, $
                                     guess_color=guess_color, $
                                     inflection_color=inflection_color, $
                                     /final_only
        line_height = 14.0
        xyouts, dims[0] - 5.0, dims[1] - line_height, /device, alignment=1.0, $
                'occulter initial guesses', charsize=detail_charsize, color=guess_color
        xyouts, dims[0] - 5.0, dims[1] - 2.0 * line_height, /device, alignment=1.0, $
                'fitted occulter', charsize=detail_charsize, color=occulter_color
        xyouts, dims[0] - 5.0, dims[1] - 3.0 * line_height, /device, alignment=1.0, $
                'inflection points', charsize=detail_charsize, color=inflection_color
    endif else begin
      xyouts, 0.5, 0.71, /normal, alignment=0.5, $
              'MLSO UCoMP', $
              charsize=mlso_charsize, color=text_color
      xyouts, 0.5, 0.67, /normal, alignment=0.5, $
              string(run->line(file.wave_region, 'ionization'), $
                     wavelengths[e - 1], $
                     format='%s %0.3f nm'), $
              charsize=ionization_charsize, color=text_color
      xyouts, 0.5, 0.605, /normal, alignment=0.5, $
              date_stamp, $
              charsize=date_charsize, color=text_color

      xyouts, 0.5, 0.54, /normal, alignment=0.5, $
              string(title, display_power, format='(%"%s!E%0.2f!N")'), $
              charsize=title_charsize, color=text_color
      colorbar2, position=[0.35, 0.5, 0.65, 0.52], $
                 charsize=detail_charsize, $
                 color=text_color, $
                 ncolors=n_colors, $
                 range=mg_signed_power([display_min, display_max], display_power), $
                 divisions=n_divisions, $
                 format='(F0.1)'
      scaling_text = string(display_min, display_power, $
                            display_max, display_power, $
                            format='min/max: %0.3g!E%0.3g!N - %0.2g!E%0.3g!N')
      if (display_gamma ne 1.0) then begin
        scaling_text += string(display_gamma, format=', gamma: %0.2g')
      endif
      xyouts, 0.5, 0.45, /normal, alignment=0.5, $
              scaling_text, $
              charsize=detail_charsize, color=text_color
    endelse

    if (keyword_set(grid)) then begin
      rsun = file.semidiameter / run->line(file.wave_region, 'plate_scale')
      ucomp_grid, rsun, $
                  run->epoch('field_radius'), $
                  (dims[0:1] - 1.0) / 2.0, $
                  color=text_color
    endif

    if (center_wavelength_only) then begin
      intensity_filename = intensity_filename_format
    endif else begin
      intensity_filename = string(e, format=intensity_filename_format)
    endelse

    write_gif, intensity_filename, tvrd(), r, g, b
    mg_log, 'wrote %s', file_basename(intensity_filename), $
            name=run.logger_name, /debug
  endfor

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


date = '20240409'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20240409.214658.17.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

l1_basename = '20240409.214658.ucomp.1074.l1.p5.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, $
                    primary_header=primary_header, $
                    ext_data=data, $
                    n_wavelengths=n_wavelengths
file.n_extensions = n_wavelengths

file.rcam_geometry = ucomp_geometry(occulter_radius=ucomp_getpar(primary_header, 'RADIUS0'), $
                                    post_angle=ucomp_getpar(primary_header, 'POST_ANG'))
file.tcam_geometry = ucomp_geometry(occulter_radius=ucomp_getpar(primary_header, 'RADIUS1'), $
                                    post_angle=ucomp_getpar(primary_header, 'POST_ANG'))

ucomp_write_intensity_image, file, data, primary_header, /grid, run=run

obj_destroy, file
obj_destroy, run

end
