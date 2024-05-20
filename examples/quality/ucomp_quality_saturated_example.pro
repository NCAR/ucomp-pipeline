; main-level example

date = '20210810'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

;raw_basename = '20210810.181351.97.ucomp.656.l0.fts'
raw_basename = '20210810.184908.08.ucomp.1083.l0.fts'
raw_filename = filepath(raw_basename, $
                        subdir=[date], $
                        root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)
print, file.raw_filename
ucomp_read_raw_data, file.raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     repair_routine=run->epoch('raw_data_repair_routine')

success = ucomp_quality_saturated(file, $
                                  primary_header, $
                                  ext_data, $
                                  ext_headers, $
                                  run=run)

print, file.n_rcam_onband_saturated_pixels, $
       file.n_tcam_onband_saturated_pixels, $
       format='# RCAM onband saturated pixels: %d, # TCAM onband saturated pixels: %d'
print, file.n_rcam_bkg_saturated_pixels, $
       file.n_tcam_bkg_saturated_pixels, $
       format='# RCAM bkg saturated pixels: %d, # TCAM bkg saturated pixels: %d'
print, file.n_rcam_onband_nonlinear_pixels, $
       file.n_tcam_onband_nonlinear_pixels, $
       format='# RCAM onband nonlinear pixels: %d, # TCAM onband nonlinear pixels: %d'
print, file.n_rcam_bkg_nonlinear_pixels, $
       file.n_tcam_bkg_nonlinear_pixels, $
       format='# RCAM bkg nonlinear pixels: %d, # TCAM bkg nonlinear pixels: %d'

obj_destroy, file
obj_destroy, run

end
