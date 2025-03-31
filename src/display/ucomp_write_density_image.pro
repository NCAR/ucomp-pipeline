; docformat = 'rst'

pro ucomp_write_density_image, basename, thumbnail=thumbnail, run=run
  compile_opt strictarr

  l3_dirname = filepath('', $
                        subdir=[run.date, 'level3'], $
                        root=run->config('processing/basedir'))

  gif_basename = file_basename(basename, '.fts') + '.gif'
  gif_filename = filepath(gif_basename, root=l3_dirname)

  fits_open, filepath(basename, root=l3_dirname), fcb
  fits_read, fcb, density, primary_header, exten_no=0
  fits_close, fcb

  datetimes = strmid(basename, 0, 22)

  date_stamp = ucomp_dt2stamp(strmid(datetimes, 0, 15))
  date_stamp += string(ucomp_decompose_time(strmid(datetimes, 16, 6)), $
                       format=' and %02d:%02d:%02dZ')

  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  ; TODO: look these up in a config file
  display_min = 6.5
  display_max = 8.5
  display_gamma = 1.0

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[nx, ny]

  n_colors = 252
  ucomp_loadct, 'density', n_colors=n_colors
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

  scaled_im = bytscl(alog10(density), $
                     min=display_min, $
                     max=display_max, $
                     top=n_colors - 1L, $
                     /nan)
  tv, scaled_im

  desnity_description = 'Electron Density [cm!E-3!N]'
  title = 'Density'

  xyouts, 0.5, 0.71, /normal, alignment=0.5, $
          'MLSO UCoMP', $
          charsize=mlso_charsize, color=text_color
  xyouts, 0.5, 0.67, /normal, alignment=0.5, $
          desnity_description, $
          charsize=ionization_charsize, color=text_color
  xyouts, 0.5, 0.605, /normal, alignment=0.5, $
          date_stamp, $
          charsize=date_charsize, color=text_color

  xyouts, 0.5, 0.54, /normal, alignment=0.5, $
          string(title, format='log(%s)'), $
          charsize=title_charsize, color=text_color
  colorbar2, position=[0.35, 0.5, 0.65, 0.52], $
             charsize=detail_charsize, $
             color=text_color, $
             ncolors=n_colors, $
             range=[display_min, display_max], $
             divisions=n_divisions, $
             format='(F0.1)'
  scaling_text = string(display_min, $
                        display_max, $
                        format='min/max: %0.3g - %0.2g')
  if (display_gamma ne 1.0) then begin
    scaling_text += string(display_gamma, format=', gamma: %0.2g')
  endif
  xyouts, 0.5, 0.45, /normal, alignment=0.5, $
          scaling_text, $
          charsize=detail_charsize, color=text_color

  write_gif, gif_filename, tvrd(), r, g, b
  mg_log, 'wrote %s', gif_basename, name=run.logger_name, /debug

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
