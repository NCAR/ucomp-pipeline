

; main-level example program

date = '20220208'
config_basename = 'ucomp.post.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

basename = '20220208.203556.ucomp.1074.distortion.p3.fts'
; basename = '20220208.203522.ucomp.1074.distortion.p3.fts'
filename = filepath(basename, $
                    subdir=[date, 'level1', '08-distortion'], $
                    root=run->config('processing/basedir'))

fits_open, filename, fcb
fits_read, fcb, primary_data, primary_header, exten_no=0

n_extensions = 6
data = make_array(dimension=[1280, 1024, 4, 2, n_extensions], type=4)
onband = strarr(n_extensions)
for e = 0L, n_extensions - 1L do begin
  fits_read, fcb, d, h, exten_no=e + 1L
  data[*, *, *, *, e] = d
  onband[e] = sxpar(h, 'ONBAND')
endfor
fits_close, fcb

dradius = run->epoch('dradius')

occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')

radius_guess = ucomp_radius_guess(occulter_id, sxpar(primary_header, 'FILTER'), run=run)

post_angle_guess = run->epoch('post_angle_guess')
post_angle_tolerance = run->epoch('post_angle_tolerance')
post_angle_search_tolerance = run->epoch('post_angle_search_tolerance')

rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
tcam_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)

rcam_offband_indices = where(onband ne 'rcam', n_rcam_offband)
tcam_offband_indices = where(onband ne 'tcam', n_tcam_offband)

rcam_background = mean(reform(data[*, *, *, 0, rcam_offband_indices]), dimension=4, /nan)
while (size(rcam_background, /n_dimensions) gt 3L) do rcam_background = mean(rcam_background, dimension=4, /nan)
rcam_background = mean(rcam_background, dimension=3, /nan)

rcam_background = smooth(rcam_background, 2, /nan)
rcam_geometry = ucomp_find_geometry(rcam_background, $
                                    xsize=run->epoch('nx'), $
                                    ysize=run->epoch('ny'), $
                                    center_guess=rcam_center_guess, $
                                    radius_guess=radius_guess, $
                                    dradius=dradius, $
                                    post_angle_guess=post_angle_guess, $
                                    post_angle_tolerance=post_angle_tolerance, $
                                    post_angle_search_tolerance=post_angle_search_tolerance, $
                                    error=rcam_error, $
                                    post_err_msg=rcam_post_err_msg, $
                                    logger_name=run.logger_name)

print, rcam_geometry.post_angle, format='RCAM post angle: %0.2f degrees'

tcam_background = mean(reform(data[*, *, *, 1, tcam_offband_indices]), dimension=4, /nan)
while (size(tcam_background, /n_dimensions) gt 3L) do tcam_background = mean(tcam_background, dimension=4, /nan)
tcam_background = mean(tcam_background, dimension=3, /nan)

tcam_background = smooth(tcam_background, 2, /nan)
tcam_geometry = ucomp_find_geometry(tcam_background, $
                                    xsize=run->epoch('nx'), $
                                    ysize=run->epoch('ny'), $
                                    center_guess=tcam_center_guess, $
                                    radius_guess=radius_guess, $
                                    dradius=dradius, $
                                    post_angle_guess=post_angle_guess, $
                                    post_angle_tolerance=post_angle_tolerance, $
                                    post_angle_search_tolerance=post_angle_search_tolerance, $
                                    error=tcam_error, $
                                    post_err_msg=tcam_post_err_msg, $
                                    logger_name=run.logger_name)

print, tcam_geometry.post_angle, format='TCAM post angle: %0.2f degrees'

obj_destroy, run

end
