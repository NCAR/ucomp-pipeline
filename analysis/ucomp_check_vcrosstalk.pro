; docformat = 'rst'

pro ucomp_check_vcrosstalk, filename, run=run
  compile_opt strictarr

  ucomp_read_l1_data, filename, $
                      primary_data=primary_data, $
                      primary_header=primary_header, $
                      ext_data=ext_data, $
                      ext_headers=ext_headers, $
                      n_wavelengths=n_wavelengths

  solar_radius = ucomp_getpar(primary_header, 'R_SUN')
  post_angle = ucomp_getpar(primary_header, 'POST_ANG')
  vcrosstalk_by_extension = fltarr(n_wavelengths)
  for w = 0L, n_wavelengths - 1 do begin
    vcrosstalk_by_extension[w] = ucomp_vcrosstalk_metric(ext_data[*, *, *, w], $
                                                         solar_radius, $
                                                         post_angle)
  endfor
  print, vcrosstalk_by_extension
end

; main-level example program

date = '20221025'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'vcrosstalk', config_filename)

basename = '20221025.221016.ucomp.789.l1.p3.fts'
process_basedir = run->config('processing/basedir')

filename = filepath(basename, subdir=[date, 'level1'], root=process_basedir)

ucomp_check_vcrosstalk, filename, run=run

obj_destroy, run

end