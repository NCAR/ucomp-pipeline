; docformat = 'rst'

;+
; Write the annotated background GIF for an L1 file. The centering is found
; using an averaged, smoothed background image.
;
; :Params:
;   bkg : in, required, type="fltarr(nx, ny)"
;     averaged, smoothed background image used to find the center for the image
;   geometry: in, required, type=object
;     `ucomp_geometry` object
;   wave_region : in, required, type=string
;     wave region for the file
;   output_filename : in, required, type=string
;     full path for output file
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_bkg_annotation, bkg, geometry, wave_region, output_filename, run=run
  compile_opt strictarr

  display_min   = run->line(wave_region, 'background_display_min')
  display_max   = run->line(wave_region, 'background_display_max')
  display_gamma = run->line(wave_region, 'background_display_gamma')
  display_power = run->line(wave_region, 'background_display_power')

  nx = run->epoch('nx')
  ny = run->epoch('ny')

  ; initiate Z-buffer
  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[nx, ny]

  n_colors = 252
  ucomp_loadct, 'background', n_colors=n_colors
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

  ; display continuum image used to determine center
  scaled_bkg = bytscl(mg_signed_power(bkg, display_power), $
                      min=mg_signed_power(display_min, display_power), $
                      max=mg_signed_power(display_max, display_power), $
                      top=n_colors - 1L, $
                      /nan)

  tv, scaled_bkg

  ; annotate with centering
  geometry->display, 0, $
                     occulter_color=occulter_color, $
                     guess_color=guess_color, $
                     inflection_color=inflection_color, $
                     /no_rotate
  annotated_im = tvrd()
  write_gif, output_filename, annotated_im, r, g, b

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
