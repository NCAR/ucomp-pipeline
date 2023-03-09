; docformat = 'rst'

function ucomp_find_geometry, data, $
                              xsize=xsize, $
                              ysize=ysize, $
                              radius_guess=radius_guess, $
                              center_guess=center_guess, $
                              dradius=dradius, $
                              elliptical=elliptical, $
                              eccentricity=eccentricity, $
                              post_angle_guess=post_angle_guess, $
                              post_angle_tolerance=post_angle_tolerance
  compile_opt strictarr

  occulter = ucomp_find_occulter(data, $
                                 chisq=occulter_chisq, $
                                 radius_guess=radius_guess, $
                                 center_guess=center_guess, $
                                 dradius=dradius, $
                                 error=occulter_error, $
                                 points=points, $
                                 elliptical=elliptical, $
                                 eccentricity=eccentricity)

  post_angle = ucomp_find_post(data, $
                               occulter[0:1], $
                               occulter[2], $
                               angle_guess=post_angle_guess, $
                               angle_tolerance=post_angle_tolerance, $
                               error=post_error)

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
