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
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_intensity_image, file, data, primary_header, $
                                 enhanced=enhanced, run=run
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
    intensity_basename_format += '.enhanced-int'
  endif else begin
    intensity_basename_format += '.int'
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

  title_charsize = 1.75
  type_charsize = 1.75
  charsize = 1.2
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
                                    !null, $
                                    !null, $
                                    primary_header, $
                                    run->epoch('field_radius'), $
                                    radius=run->line(file.wave_region, 'enhanced_intensity_radius'), $
                                    amount=run->line(file.wave_region, 'enhanced_intensity_amount'), $
                                    mask=run->config('display/mask_l1'))
    endif

    dims = size(im, /dimensions)
    if (run->config('display/mask_l1')) then begin
      rcam = file.rcam_geometry
      tcam = file.tcam_geometry
      mask = ucomp_mask(dims[0:1], $
                        field_radius=run->epoch('field_radius'), $
                        occulter_radius=file.occulter_radius, $
                        post_angle=(rcam.post_angle + tcam.post_angle) / 2.0, $
                        p_angle=file.p_angle)
    endif else begin
      mask = bytarr(dims[0], dims[1]) + 1B
    endelse

    scaled_im = bytscl((im * mask)^display_power, $
                       min=display_min^display_power, $
                       max=display_max^display_power, $
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
      xyouts, 0.5, 0.62, /normal, alignment=0.5, $
              string(run->line(file.wave_region, 'ionization'), $
                     file.wave_region, $
                     format='(%"MLSO UCoMP %s %s nm")'), $
              charsize=title_charsize, color=text_color
      xyouts, 0.5, 0.59, /normal, alignment=0.5, $
              string(date_stamp, wavelengths[e - 1], format='(%"%s %0.2f nm")'), $
              charsize=charsize, color=text_color

      xyouts, 0.5, 0.54, /normal, alignment=0.5, $
              string(title, display_power, format='(%"%s!E%0.2f!N")'), $
              charsize=type_charsize, color=text_color
      colorbar2, position=[0.35, 0.5, 0.65, 0.52], $
                 charsize=detail_charsize, $
                 color=text_color, $
                 ncolors=n_colors, $
                 range=[display_min, display_max]^display_power, $
                 divisions=n_divisions, $
                 format='(F0.1)'
      xyouts, 0.5, 0.45, /normal, alignment=0.5, $
              string(display_min, display_power, $
                     display_max, display_power, $
                     display_gamma, $
                     format='(%"min/max: %0.2f!E%0.2f!N - %0.1f!E%0.2f!N, gamma: %0.1f")'), $
              charsize=detail_charsize, color=text_color
    endelse

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


date = '20220901'

config_basename = 'ucomp.bilinear.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20220901.190352.15.ucomp.1079.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

l1_basename = '20220901.190352.ucomp.1079.l1.3.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, $
                    primary_header=primary_header, $
                    ext_data=data, $
                    n_wavelengths=n_wavelengths
file.n_extensions = n_wavelengths

ucomp_write_intensity_image, file, data, primary_header, /enhanced, run=run

obj_destroy, file
obj_destroy, run

end
