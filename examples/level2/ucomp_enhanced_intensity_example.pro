; main-level example program

date = '20220901'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

wave_region = '1074'
processing_basedir = run->config('processing/basedir')
basename = '20220901.182014.ucomp.1074.l2.polarization.fts'
filename = filepath(basename, $
                    subdir=[run.date, 'level2'], $
                    root=processing_basedir)

fits_open, filename, fcb
fits_read, fcb, !null, primary_header, exten_no=0
fits_read, fcb, peak_intensity, peak_intensity_header, exten_no=1
fits_close, fcb

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
post_angle = ucomp_getpar(primary_header, 'POST_ANG')

enhanced_peak_intensity = ucomp_enhanced_intensity(peak_intensity, $
                                                   radius=run->line(wave_region, 'enhanced_intensity_radius'), $
                                                   amount=run->line(wave_region, 'enhanced_intensity_amount'), $
                                                   occulter_radius=occulter_radius, $
                                                   post_angle=post_angle, $
                                                   field_radius=run->epoch('field_radius'), $
                                                   mask=mask)

display_min = run->line(wave_region, 'enhanced_intensity_display_min')
display_max = run->line(wave_region, 'enhanced_intensity_display_max')
display_power = run->line(wave_region, 'enhanced_intensity_display_power')
dims = size(enhanced_peak_intensity, /dimensions)
window, xsize=dims[0], ysize=dims[1], /free, title='Enhanced peak intensity'
tv, bytscl(enhanced_peak_intensity^display_power, $
           min=display_min^display_power, $
           max=display_max^display_power)

obj_destroy, run

end
