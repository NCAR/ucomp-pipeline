; docformat = 'rst'

pro ucomp_raw_differences, filename, wavelength, camera, onband, $
                           save_as_image=save_as_image
  compile_opt strictarr

  power = 0.5
  abs_max = 200.0
  diff_min = - abs_max^power
  diff_max = abs_max^power

  fits_open, filename, fcb
  ext_wavelengths = fltarr(fcb.nextend)
  ext_onband = strarr(fcb.nextend)
  for e = 1L, fcb.nextend do begin
    fits_read, fcb, !null, ext_header, exten_no=e
    ext_wavelengths[e - 1] = ucomp_getpar(ext_header, 'WAVELNG')
    ext_onband[e - 1] = ucomp_getpar(ext_header, 'ONBAND')
  endfor

  extensions = where(abs(ext_wavelengths - wavelength) lt 0.01 and (ext_onband eq onband)) + 1L

  print, onband, wavelength, strjoin(strtrim(extensions, 2), ', '), $
         format='extensions with ONBAND=%s and wavelength=%0.2f nm: %s'

  if (n_elements(extensions) eq 1L) then begin
    print, 'only 1 matching extension, skipping'
    goto, cleanup
  endif

  n_diff_images = n_elements(extensions) - 1L
  scale = 2L
  image_width = 1280
  image_height = 1024
  max_height = 1024
  max_rows = max_height / (image_height / scale)
  n_columns = n_diff_images / max_rows
  n_columns += (n_diff_images mod max_rows) gt 0
  n_rows = n_columns gt 1 ? max_rows : n_diff_images

  if (keyword_set(save_as_image)) then begin
    orig_device = !d.name
    set_plot, 'Z'
    device, set_resolution=[image_width / scale * n_columns, image_height / scale * n_rows], $
            decomposed=0, $
            set_pixel_depth=24
  endif else begin
    device, decomposed=0
  endelse

  ucomp_loadct, 'difference'
  if (keyword_set(save_as_image)) then erase, 128

  i = 0L
  for e1 = 0L, n_elements(extensions) - 2L do begin
    fits_read, fcb, data1, header1, exten_no=extensions[e1]
    intensity1 = float(reform(data1[*, *, 0, camera])) / ucomp_getpar(header1, 'NUMSUM')

    !null = where(intensity1 gt 3000.0, n_e1_nonlinear_pixels)
    if (e1 eq 0L) then begin
      print, extensions[e1], n_e1_nonlinear_pixels, format='ext %d: %d non-linear pixels'
    endif

    e2 = e1 + 1L

    ; top is row 0
    row = i / n_columns
    col = i mod n_columns

    fits_read, fcb, data2, header2, exten_no=extensions[e2]
    intensity2 = float(reform(data2[*, *, 0, camera])) / ucomp_getpar(header2, 'NUMSUM')

    !null = where(intensity2 gt 3000.0, n_e2_nonlinear_pixels)
    print, extensions[e2], n_e2_nonlinear_pixels, format='ext %d: %d non-linear pixels'

    if (keyword_set(save_as_image)) then begin
      xpos = col * image_width / scale
      ypos = (n_rows - 1L - row) * image_height / scale
      tv, bytscl(rebin(mg_signed_power(intensity1 - intensity2, 0.5), $
                                       image_width / scale, image_height / scale), $
                 min=diff_min, max=diff_max), $
          xpos, ypos
      device, decomposed=1
      charsize = 1.1
      gap = 0.04 * charsize
      xyouts, xpos + 0.5 * image_width / scale, $
              ypos + (0.5 + gap) * image_height / scale, $
              string(extensions[e1], extensions[e2], format='ext %d - ext %d'), $
              alignment=0.5, color='ffffff'x, /device, charsize=charsize
      xyouts, xpos + 0.5 * image_width / scale, $
              ypos + 0.50 * image_height / scale, $
              string(n_e1_nonlinear_pixels, n_e2_nonlinear_pixels, $
                     format='%d / %d non-linear pixels'), $
              alignment=0.5, color='ffffff'x, /device, charsize=charsize
      xyouts, xpos + 0.5 * image_width / scale, $
              ypos + (0.5 - gap) * image_height / scale, $
              string(power, diff_min, diff_max, $
                     format='diff ^ %0.1f, min: %0.1f, max: %0.1f'), $
              alignment=0.5, color='ffffff'x, /device, charsize=charsize
      device, decomposed=0
      i += 1L
    endif else begin
      mg_image, bytscl(mg_signed_power(intensity1 - intensity2, 0.5), $
                       min=diff_min, max=diff_max), /new, $
                title=string(file_basename(filename), extensions[e1], extensions[e2], $
                             wavelength, camera ? 'TCAM' : 'RCAM', onband, $
                             abs_max, power, - abs_max, power, $
                             format='%s: ext %d - ext %d [%0.2f nm, camera: %s, ONBAND: %s] (min: %0.1f^%0.1f, max: %0.1f^%0.1f)')
    endelse
  endfor

  if (keyword_set(save_as_image)) then begin
    im = tvrd(true=1)
    set_plot, orig_device
    write_png, file_basename(filename) + '.png', im
  endif

  cleanup:
  fits_close, fcb
end


; main-level example program

date = '20220901'
; basenames = ['20220902.005109.76.ucomp.1074.l0.fts']  ; bad
;basenames = ['20220901.182014.02.ucomp.1074.l0.fts']  ; good

; date = '20221125'
; basenames = ['20221125.195733.83.ucomp.1074.l0.fts']

; date = '20220225'
; basenames = ['20220225.181823.88.ucomp.1074.l0.fts']

wavelength = 1074.70
camera = 0
onband = 'rcam'
; camera = 1
; onband = 'tcam'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

glob = filepath('*.ucomp.1074.l0.fts', $
                subdir=date, $
                root=run->config('raw/basedir'))

save_as_image = 1B
if (keyword_set(save_as_image)) then begin
  filenames = file_search(glob, count=n_filenames)
endif else begin
  filenames = filepath(basenames, subdir=date, root=run->config('raw/basedir'))
  n_filenames = n_elements(filenames)
endelse

for f = 0L, n_filenames - 1L do begin
  print, filenames[f]
  ucomp_raw_differences, filenames[f], wavelength, camera, onband, $
                         save_as_image=keyword_set(save_as_image)
endfor

obj_destroy, run

end
