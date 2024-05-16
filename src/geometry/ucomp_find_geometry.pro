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
