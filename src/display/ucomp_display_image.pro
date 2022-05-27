; docformat = 'rst'

function ucomp_display_image, file, im, $
                              type=type, $
                              name=name, $
                              reduce_factor=reduce_factor, $
                              run=run
  compile_opt strictarr

  display_im = !null

  dims = size(im, /dimensions)
  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor

  _im = rebin(im, dims[0], dims[1])

  case 1 of
    type eq 'intensity': begin
        colortable_name = 'intensity'
        display_min   = run->line(file.wave_region, 'intensity_display_min')
        display_max   = run->line(file.wave_region, 'intensity_display_max')
        display_gamma = run->line(file.wave_region, 'intensity_display_gamma')
        display_power = run->line(file.wave_region, 'intensity_display_power')
    end
    type eq 'quv': begin
        colortable_name = 'quv'
        display_min   = run->line(file.wave_region, 'quv_display_min')
        display_max   = run->line(file.wave_region, 'quv_display_max')
        display_gamma = run->line(file.wave_region, 'quv_display_gamma')
        display_power = run->line(file.wave_region, 'quv_display_power')
    end
    type eq 'linpol': begin
        colortable_name = 'linpol'
        display_min   = run->line(file.wave_region, 'linpol_display_min')
        display_max   = run->line(file.wave_region, 'linpol_display_max')
        display_gamma = run->line(file.wave_region, 'linpol_display_gamma')
        display_power = run->line(file.wave_region, 'linpol_display_power')
    end
    type eq 'azimuth': begin
        colortable_name = 'azimuth'
        display_min   = run->line(file.wave_region, 'azimuth_display_min')
        display_max   = run->line(file.wave_region, 'azimuth_display_max')
        display_gamma = run->line(file.wave_region, 'azimuth_display_gamma')
        display_power = run->line(file.wave_region, 'azimuth_display_power')
    end
    type eq 'doppler': begin
        colortable_name = 'doppler'
        display_min   = run->line(file.wave_region, 'doppler_display_min')
        display_max   = run->line(file.wave_region, 'doppler_display_max')
        display_gamma = run->line(file.wave_region, 'doppler_display_gamma')
        display_power = run->line(file.wave_region, 'doppler_display_power')
    end
    type eq 'line_width': begin
        colortable_name = 'line_width'
        display_min   = run->line(file.wave_region, 'line_width_display_min')
        display_max   = run->line(file.wave_region, 'line_width_display_max')
        display_gamma = run->line(file.wave_region, 'line_width_display_gamma')
        display_power = run->line(file.wave_region, 'line_width_display_power')
    end
  endcase

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  date_stamp = ucomp_dt2stamp(datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=24, $
          set_resolution=dims

  n_colors = 252
  ucomp_loadct, colortable_name, n_colors=n_colors
  gamma_ct, display_gamma, /current
  
  text_color = 252
  tvlct, 255, 255, 255, text_color
  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 128, 128, inflection_color

  tvlct, r, g, b, /get

  if (n_elements(reduce_factor) gt 0L && reduce_factor ge 4L) then begin
    charsize = 0.9
    detail_charsize = 0.9
    small = 1B
    line_height = 11
  endif else begin
    charsize = 1.2
    detail_charsize = 1.0
    small = 0B
    line_height = 15
  endelse

  scaled_im = bytscl(_im^display_power, $
                     min=display_min, $
                     max=display_max, $
                     top=n_colors - 1L, $
                     /nan)

  tv, scaled_im

  xyouts, 15, dims[1] - 2.0 * line_height, /device, $
          string(run->line(file.wave_region, 'ionization'), $
                 file.wave_region, $
                 format='(%"MLSO UCoMP %s %s nm")'), $
          charsize=charsize, color=text_color
  xyouts, 15, line_height, /device, alignment=0.0, $
          string(date_stamp, format='(%"%s")'), $
          charsize=detail_charsize, color=text_color
  if (n_elements(name) gt 0L) then begin
    xyouts, dims[0] - 15, dims[1] - 2.0 * line_height, /device, alignment=1.0, $
            name, $
            charsize=charsize, color=text_color
  endif
  if (~keyword_set(small)) then begin
    xyouts, dims[0] - 15, line_height, /device, alignment=1.0, $
            string(display_min, display_max, display_gamma, display_power, $
                   format='(%"min/max: %0.2f/%0.1f, gamma: %0.1f, exp: %0.2f")'), $
            charsize=detail_charsize, color=text_color
  endif

  display_im = tvrd(true=1)

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device

  return, display_im
end
