; docformat = 'rst'

pro ucomp_raw_differences, filename, wavelength, camera, onband
  compile_opt strictarr

  device, decomposed=0
  ucomp_loadct, 'difference'
  diff_min = -200.0
  diff_max = 200.0

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

  for e1 = 0L, n_elements(extensions) - 1L do begin
    fits_read, fcb, data1, header1, exten_no=extensions[e1]
    intensity1 = float(reform(data1[*, *, 0, camera])) / ucomp_getpar(header1, 'NUMSUM')

    !null = where(intensity1 gt 3000.0, n_nonlinear_pixels)
    print, extensions[e1], n_nonlinear_pixels, format='ext %d: %d nonlinear pixels'

    for e2 = e1 + 1L, n_elements(extensions) - 1L do begin
      fits_read, fcb, data2, header2, exten_no=extensions[e2]
      intensity2 = float(reform(data2[*, *, 0, camera])) / ucomp_getpar(header2, 'NUMSUM')

      mg_image, bytscl(intensity1 - intensity2, min=diff_min, max=diff_max), /new, $
                title=string(file_basename(filename), extensions[e1], extensions[e2], $
                             wavelength, camera ? 'TCAM' : 'RCAM', onband, diff_min, diff_max, $
                             format='%s: ext %d - ext %d [%0.2f nm, camera: %s, ONBAND: %s] (min: %0.1f, max: %0.1f)')
    endfor
  endfor
  fits_close, fcb
end


; main-level example program

; date = '20220901'
; basename = '20220902.005109.76.ucomp.1074.l0.fts'  ; bad
; basename = '20220901.182014.02.ucomp.1074.l0.fts'  ; good

; date = '20221125'
; basename = '20221125.195733.83.ucomp.1074.l0.fts'

date = '20220225'
basename = '20220225.181823.88.ucomp.1074.l0.fts'

wavelength = 1074.70
camera = 0
onband = 'tcam'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

filename = filepath(basename, $
                    subdir=date, $
                    root=run->config('raw/basedir'))

ucomp_raw_differences, filename, wavelength, camera, onband

obj_destroy, run

end
