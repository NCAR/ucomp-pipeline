; docformat = 'rst'


;= graphics

;+
; Output annotations on the current graphics window, displaying the geometry.
;
; :Params:
;   camera : in, required, type=integer
;     camera index, 0 for RCAM, 1 for TCAM
;
; :Keywords:
;   occulter_color : in, optional, type=long
;     color to use for the occulter center and edge display
;   guess_color : in, optional, type=long
;     color to use for the guess center and edge display
;   inflection_color : in, optional, type=long
;     color to use for the inflection points display
;   no_rotate : in, optional, type=boolean
;     don't rotate the geometry by the p-angle
;   final_only : in, optional, type=boolean
;     set to only display the final occulter position, not the initial guess
;     center/circle
;-
pro ucomp_geometry::display, camera, $
                             occulter_color=occulter_color, $
                             guess_color=guess_color, $
                             inflection_color=inflection_color, $
                             no_rotate=no_rotate, $
                             final_only=final_only
  compile_opt strictarr

  _occulter_color   = mg_default(occulter_color, self.occulter_color)
  _guess_color      = mg_default(guess_color, self.guess_color)
  _inflection_color = mg_default(inflection_color, self.inflection_color)

  ; display inflection points
  if ((n_elements(*self.inflection_points) gt 0L) and ~keyword_set(final_only)) then begin
    if (keyword_set(no_rotate)) then begin
      x_center = self.occulter_center[0]
      y_center = self.occulter_center[1]
    endif else begin
      x_center = (self.xsize - 1.0) / 2.0
      y_center = (self.ysize - 1.0) / 2.0
    endelse

    points = *self.inflection_points

    xshift = x_center - self.occulter_center[0]
    yshift = y_center - self.occulter_center[1]

    x = points[0, *] + xshift
    y = points[1, *] + yshift

    if (~keyword_set(no_rotate)) then begin
      mg_rotate_points, x, y, -self.p_angle, $
                        new_x=x_rotated, new_y=y_rotated, $
                        center=[x_center, y_center]
    endif else begin
      x_rotated = x
      y_rotated = y
    endelse

    plots, x_rotated, y_rotated, $
           /device, $
           color=_inflection_color, $
           thick=1.0, $
           psym=6, symsize=0.75
  endif

  ; display occulter guess
  if (finite(self.radius_guess) && ~keyword_set(final_only)) then begin
    t = findgen(360) * !dtor

    if (keyword_set(no_rotate)) then begin
      x0 = self.occulter_center[0]
      y0 = self.occulter_center[1]
    endif else begin
      x0 = (self.xsize - 1.0) / 2.0
      y0 = (self.ysize - 1.0) / 2.0
    endelse

    inner_x = (self.radius_guess - self.dradius) * cos(t) + x0
    inner_y = (self.radius_guess - self.dradius) * sin(t) + y0
    plots, inner_x, inner_y, /device, $
           color=_guess_color, $
           linestyle=3

    outer_x = (self.radius_guess + self.dradius) * cos(t) + x0
    outer_y = (self.radius_guess + self.dradius) * sin(t) + y0
    plots, outer_x, outer_y, /device, $
           color=_guess_color, $
           linestyle=3

    plots, x0, y0, /device, color=_guess_color, psym=1
  endif

  ; display occulter fit
  if (finite(self.occulter_radius)) then begin
    t = findgen(360) * !dtor
    if (keyword_set(no_rotate)) then begin
      x0 = self.occulter_center[0]
      y0 = self.occulter_center[1]
    endif else begin
      x0 = (self.xsize - 1.0) / 2.0
      y0 = (self.ysize - 1.0) / 2.0
    endelse
    x = self.occulter_radius * cos(t) + x0
    y = self.occulter_radius * sin(t) + y0
    plots, x, y, /device, color=_occulter_color, thick=2.0, linestyle=2
    plots, x0, y0, /device, color=_occulter_color, psym=1
  endif

  ; display post
  if (finite(self.post_angle)) then begin
    width = 35.0
    t = (self.post_angle + 90.0) * !dtor
    if (keyword_set(no_rotate)) then begin
      x0 = self.occulter_center[0]
      y0 = self.occulter_center[1]
    endif else begin
      x0 = (self.xsize - 1.0) / 2.0
      y0 = (self.ysize - 1.0) / 2.0
    endelse
    x1 = self.occulter_radius * cos(t) + x0
    y1 = self.occulter_radius * sin(t) + y0
    v = [y1 - y0, x0 - x1]
    v /= sqrt(total(v^2))
    v *= width
    v2 = [x1, y1] + v
    v3 = [x1, y1] - v
    v4 = [x1 - x0, y1 - y0] + v2
    v5 = [x1 - x0, y1 - y0] + v3
    plots, [v2[0], v4[0]], [v2[1], v4[1]], /device, color=_occulter_color
    plots, [v3[0], v5[0]], [v3[1], v5[1]], /device, color=_occulter_color
  endif
end


;= property access

;+
; Set object properties.
;-
pro ucomp_geometry::setProperty, xsize=xsize, $
                                 ysize=ysize, $
                                 center_guess=center_guess, $
                                 radius_guess=radius_guess, $
                                 dradius=dradius, $
                                 inflection_points=inflection_points, $
                                 occulter_center=occulter_center, $
                                 occulter_radius=occulter_radius, $
                                 occulter_chisq=occulter_chisq, $
                                 occulter_error=occulter_error, $
                                 post_angle=post_angle, $
                                 eccentricity=eccentricity, $
                                 ellipse_angle=ellipse_angle, $
                                 p_angle=p_angle
  compile_opt strictarr

  if (n_elements(xsize) gt 0L) then self.xsize = xsize
  if (n_elements(ysize) gt 0L) then self.ysize = ysize
  if (n_elements(center_guess) gt 0L) then self.center_guess = center_guess
  if (n_elements(radius_guess) gt 0L) then self.radius_guess = radius_guess
  if (n_elements(dradius) gt 0L) then self.dradius = dradius
  if (n_elements(inflection_points) gt 0L) then *self.inflection_points = inflection_points
  if (n_elements(occulter_center) gt 0L) then self.occulter_center = occulter_center
  if (n_elements(occulter_radius) gt 0L) then self.occulter_radius = occulter_radius
  if (n_elements(occulter_chisq) gt 0L) then self.occulter_chisq = occulter_chisq
  if (n_elements(occulter_error) gt 0L) then self.occulter_error = occulter_error
  if (n_elements(post_angle) gt 0L) then self.post_angle = post_angle
  if (n_elements(eccentricity) gt 0L) then self.eccentricity = eccentricity
  if (n_elements(ellipse_angle) gt 0L) then self.ellipse_angle = ellipse_angle
  if (n_elements(p_angle) gt 0L) then self.p_angle = p_angle
end


;+
; Get object properties.
;-
pro ucomp_geometry::getProperty, xsize=xsize, $
                                 ysize=ysize, $
                                 center_guess=center_guess, $
                                 radius_guess=radius_guess, $
                                 dradius=dradius, $
                                 inflection_points=inflection_points, $
                                 occulter_center=occulter_center, $
                                 occulter_radius=occulter_radius, $
                                 occulter_chisq=occulter_chisq, $
                                 occulter_error=occulter_error, $
                                 post_angle=post_angle, $
                                 eccentricity=eccentricity, $
                                 ellipse_angle=ellipse_angle, $
                                 p_angle=p_angle
  compile_opt strictarr

  if (arg_present(xsize)) then xsize = self.xsize
  if (arg_present(ysize)) then ysize = self.ysize
  if (arg_present(center_guess)) then center_guess = self.center_guess
  if (arg_present(radius_guess)) then radius_guess = self.radius_guess
  if (arg_present(dradius)) then dradius = self.dradius
  if (arg_present(inflection_points)) then inflection_points = *self.inflection_points
  if (arg_present(occulter_center)) then occulter_center = self.occulter_center
  if (arg_present(occulter_radius)) then occulter_radius = self.occulter_radius
  if (arg_present(occulter_chisq)) then occulter_chisq = self.occulter_chisq
  if (arg_present(occulter_error)) then occulter_error = self.occulter_error
  if (arg_present(post_angle)) then post_angle = self.post_angle
  if (arg_present(eccentricity)) then eccentricity = self.eccentricity
  if (arg_present(ellipse_angle)) then ellipse_angle = self.ellipse_angle
  if (arg_present(p_angle)) then p_angle = self.p_angle
end


;= lifecycle methods

;+
; Free resources of the geometry object.
;-
pro ucomp_geometry::cleanup
  compile_opt strictarr

  ptr_free, self.inflection_points
end


;+
; Initialize the geometry object.
;
; :Returns:
;   1 for successful initialization, 0 for failure
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `setProperty`
;-
function ucomp_geometry::init, _extra=e
  compile_opt strictarr

  self.center_guess = fltarr(2) + !values.f_nan
  self.radius_guess = !values.f_nan
  self.inflection_points = ptr_new(/allocate_heap)

  self.occulter_center = fltarr(2) + !values.f_nan
  self.occulter_radius = !values.f_nan

  self.post_angle = !values.f_nan
  self.eccentricity = !values.f_nan
  self.ellipse_angle = !values.f_nan

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
            xsize             : 0L, $
            ysize             : 0L, $
            center_guess      : fltarr(2), $
            radius_guess      : 0.0, $
            dradius           : 0.0, $
            inflection_points : ptr_new(), $
            occulter_center   : fltarr(2), $
            occulter_radius   : 0.0, $
            occulter_chisq    : 0.0, $
            occulter_error    : 0L, $
            post_angle        : 0.0, $
            eccentricity      : 0.0, $
            ellipse_angle     : 0.0, $
            p_angle           : 0.0, $
            occulter_color    : 0UL, $
            guess_color       : 0UL, $
            inflection_color  : 0UL}
end
