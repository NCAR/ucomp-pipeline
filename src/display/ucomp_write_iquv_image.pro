; docformat = 'rst'

;+
; Process a plot of the center wavelength from a UCoMP science file.
;
; :Params:
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;   l1_basename : in, required, type=string
;     level 1 basename for corresponding to the given data
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;   wavelengths : in, required, type=fltarr(nexts)
;     wavelengths corresponding to the images in the `nexts` dimension of the
;     data
;
; :Keywords:
;   daily : in, optional, type=boolean
;     set to indicate that the image corresponds to a daily average in the
;     level 2 directory
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_iquv_image, data, $
                            l1_basename, $
                            wave_region, $
                            wavelengths, $
                            occulter_radius=occulter_radius, $
                            daily=daily, $
                            run=run
  compile_opt strictarr

  dims = size(data, /dimensions)
  n_extensions = dims[3]

  reduce_dims_factor = 2L
  center_wavelength_only = run->config('intensity/center_wavelength_gifs_only')

  l1_dirname = filepath('', $
                        subdir=[run.date, keyword_set(daily) ? 'level2' : 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  iquv_basename_format = file_basename(l1_basename, '.fts')
  iquv_basename_format += '.iquv'
  if (~center_wavelength_only) then iquv_basename_format += '.ext%02d'
  iquv_basename_format += '.png'
  iquv_filename_format = filepath(iquv_basename_format, root=l1_dirname)

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

  datetime = strmid(l1_basename, 0, keyword_set(daily) ? 8 : 15)
  date_stamp = ucomp_dt2stamp(datetime)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=24, $
          set_resolution=2L * [nx, ny] / reduce_dims_factor

  n_colors = 252

  xmargin = 0.05
  ymargin = 0.05

  text_color = 252
  occulter_color = 253
  guess_color = 254
  inflection_color = 255

  tvlct, 255, 255, 255, text_color
  tvlct, 0, 255, 255, occulter_color
  tvlct, 255, 255, 0, guess_color
  tvlct, 255, 0, 0, inflection_color

  charsize = 1.25
  title_charsize = 1.75
  detail_charsize = 0.9

  n_divisions = 4L

  pol_states = ['I', 'Q', 'U', 'V']
  for e = 1L, n_extensions do begin
    if (center_wavelength_only) then begin
      diff = wavelengths[e - 1L] - run->line(wave_region, 'center_wavelength')
      if (abs(diff) gt 0.01) then continue
    endif

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
      if (run->config('display/mask_l1') || run->line(wave_region, 'mask_l1')) then begin
        mask = ucomp_mask(dims[0:1] / reduce_dims_factor, $
                          occulter_radius=n_elements(occulter_radius) gt 0L $
                            ? occulter_radius / reduce_dims_factor $
                            : !null, $
                          field_radius=run->epoch('field_radius') / reduce_dims_factor)
      endif else begin
        mask = bytarr(dims[0] / reduce_dims_factor, dims[1] / reduce_dims_factor) + 1B
      endelse

      scaled_im = bytscl(mg_signed_power(im * mask, display_power), $
                         min=mg_signed_power(display_min, display_power), $
                         max=mg_signed_power(display_max, display_power), $
                         top=n_colors - 1L, $
                         /nan)

      tv, scaled_im, p
      if (p eq 0L) then begin
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (2.0 - ymargin) * dims[1] / reduce_dims_factor, $
                /device, $
                string(run->line(wave_region, 'ionization'), $
                       run->line(wave_region, 'center_wavelength'), $
                       format='(%"%s %0.2f nm")'), $
                charsize=charsize, color=text_color
        xyouts, xmargin * dims[0] / reduce_dims_factor, $
                (1.0 + ymargin) * dims[1] / reduce_dims_factor, $
                /device, $
                date_stamp, $
                charsize=charsize, color=text_color
      endif
      xyouts, 0.25 + (p mod 2) / 2.0, 0.75 - (p / 2) / 2.0 + 0.025, $
              /normal, $
              display_power eq 1.0 $
                ? pol_states[p] $
                : string(pol_states[p], display_power, format='%s!E%0.2f!N'), $
              charsize=title_charsize, alignment=0.5, color=text_color
      colorbar2, position=[0.25 + (p mod 2) / 2.0 - 0.075, 0.75 - (p / 2) / 2.0, $
                           0.25 + (p mod 2) / 2.0 + 0.075, 0.75 - (p / 2) / 2.0 + 0.01], $
                 charsize=detail_charsize, $
                 color=text_color, $
                 ncolors=n_colors, $
                 range=mg_signed_power([display_min, display_max], display_power), $
                 divisions=n_divisions, $
                 format='(F0.1)'
    endfor

    if (center_wavelength_only) then begin
      iquv_filename = iquv_filename_format
    endif else begin
      iquv_filename = string(e, format=iquv_filename_format)
    endelse

    write_png, iquv_filename, tvrd(true=1)
    mg_log, 'wrote %s', file_basename(iquv_filename), $
            name=run.logger_name, /debug
  endfor

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


; main-level example program

; date = '20220105'
; date = '20220727'
date = '20220901'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

; l0_basename = '20220105.204523.49.ucomp.1074.l0.fts'
; l0_basename = '20220727.225643.89.ucomp.1074.l0.fts'
; l0_basename = '20220902.024545.71.ucomp.1074.l0.fts'
l0_basename = '20220902.031311.23.ucomp.706.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

; l1_basename = '20220105.204523.ucomp.1074.l1.5.fts'
; l1_basename = '20220727.225643.ucomp.1074.l1.3.fts'
; l1_basename = '20220902.024545.ucomp.1074.l1.3.fts'
l1_basename = '20220902.031311.ucomp.706.l1.3.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, ext_data=data, n_wavelengths=n_wavelengths, $
                    primary_header=primary_header
file.n_extensions = n_wavelengths

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

ucomp_write_iquv_image, data, l1_basename, file.wave_region, file.wavelengths, $
                        occulter_radius=occulter_radius, $
                        run=run

obj_destroy, file
obj_destroy, run

end
