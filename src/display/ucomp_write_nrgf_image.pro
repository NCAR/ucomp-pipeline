; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header of the image
;   data : in, required, type="fltarr(nx, ny, nstokes, nexts)"
;     extension data
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_nrgf_image, file, primary_header, data, run=run
  compile_opt strictarr

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_resolution=[nx, ny]

  n_colors = 253
  loadct, 0, /silent, ncolors=n_colors
  mg_gamma_ct, display_gamma, /current, n_colors=n_colors

  occulter_color = 253
  tvlct, 0, 255, 255, occulter_color
  guess_color = 254
  tvlct, 255, 255, 0, guess_color
  inflection_color = 255
  tvlct, 255, 0, 0, inflection_color

  tvlct, r, g, b, /get

  center_wavelength = run->line(file.wave_region, 'center_wavelength')
  center_wavelength_indices = where(abs(center_wavelength - file.wavelengths) lt 0.01, n_center)
  if (n_center eq 0L) then begin
    mg_log, 'no center wavelength found', name=run.logger_name, /warn
    goto, done
  endif

  intensity_im = data[*, *, center_wavelength_indices[0], 0]
  nrgf_intensity_im = ucomp_nrgf(intensity_im, occulter_radius)
  tv, bytscl(nrgf_intensity_im^0.7, 0.0, 5.0, top=n_colors - 1L, /nan)

  nrgf_intensity_filename = filepath(string(file_basename(file.l1_basename, '.fts'), $
                                            format='(%"%s.int.nrgf.gif")'), $
                                     root=l1_dirname)
  write_gif, nrgf_intensity_filename, tvrd(), r, g, b

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


; main-level example program

;date = '20220105'
date = '20211213'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

;l0_basename = '20220105.204523.49.ucomp.1074.l0.fts'
l0_basename = '20211213.190812.67.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

;l1_basename = '20220105.204523.ucomp.1074.l1.5.fts'
l1_basename = '20211213.190812.ucomp.1074.l1.5.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, $
                    primary_header=primary_header, $
                    ext_data=data, $
                    n_wavelengths=n_wavelengths
file.n_extensions = n_wavelengths

ucomp_write_nrgf_image, file, primary_header, data, run=run

obj_destroy, file
obj_destroy, run

end
