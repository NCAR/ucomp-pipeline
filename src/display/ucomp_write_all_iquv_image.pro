; docformat = 'rst'

;+
; Produce a plot of all the images in a UCoMP level 1 science file.
;
; :Params:
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;   backgrounds : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     background extension data
;   l1_basename : in, required, type=string
;     basename of corresponding level 1 file
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;   wavelengths : in, required, type=fltarr
;     wavelengths corresponding to the images in the `nexts` dimension of the
;     data
;   occulter_radius : in, required, type=float
;     radius of occulter
;   post_angle : in, required, type=float
;     angle of the post in degrees
;   p_angle : in, required, type=float
;     solar p0 angle in degrees
;
; :Keywords:
;   daily : in, optional, type=boolean
;     set to produce an iquv.all.png image for an average file
;   sigma : in, optional, type=boolean
;     set to indicate that the image corresponds to the standard deviation of
;     IQUV data
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_all_iquv_image, data, $
                                backgrounds, $
                                l1_basename, $
                                wave_region, $
                                wavelengths, $
                                occulter_radius, $
                                post_angle, $
                                p_angle, $
                                daily=daily, $
                                sigma=sigma, $
                                run=run
  compile_opt strictarr

  n_wavelengths = n_elements(wavelengths)

  case 1 of
    n_wavelengths le 5: reduce_dims_factor = 4L
    n_wavelengths gt 5: reduce_dims_factor = 8L
    n_wavelengths gt 11: reduce_dims_factor = 16L
  endcase

  output_dirname = filepath('', $
                        subdir=[run.date, keyword_set(daily) ? 'level2' : 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, output_dirname, logger_name=run.logger_name

  iquv_basename_format = file_basename(l1_basename, '.fts')
  if (run->config('centering/perform')) then begin
    iquv_basename_format += '.iquv.all.png'
  endif else begin
    iquv_basename_format += '.iquv.all.cam%d.png'
  endelse
  iquv_filename_format = filepath(iquv_basename_format, root=output_dirname)

  intensity_display_min   = run->line(wave_region, 'intensity_display_min')
  intensity_display_max   = run->line(wave_region, 'intensity_display_max')
  intensity_display_gamma = run->line(wave_region, 'intensity_display_gamma')
  intensity_display_power = run->line(wave_region, 'intensity_display_power')

  qu_display_min   = run->line(wave_region, 'qu_display_min')
  qu_display_max   = run->line(wave_region, 'qu_display_max')
  qu_display_gamma = run->line(wave_region, 'qu_display_gamma')
  qu_display_power = run->line(wave_region, 'qu_display_power')

  v_display_min   = run->line(wave_region, 'v_display_min')
  v_display_max   = run->line(wave_region, 'v_display_max')
  v_display_gamma = run->line(wave_region, 'v_display_gamma')
  v_display_power = run->line(wave_region, 'v_display_power')

  background_display_min   = run->line(wave_region, 'background_display_min')
  background_display_max   = run->line(wave_region, 'background_display_max')
  background_display_gamma = run->line(wave_region, 'background_display_gamma')
  background_display_power = run->line(wave_region, 'background_display_power')

  if (keyword_set(sigma)) then begin
    i_sigma_level = 0.02
    quv_sigma_level = 0.20
    intensity_display_min *= i_sigma_level
    intensity_display_max *= i_sigma_level
    qu_display_min = 0.0
    qu_display_max *= quv_sigma_level
    v_display_min = 0.0
    v_display_max *= quv_sigma_level
  endif

  datetime = strmid(l1_basename, 0, keyword_set(daily) ? 8 : 15)
  date_stamp = ucomp_dt2stamp(datetime)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  ; size is all wavelengths in the x-direction, IQUVB in the y-direction
  device, decomposed=0, $
          set_pixel_depth=24, $
          set_resolution=[n_wavelengths * nx, 5L * ny] / reduce_dims_factor

  n_colors = 252

  text_color = 252
  occulter_color = 253
  guess_color = 254
  inflection_color = 255

  tvlct, 255, 255, 255, text_color
  tvlct, 0, 255, 255, occulter_color
  tvlct, 255, 255, 0, guess_color
  tvlct, 255, 0, 0, inflection_color

  xmargin = 0.05
  ymargin = 0.03

  charsize = 1.0
  title_charsize = 1.25
  detail_charsize = 0.9

  dims = size(data, /dimensions)
  if (run->config('display/mask_l1') || run->line(wave_region, 'mask_l1')) then begin
    mask = ucomp_mask(dims[0:1] / reduce_dims_factor, $
                      field_radius=run->epoch('field_radius') / reduce_dims_factor, $
                      occulter_radius=occulter_radius / reduce_dims_factor, $
                      post_angle=post_angle, $
                      p_angle=p_angle)
  endif else if (run->line(wave_region, 'mask_l1_occulter')) then begin
    mask = ucomp_mask(dims[0:1] / reduce_dims_factor, $
                      field_radius=run->epoch('field_radius') / reduce_dims_factor, $
                      occulter_radius=occulter_radius / reduce_dims_factor, $
                      p_angle=p_angle)
  endif else begin
    mask = bytarr(dims[0] / reduce_dims_factor, dims[1] / reduce_dims_factor) + 1B
  endelse

  pol_states = ['I', 'Q', 'U', 'V']
  for e = 1L, n_wavelengths do begin
    ext_data = reform(data[*, *, *, e - 1L])

    for p = 0L, dims[2] - 1L do begin
      if (p eq 0) then begin
        display_min = intensity_display_min
        display_max = intensity_display_max
        display_gamma = intensity_display_gamma
        display_power = intensity_display_power
        ct_name = 'intensity'
      endif else if (p eq 3) then begin
        display_min = v_display_min
        display_max = v_display_max
        display_gamma = v_display_gamma
        display_power = v_display_power
        ct_name = 'quv'
      endif else begin
        display_min = qu_display_min
        display_max = qu_display_max
        display_gamma = qu_display_gamma
        display_power = qu_display_power
        ct_name = 'quv'
      endelse

      ucomp_loadct, ct_name, n_colors=n_colors
      mg_gamma_ct, display_gamma, /current, n_colors=n_colors

      im = rebin(ext_data[*, *, p], $
                 dims[0] / reduce_dims_factor, $
                 dims[1] / reduce_dims_factor)

      scaled_im = bytscl(mg_signed_power(im * mask, display_power), $
                         min=mg_signed_power(display_min, display_power), $
                         max=mg_signed_power(display_max, display_power), $
                         top=n_colors - 1L, $
                         /nan)

      tv, scaled_im, p * n_wavelengths + e - 1L

      if (p eq 0L and e eq 1L) then begin
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (dims[2] + 1.0 - 2.5 * ymargin) * dims[1] / reduce_dims_factor, $
                /device, $
                string(run->line(wave_region, 'ionization'), $
                       wave_region, $
                       format='(%"%s!C%s nm")'), $
                charsize=charsize, color=text_color
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (dims[2] + 1.0 - 1.0 + ymargin) * dims[1] / reduce_dims_factor, $
                /device, $
                date_stamp, $
                charsize=charsize, color=text_color
      endif

      w = (e - 1L) mod n_wavelengths
      if (p eq 0L) then begin
        xyouts, (w + 0.5) * dims[0] / reduce_dims_factor, $
                (dims[2] + 1.0 - 3.0 * ymargin) * dims[1] / reduce_dims_factor, $
                /device, alignment=0.5, $
                string(wavelengths[w], format='(%"%0.3f nm")'), $
                charsize=charsize, color=text_color
      endif
      if (w eq n_wavelengths - 1L) then begin
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (dims[2] - p + 1.0 - 0.5 - 0.5 * ymargin) * dims[1] / reduce_dims_factor, $, $
                /device, $
                pol_states[p], $
                charsize=charsize, color=text_color
      endif
    endfor
  endfor

  display_min   = background_display_min
  display_max   = background_display_max
  display_gamma = background_display_gamma
  display_power = background_display_power
  ct_name       = 'background'

  ucomp_loadct, ct_name, n_colors=n_colors
  mg_gamma_ct, display_gamma, /current, n_colors=n_colors
  for e = 1L, n_wavelengths do begin
    im = rebin(reform(backgrounds[*, *, 0, e - 1L]), $
               dims[0] / reduce_dims_factor, $
               dims[1] / reduce_dims_factor)
    scaled_im = bytscl(mg_signed_power(im * mask, display_power), $
                       min=mg_signed_power(display_min, display_power), $
                       max=mg_signed_power(display_max, display_power), $
                       top=n_colors - 1L, $
                       /nan)
    print, display_power, display_min, display_max, display_gamma
    tv, scaled_im, 4 * n_wavelengths + e - 1L
  endfor

  xyouts, xmargin * dims[0] / reduce_dims_factor, $
          0.5 * dims[1] / reduce_dims_factor, $, $
          /device, $
          'B', $
          charsize=charsize, color=text_color

  iquv_filename = iquv_filename_format
  write_png, iquv_filename, tvrd(true=1)
  mg_log, 'wrote %s', file_basename(iquv_filename), $
          name=run.logger_name, /debug

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


; main-level example program

date = '20240409'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

l1_dir = filepath('level1', subdir=date, root=run->config('processing/basedir'))

wave_region = '1074'
l1_basename = '20240409.180748.ucomp.1074.l1.p5.fts'
l1_filename = filepath(l1_basename, root=l1_dir)

ucomp_read_l1_data, l1_filename, $
                    primary_data=primary_data, $
                    primary_header=primary_header, $
                    ext_data=ext_data, $
                    ext_headers=ext_headers, $
                    background_data=background_data, $
                    background_headers=background_headers, $
                    n_wavelengths=n_wavelengths

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
post_angle = ucomp_getpar(primary_header, 'POST_ANG')
p_angle = ucomp_getpar(primary_header, 'SOLAR_P0')
wavelengths = fltarr(n_wavelengths)
for w = 0L, n_wavelengths - 1L do begin
  wavelengths[w] = ucomp_getpar(ext_headers[w], 'WAVELNG')
endfor

ucomp_write_all_iquv_image, ext_data, $
                            background_data, $
                            l1_basename, $
                            wave_region, $
                            wavelengths, $
                            occulter_radius, $
                            post_angle, $
                            p_angle, $
                            run=run

obj_destroy, run

end
