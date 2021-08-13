; docformat = 'rst'


;= graphics

pro ucomp_geometry::display, occulter_color=occulter_color, $
                             guess_color=guess_color, $
                             inflection_color=inflection_color
  compile_opt strictarr

  _occulter_color   = mg_default(occulter_color, self.occulter_color)
  _guess_color      = mg_default(guess_color, self.guess_color)
  _inflection_color = mg_default(inflection_color, self.inflection_color)

  points = *self.inflection_points

  ; display inflection points
  plots, points[0, *], points[1, *], /device, $
         color=self.inflection_color, $
         thick=1.0, $
         linestyle=2

  ; display occulter fit
  t = findgen(360) * !dtor
  x = self.occulter_radius * cos(t) + self.occulter_center[0]
  y = self.occulter_radius * sin(t) + self.occulter_center[1]
  plots, x, y, /device, color=_occulter_color, thick=2.0, linestyle=3
  plots, self.occulter_center[0], self.occulter_center[1], /device, $
         color=_occulter_color, psym=1

  inner_x = (self.radius_guess - self.dradius) * cos(t) + self.center_guess[0]
  inner_y = (self.radius_guess - self.dradius) * sin(t) + self.center_guess[1]
  plots, inner_x, inner_y, /device, $
         color=_guess_color, $
         linestyle=3

  outer_x = (self.radius_guess + self.dradius) * cos(t) + self.center_guess[0]
  outer_y = (self.radius_guess + self.dradius) * sin(t) + self.center_guess[1]
  plots, outer_x, outer_y, /device, $
         color=_guess_color, $
         linestyle=3

  plots, self.center_guess[0], self.center_guess[1], /device, $
         color=_guess_color, psym=1
  
end


;= property access

pro ucomp_geometry::setProperty, center_guess=center_guess, $
                                 radius_guess=radius_guess, $
                                 dradius=dradius, $
                                 inflection_points=inflection_points, $
                                 occulter_center=occulter_center, $
                                 occulter_radius=occulter_radius, $
                                 occulter_chisq=occulter_chisq, $
                                 occulter_error=occulter_error, $
                                 post_angle=post_angle
  compile_opt strictarr

  if (n_elements(center_guess) gt 0L) then self.center_guess = center_guess
  if (n_elements(radius_guess) gt 0L) then self.radius_guess = radius_guess
  if (n_elements(dradius) gt 0L) then self.dradius = dradius
  if (n_elements(inflection_points) gt 0L) then *self.inflection_points = inflection_points
  if (n_elements(occulter_center) gt 0L) then self.occulter_center = occulter_center
  if (n_elements(occulter_radius) gt 0L) then self.occulter_radius = occulter_radius
  if (n_elements(occulter_chisq) gt 0L) then self.occulter_chisq = occulter_chisq
  if (n_elements(occulter_error) gt 0L) then self.occulter_error = occulter_error
  if (n_elements(post_angle) gt 0L) then self.post_angle = post_angle
end


pro ucomp_geometry::getProperty, center_guess=center_guess, $
                                 radius_guess=radius_guess, $
                                 dradius=dradius, $
                                 inflection_points=inflection_points, $
                                 occulter_center=occulter_center, $
                                 occulter_radius=occulter_radius, $
                                 occulter_chisq=occulter_chisq, $
                                 occulter_error=occulter_error, $
                                 post_angle=post_angle
  compile_opt strictarr

  if (arg_present(center_guess)) then center_guess = self.center_guess
  if (arg_present(radius_guess)) then radius_guess = self.radius_guess
  if (arg_present(dradius)) then dradius = self.dradius
  if (arg_present(inflection_points)) then inflection_points = *self.inflection_points
  if (arg_present(occulter_center)) then occulter_center = self.occulter_center
  if (arg_present(occulter_radius)) then occulter_radius = self.occulter_radius
  if (arg_present(occulter_chisq)) then occulter_chisq = self.occulter_chisq
  if (arg_present(occulter_error)) then occulter_error = self.occulter_error
  if (arg_present(post_angle)) then post_angle = self.post_angle
end


;= lifecycle methods

pro ucomp_geometry::cleanup
  compile_opt strictarr

  ptr_free, self.inflection_points
end


function ucomp_geometry::init, _extra=e
  compile_opt strictarr

  self.inflection_points = ptr_new(/allocate_heap)

  self.occulter_color   = 'ffff00'x
  self.guess_color      = '00ffff'x
  self.inflection_color = '0000ff'x

  self->setProperty, _extra=e

  return, 1
end


;+
; Define structure containing information about the geometry of a UCoMP image.
;-
pro ucomp_geometry__define
  compile_opt strictarr
 
   !null = {ucomp_geometry, inherits IDL_Object, $
            center_guess      : fltarr(2), $
            radius_guess      : 0.0, $
            dradius           : 0.0, $
            inflection_points : ptr_new(), $
            occulter_center   : fltarr(2), $
            occulter_radius   : 0.0, $
            occulter_chisq    : 0.0, $
            occulter_error    : 0L, $
            post_angle        : 0.0, $
            occulter_color    : 0UL, $
            guess_color       : 0UL, $
            inflection_color  : 0UL}
end
