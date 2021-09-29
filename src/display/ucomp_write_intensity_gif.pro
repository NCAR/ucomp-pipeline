; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_intensity_gif, file, data, run=run, $
                               occulter_annotation=occulter_annotation
  compile_opt strictarr

  center_wavelength_only = run->config('intensity/center_wavelength_gifs_only')

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  if (center_wavelength_only) then begin
    intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                       format='(%"%s.int.gif")')
    intensity_filename_format = filepath(intensity_basename_format, $
                                         root=l1_dirname)
  endif else begin
    intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                       format='(%"%s.int.ext%%02d.gif")')
    intensity_filename_format = mg_format(filepath(intensity_basename_format, $
                                                   root=l1_dirname))
  endelse
  

  display_min   = run->line(file.wave_region, 'intensity_display_min')
  display_max   = run->line(file.wave_region, 'intensity_display_max')
  display_gamma = run->line(file.wave_region, 'intensity_display_gamma')
  display_power = run->line(file.wave_region, 'intensity_display_power')

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_resolution=[nx, ny]

  n_colors = 253
  loadct, 0, /silent, ncolors=n_colors
  gamma_ct, display_gamma, /current

  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 0, 0, inflection_color

  tvlct, r, g, b, /get

  wavelengths = file.wavelengths
  for e = 1L, file.n_extensions do begin
    if (center_wavelength_only) then begin
      diff = wavelengths[e - 1L] - run->line(file.wave_region, 'center_wavelength')
      if (abs(diff) gt 0.01) then continue
    endif

    if (file.n_extensions gt 1L) then begin
      im = reform(data[*, *, 0, e - 1L])
    endif else begin
      im = reform(data[*, *, 0])
    endelse

    scaled_im = bytscl(im^display_power, $
                       min=display_min, $
                       max=display_max, $
                       top=n_colors - 1L, $
                       /nan)

    tv, scaled_im
    xyouts, 15, 15, /device, alignment=0.0, $
            string(e, format='(%"ext: %d")'), $
            color=guess_color
    xyouts, nx - 15, 15, /device, alignment=1.0, $
            string(display_min, display_max, display_gamma, $
                   format='(%"min/max: %0.1f/%0.1f, gamma: %0.1f")'), $
            color=guess_color

    if (keyword_set(occulter_annotation)) then begin
      ; TODO: draw occulter on GIF image, use center of image and the mean
      ; of the two geometry radii
    endif

    if (center_wavelength_only) then begin
      intensity_filename = intensity_filename_format
    endif else begin
      intensity_filename = string(e, format=intensity_filename_format)
    endelse
    write_gif, intensity_filename, tvrd(), r, g, b
  endfor

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
