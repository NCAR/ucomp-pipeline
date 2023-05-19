; docformat = 'rst'

;+
; Write an intermediate GIF file if turned on in the config options.
;
; :Params:
;   name : in, required, type=string
;     name of the step of the level 1 processing after which to write the file,
;     i.e., "apply_gain", "demodulation", etc.
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     FITS primary header
;   data : in, required, type="fltarr(nx, ny, ..., n_extensions)"
;     data to write
;   headers : in, required, type=list
;     list of `strarr` FITS headers
;
; :Keywords:
;   step_number : in, required, type=integer
;     number of the step in the level 1 processing for a file
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_intermediate_image, name, $
                                    file, primary_header, data, headers, $
                                    step_number=step_number, run=run
  compile_opt strictarr
  on_error, 2

  if (~run->config('intermediate/after_' + name)) then goto, done

  dims = size(data, /dimensions)   ; [nx, ny, n_polstates, n_cameras, n_exts]
  n_dims = size(data, /n_dimensions)
  n_exts = n_elements(headers)
  case n_dims of
    3: n_cameras = 1L
    4: n_cameras = n_exts gt 1L ? 1L : dims[3]
    5: n_cameras = dims[3]
    else: message, string(n_dims, format='(%"wrong number of dimensions: %d")')
  endcase

  intermediate_dirname = filepath(string(step_number, name, $
                                         format='(%"%02d-%s")'), $
                                  subdir=[run.date, 'level1'], $
                                  root=run->config('processing/basedir'))
  file->getProperty, l1_basename=basename, intermediate_name=name
  basename = file_basename(basename, '.fts')

  if (~file_test(intermediate_dirname, /directory)) then begin
    ucomp_mkdir, intermediate_dirname, logger_name=run.logger_name
  endif

  percent_stretch = 0.05
  display_gamma = run->line(file.wave_region, 'intensity_display_gamma')

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
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

  for e = 1L, n_exts do begin
    for c = 0L, n_cameras - 1L do begin

      e_basename = basename
      if (n_cameras gt 1L) then begin
        e_basename = string(e_basename, c, format='(%"%s.cam%d")')
      endif
      e_basename = string(e_basename, e, format='(%"%s.ext%02d.gif")')
      e_filename = filepath(e_basename, root=intermediate_dirname)

      ; get an nx by ny image, depending on current data
      if (n_cameras gt 1L) then begin
        if (n_exts gt 1L) then begin
          im = data[*, *, *, c, e - 1]
        endif else begin
          im = data[*, *, *, c]
        endelse
      endif else begin
        if (n_exts gt 1L) then begin
          im = data[*, *, *, e - 1]
        endif else begin
          im = data[*, *, *]
        endelse
      endelse
      if (file.demodulated) then begin
        im = im[*, *, 0]
      endif else begin
        im = total(im, 3, /preserve_type)
      endelse

      p = mg_percentiles(im, percentiles=[percent_stretch, 1.0 - percent_stretch])
      display_min = p[0]
      display_max = p[1]
      scaled_im = bytscl(im, $
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

      case c of
        0: geometry = file.rcam_geometry
        1: geometry = file.tcam_geometry
      endcase
      if (obj_valid(geometry)) then begin
        geometry->display, c, $
                           occulter_color=253, $
                           guess_color=254, $
                           inflection_color=255, $
                           no_rotate=file.rotated eq 0B
      endif

      write_gif, e_filename, tvrd(), r, g, b
    endfor
  endfor

  gamma_ct, 1.0, /current   ; reset gamma to linear ramp
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device

  done:
end
