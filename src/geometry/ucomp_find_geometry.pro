; docformat = 'rst'

;+
; Find the occulter and post in the given image.
;
; :Returns:
;   `ucomp_geometry` object
;
; :Params:
;   data : in, required, type=`fltarr(nx, ny)`
;     image to find the occulter and post in
;
; :Keywords:
;   xsize : in, required, type=long
;     xsize of the image
;   ysize : in, required, type=long
;     ysize of the image
;   radius_guess : in, optional, type=float
;     initial radius used in occulter finding algorithm
;   center_guess : in, optional, type=fltarr(2)
;     initial center used in occulter finding algorithm
;   dradius : in, optional, type=float
;     amount added and subtracted from `radius_guess` to search for radius in
;   elliptical : in, optional, type=boolean
;     set to allow an elliptical fit
;   eccentricity : out, optional, type=float
;     set to a named variable to retrieve the eccentricity of a valid fit when
;     `ELLIPICAL` is set
;   ellipse_angle : out, optional, type=float
;     set to a named variable to retrieve the angle of the major axis of the
;     ellipse found when `ELLIPTICAL` is set
;   post_angle_guess : in, optional, type=float, default=180.0
;     initial guess angle in degrees from north for the location of the post
;   post_angle_width : in, optional, type=float, default=5.0
;     initial guess for width of Gaussian fit
;   post_angle_tolerance : in, optional, type=float, default=30.0
;     amount added and subtracted to `post_angle_guess` to search for post in
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status, 0 for no error,
;     otherwise for an error in finding the geometry information
;   post_err_msg : out, optional, type=string
;     set to a named variable to retrieve any error message generated in
;     finding the post, will be an empty string if there was no error
;-
function ucomp_find_geometry, data, $
                              xsize=xsize, $
                              ysize=ysize, $
                              radius_guess=radius_guess, $
                              center_guess=center_guess, $
                              dradius=dradius, $
                              elliptical=elliptical, $
                              eccentricity=eccentricity, $
                              ellipse_angle=ellipse_angle, $
                              post_angle_guess=post_angle_guess, $
                              post_angle_width=post_angle_width, $
                              post_angle_search_tolerance=post_angle_search_tolerance, $
                              post_angle_tolerance=post_angle_tolerance, $
                              error=error, $
                              post_err_msg=post_err_msg, $
                              logger_name=logger_name
  compile_opt strictarr

  error = 0L

  occulter = ucomp_find_occulter(data, $
                                 chisq=occulter_chisq, $
                                 radius_guess=radius_guess, $
                                 center_guess=center_guess, $
                                 dradius=dradius, $
                                 error=occulter_error, $
                                 points=points, $
                                 elliptical=elliptical, $
                                 eccentricity=eccentricity, $
                                 ellipse_angle=ellipse_angle, $
                                 /remove_post)
  error or= occulter_error

  post_angle = ucomp_find_post(data, $
                               occulter[0:1], $
                               occulter[2], $
                               angle_guess=post_angle_guess, $
                               angle_width=post_angle_width, $
                               angle_search_tolerance=post_angle_search_tolerance, $
                               error=post_error, $
                               err_msg=post_err_msg, $
                               fit_coefficients=fit_coefficients, $
                               fit_estimates=fit_estimates)
  error or= 2L * post_error

  if (abs(post_angle - post_angle_guess) gt post_angle_tolerance) then begin
    mg_log, 'bad post angle found: %0.1f', post_angle, name=logger_name, /error
    post_angle = post_angle_guess
  endif

  geometry = ucomp_geometry(xsize=xsize, $
                            ysize=ysize, $
                            center_guess=center_guess, $
                            radius_guess=radius_guess, $
                            dradius=dradius, $
                            inflection_points=points, $
                            occulter_center=occulter[0:1], $
                            occulter_radius=occulter[2], $
                            occulter_chisq=occulter_chisq, $
                            occulter_error=occulter_error, $
                            post_angle=post_angle)

  return, geometry
end


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
