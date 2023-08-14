; docformat = 'rst'

;+
; Create an annotated display of an image.
;
; :Returns:
;   `bytarr(3, reduced_nx, reduced_ny)`
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, e.g., '1074'
;   im : in, required, type="fltarr(nx, ny"
;     input image of the type specified by `TYPE`
;
; :Keywords:
;   type : in, required, type=string
;     type of input image given in `im`, e.g., "intensity", "qu", etc.
;   name : in, optional, type=string
;     if present, use as a title annotation on the displayed image
;   reduce_factor : in, optional, type=integer, default=1
;     factor to reduce the height and width of the input image dimensions by
;   datetime : in, optional, type=string
;     if present, date/time is placed on the image; can be of the form
;     "YYYYMMDD" or "YYYYMMDD.HHMMSS"
;   no_wave_region_annotation : in, optional, type=boolean
;     set to not annotate the displayed image with the wave region information
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_display_image, wave_region, im, $
                              type=type, $
                              name=name, $
                              reduce_factor=reduce_factor, $
                              datetime=datetime, $
                              no_wave_region_annotation=no_wave_region_annotation, $
                              run=run
  compile_opt strictarr

  display_im = !null

  dims = size(im, /dimensions)
  _reduce_factor = mg_default(reduce_factor, 1L)
  dims /= _reduce_factor

  _im = rebin(im, dims[0], dims[1])

  n_colors = 251

  case 1 of
    type eq 'intensity': begin
        colortable_name = 'intensity'
        display_min   = run->line(wave_region, 'intensity_display_min')
        display_max   = run->line(wave_region, 'intensity_display_max')
        display_gamma = run->line(wave_region, 'intensity_display_gamma')
        display_power = run->line(wave_region, 'intensity_display_power')
    end
    type eq 'enhanced_intensity': begin
        colortable_name = 'enhanced_intensity'
        display_min   = run->line(wave_region, 'enhanced_intensity_display_min')
        display_max   = run->line(wave_region, 'enhanced_intensity_display_max')
        display_gamma = run->line(wave_region, 'enhanced_intensity_display_gamma')
        display_power = run->line(wave_region, 'enhanced_intensity_display_power')
    end
    type eq 'qu': begin
        colortable_name = 'quv'
        display_min   = run->line(wave_region, 'qu_display_min')
        display_max   = run->line(wave_region, 'qu_display_max')
        display_gamma = run->line(wave_region, 'qu_display_gamma')
        display_power = run->line(wave_region, 'qu_display_power')
    end
    type eq 'v': begin
        colortable_name = 'quv'
        display_min   = run->line(wave_region, 'v_display_min')
        display_max   = run->line(wave_region, 'v_display_max')
        display_gamma = run->line(wave_region, 'v_display_gamma')
        display_power = run->line(wave_region, 'v_display_power')
    end
    type eq 'quv_i': begin
        colortable_name = 'quv'
        display_min   = run->line(wave_region, 'quv_i_display_min')
        display_max   = run->line(wave_region, 'quv_i_display_max')
        display_gamma = run->line(wave_region, 'quv_i_display_gamma')
        display_power = run->line(wave_region, 'quv_i_display_power')
    end
    type eq 'linpol': begin
        colortable_name = 'linpol'
        _im = alog10(_im)
        display_min   = run->line(wave_region, 'linpol_display_min')
        display_max   = run->line(wave_region, 'linpol_display_max')
        display_gamma = run->line(wave_region, 'linpol_display_gamma')
        display_power = run->line(wave_region, 'linpol_display_power')
    end
    type eq 'azimuth': begin
        colortable_name = 'azimuth'
        display_min   = run->line(wave_region, 'azimuth_display_min')
        display_max   = run->line(wave_region, 'azimuth_display_max')
        display_gamma = run->line(wave_region, 'azimuth_display_gamma')
        display_power = run->line(wave_region, 'azimuth_display_power')
    end
    type eq 'radial_azimuth': begin
        colortable_name = 'radial_azimuth'
        display_min   = run->line(wave_region, 'radial_azimuth_display_min')
        display_max   = run->line(wave_region, 'radial_azimuth_display_max')
        display_gamma = run->line(wave_region, 'radial_azimuth_display_gamma')
        display_power = run->line(wave_region, 'radial_azimuth_display_power')
    end
    type eq 'doppler': begin
        colortable_name = 'doppler'
        display_min   = run->line(wave_region, 'doppler_display_min')
        display_max   = run->line(wave_region, 'doppler_display_max')
        display_gamma = run->line(wave_region, 'doppler_display_gamma')
        display_power = run->line(wave_region, 'doppler_display_power')
    end
    type eq 'line_width': begin
        colortable_name = 'line_width'
        display_min   = run->line(wave_region, 'line_width_display_min')
        display_max   = run->line(wave_region, 'line_width_display_max')
        display_gamma = run->line(wave_region, 'line_width_display_gamma')
        display_power = run->line(wave_region, 'line_width_display_power')
    end
  endcase

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=24, $
          set_resolution=dims

  ucomp_loadct, colortable_name, n_colors=n_colors
  mg_gamma_ct, display_gamma, /current, n_colors=n_colors

  background_color = 251
  tvlct, 0, 0, 0, background_color
  text_color = 252
  tvlct, 255, 255, 255, text_color
  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 128, 128, inflection_color

  tvlct, r, g, b, /get

  nan_indices = where(finite(_im) eq 0, n_nan)

  case _reduce_factor of
    1: begin
        mlso_charsize = 1.3
        charsize = 1.6
        title_charsize = 2.5
        date_charsize = 1.75
        detail_charsize = 1.25
        n_divisions = 4L
        small = 0B
        mlso_height = 0.70
        ionization_height = 0.67
        date_height = 0.62
        title_height = 0.54
        display_params_height = 0.45
      end
    2: begin
        mlso_charsize = 0.9
        charsize = 0.9
        title_charsize = 1.65
        date_charsize = 1.0
        detail_charsize = 1.0
        n_divisions = 2L
        small = 0B
        mlso_height = 0.71
        ionization_height = 0.675
        date_height = 0.62
        title_height = 0.54
        display_params_height = 0.42
      end
    else: begin
        mlso_charsize = 0.75
        charsize = 0.85
        title_charsize = 1.05
        date_charsize = 0.85
        detail_charsize = 0.85
        n_divisions = 2L
        small = 1B
        mlso_height = 0.71
        ionization_height = 0.65
        date_height = 0.35
        title_height = 0.55
        display_params_height = 0.40
      end
  end

  scaled_im = bytscl(mg_signed_power(_im, display_power), $
                     min=mg_signed_power(display_min, display_power), $
                     max=mg_signed_power(display_max, display_power), $
                     top=n_colors - 1L, $
                     /nan)

  if (n_nan gt 0L) then scaled_im[nan_indices] = background_color

  tv, scaled_im

  if (~keyword_set(no_wave_region_annotation)) then begin
    xyouts, 0.5, mlso_height, /normal, alignment=0.5, $
            'MLSO UCoMP', $
            charsize=mlso_charsize, color=text_color
    xyouts, 0.5, ionization_height, /normal, alignment=0.5, $
            string(run->line(wave_region, 'ionization'), $
                   wave_region, $
                   format='%s %s nm'), $
            charsize=charsize, color=text_color
  endif

  if (n_elements(datetime) gt 0L) then begin
    case strlen(datetime) of
      8: date_stamp = strjoin(ucomp_decompose_date(datetime), '-')
      15: date_stamp = ucomp_dt2stamp(datetime)
      else: date_stamp = datetime
    endcase
    xyouts, 0.5, date_height, /normal, alignment=0.5, $
            string(date_stamp, format='(%"%s")'), $
            charsize=date_charsize, color=text_color
  endif

  if (n_elements(name) gt 0L) then begin
    xyouts, 0.5, title_height, /normal, alignment=0.5, $
            display_power eq 1.0 $
              ? string(name, format='%s') $
              : string(name, display_power, format='(%"%s!E%0.2f!N")'), $
            charsize=title_charsize, color=text_color
  endif
  colorbar2, position=[0.35, 0.5, 0.65, 0.52], $
             charsize=detail_charsize, $
             color=text_color, $
             ncolors=n_colors, $
             range=mg_signed_power([display_min, display_max], display_power), $
             divisions=n_divisions, $
             format='(F0.1)'
  if (~keyword_set(small)) then begin
    xyouts, 0.5, display_params_height, /normal, alignment=0.5, $
            ucomp_display_image_params(display_min, $
                                       display_max, $
                                       display_power, $
                                       display_gamma), $
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
