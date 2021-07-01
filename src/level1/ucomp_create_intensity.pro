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
pro ucomp_create_intensity, file, data, run=run
  compile_opt strictarr

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  intensity_basename_format = string(file_basename(file.l1_basename, '.fts'), $
                                     format='(%"%s.int.ext%%02d.gif")')
  intensity_filename_format = mg_format(filepath(intensity_basename_format, $
                                                 root=l1_dirname))

  display_min   = run->line(file.wave_region, 'intensity_display_min')
  display_max   = run->line(file.wave_region, 'intensity_display_max')
  display_gamma = run->line(file.wave_region, 'intensity_display_gamma')

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_resolution=[nx, ny]
  loadct, 0, /silent
  gamma_ct, display_gamma, /current
  tvlct, r, g, b, /get

  for e = 1L, file.n_extensions do begin
    if (file.n_extensions eq 1L) then begin
      im = total(reform(data), 3, /preserve_type)
    endif else begin
      im = total(reform(data[*, *, *, e - 1]), 3, /preserve_type)
    endelse

    tvscl, bytscl(im, min=display_min, max=display_max)
    xyouts, 15, 15, /device, alignment=0.0, $
            string(e, format='(%"ext: %d")')
    xyouts, nx - 15, 15, /device, alignment=1.0, $
            string(display_min, display_max, format='(%"min/max: %0.1f/%0.1f")')

    write_gif, string(e, format=intensity_filename_format), tvrd(), r, g, b
  endfor

  done:
  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end
