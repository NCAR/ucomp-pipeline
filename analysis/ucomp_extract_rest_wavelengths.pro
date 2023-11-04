; docformat = 'rst'

pro ucomp_extract_rest_wavelengths, output_basename_format, $
                                    program, $
                                    start_date, end_date, $
                                    run=run
  compile_opt strictarr

  ; TODO: lower to 3.0? change for other wave_regions
  threshold = 4.0
  wave_region = '1074'
  nx = 1280L
  ny = 1024L

  output_filename = string(program, format=output_basename_format)
  openw, lun, output_filename, /get_lun

  date = start_date
  while date ne end_date do begin
    run.date = date

    process_rootdir = run->config('processing/basedir')
    l2_dir = filepath('', $
                      subdir=[date, 'level2'], $
                      root=process_rootdir)
    if (file_test(l2_dir, /directory)) then begin
      basename = string(date, wave_region, program, $
                        format='%s.ucomp.%s.l2.%s.median.fts')
      filename = filepath(basename, root=l2_dir)
      if (file_test(filename, /regular)) then begin
        fits_open, filename, fcb
        fits_read, fcb, !null, primary_header, exten_no=0

        n_wavelengths = ucomp_getpar(primary_header, 'NUMWAVE')

        wavelengths = fltarr(n_wavelengths)
        intensity = fltarr(nx, ny, n_wavelengths)
        n_above = lonarr(n_wavelengths)

        for w = 0L, n_wavelengths - 1L do begin
          fits_read, fcb, ext_data, ext_header, exten_no=w + 1L
          intensity[*, *, w] = ext_data[*, *, 0]

          wavelengths[w] = ucomp_getpar(ext_header, 'WAVELNG', found=found, /float)
          if (~found) then goto, next

          ; store number of pixels above intensity threshold
          ; TODO: also have a max intensity
          !null = where(ext_data[*, *, 0] gt threshold, count)
          n_above[w] = count
        endfor
        !null = max(n_above, max_index)

        x_values = rebin(findgen(nx) - float(nx) / 2.0, nx, ny)
        east = where(intensity[*, *, max_index] gt threshold and x_values lt 0.0, n_east)
        west = where(intensity[*, *, max_index] gt threshold and x_values gt 0.0, n_west)

        fits_close, fcb

        if (n_east gt 0L && n_west gt 0L) then begin
          y = fltarr(n_wavelengths)
          for w = 0L, n_wavelengths - 1L do begin
            d = intensity[*, *, w]
            y[w] = (median(d[east]) + median(d[west])) / 2.0
          endfor
          ; TODO: always use 3 central lines analytic fit
          if (n_wavelengths gt 3) then begin
            result = gaussfit(wavelengths, y, a, nterms=3)
            center_intensity = a[0]
            center_wavelength = a[1]
            line_width = a[2]
          endif else begin
            gauss_fit_3, wavelengths, y, $
                         center_wavelength, $
                         line_width, $
                         center_intensity
            a = [center_intensity, center_wavelength, line_width]
          endelse
        endif else begin
          center_intensity = !values.f_nan
          center_wavelength = !values.f_nan
          line_width = !values.f_nan
        endelse

        print, date, center_intensity, center_wavelength, line_width
        printf, lun, date, center_intensity, center_wavelength, line_width
      endif
    endif

    next:
    date = ucomp_increment_date(date)
  endwhile

  free_lun, lun
end


; main-level example program

start_date = '20210701'
;start_date = '20220831'
end_date = '20221201'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run('20210526', 'analysis', config_filename)
output_basename_format = 'ucomp.rstwvl.median.%s.txt'
ucomp_extract_rest_wavelengths, output_basename_format, 'synoptic', $
                                start_date, end_date, run=run
ucomp_extract_rest_wavelengths, output_basename_format, 'waves', $
                                start_date, end_date, run=run
obj_destroy, run

end
