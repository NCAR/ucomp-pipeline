; docformat = 'rst'

;+
; Procedure to find the edge of the occulting disk.
;
; A 3-element array is returned containing: the x-offset of the image, the
; y-offset of the image, and the occulter radius. The value of chi^2 (`CHISQ`)
; is optionally returned.
;
; :Examples:
;   For example, call like::
;
;     ucomp_find_occulter, data, radius_guess=350.0
;
; :Uses:
;   ucomp_radial_derivative, mpfitellipse, ucomp_circfit
;
; :Returns:
;   `fltarr(3)` in the form `[x, y, r]`, or, if `ELLIPTICAL` is set, `fltarr(5)`
;   in the form `[x, y, semi axis 1, semi axis 2, rotation angle]`
;
; :Params:
;   data : in, required, type="fltarr(nx, ny)"
;     the data array in which to locate the image
;
; :Keywords:
;   chisq : out, optional, type=float
;     set to a named variable to retrieve the chi^2 of the fit
;   radius_guess : in, optional, type=float, default=295. or 224.
;     the optional guess of the radius of the discontinuity
;   center_guess : in, required, type=fltarr(2)
;     guess for the center; if not provided, use center of `data`
;   dradius : in, optional, type=float, default=40.0
;     the +/- size of the radius which to scan
;   error : out, optional, type=long
;     0 if no error
;   points : out, optional, type="fltarr(2, n_points)"
;     points that are fitted to find occulter
;   pt_weights : out, optional, type=fltarr(n_points)
;     set to a named variable to retrieve a normalized weighting of the points
;     returned in `POINTS`
;   elliptical : in, optional, type=boolean
;     set to find elliptical occulter instead of circular occulter
;   eccentricity : out, optional, type=float
;     set to a named variable to retrieve the eccentricity of a valid fit when
;     `ELLIPICAL` is set
;   ellipse_angle : out, optional, type=float
;     set to a named variable to retrieve the angle of the major axis of the
;     ellipse found when `ELLIPTICAL` is set
;   remove_post : in, optional, type=boolean
;     set to remove points in the estimated location of the post from the search
;
; :Author:
;   MLSO Software Team
;-
function ucomp_find_occulter, data, $
                              chisq=chisq, $
                              radius_guess=radius_guess, $
                              center_guess=center_guess, $
                              dradius=dradius, $
                              error=error, $
                              points=points, $
                              pt_weights=pt_weights, $
                              elliptical=elliptical, $
                              eccentricity=eccentricity, $
                              ellipse_angle=ellipse_angle, $
                              remove_post=remove_post
  compile_opt strictarr

  ; if guess of radius is input, use it, otherwise use default guess
  _radius_guess = n_elements(radius_guess) eq 0L ? 330.0 : radius_guess

  ; if number of points around radius is input, use it, otherwise use default
  ; number of points (+/-) around radius for determination
  _dradius = n_elements(dradius) eq 0L ? 80.0 : dradius

  ; find limb positions, array of angles (theta) and limb positions (r) is returned
  r = ucomp_radial_derivative(data, _radius_guess, _dradius, $
                              angles=angles, $
                              center_guess=center_guess, $
                              points=points, $
                              pt_weights=pt_weights)

  x = reform(points[0, *])
  y = reform(points[1, *])

  ; remove points under the occulter post
  if (keyword_set(remove_post)) then begin
    post_width_angle = 8.0
    l0_post_angle = -90.0
    theta = atan(y - center_guess[1], x - center_guess[0]) * !radeg
    non_post_indices = where(theta lt (l0_post_angle - post_width_angle / 2.0) $
                               or theta gt (l0_post_angle + post_width_angle / 2.0))

    points = points[*, non_post_indices]

    if (keyword_set(elliptical)) then begin
      x = x[non_post_indices]
      y = y[non_post_indices]
      pt_weights = pt_weights[non_post_indices]
    endif else begin
      angles = angles[non_post_indices]
      r = r[non_post_indices]
    endelse
  endif

  if (keyword_set(elliptical)) then begin
    p = mpfitellipse(x, y, $
                     weights=pt_weights, $
                     circular=0B, $
                     /tilt, $
                     /quiet, $
                     status=status, $
                     bestnorm=bestnorm)
    error = status le 0
    chisq = bestnorm / n_elements(x)

    eccentricity = sqrt(1 - (p[1] / p[0])^2)
    ellipse_angle = p[4] * !radeg
    return, p[[2, 3, 0, 1, 4]]
  endif else begin
    p = ucomp_circfit(angles, r, chisq=chisq, error=error)
    return, [center_guess, 0.0] + [p[0] / 2.0, p[1] / 2.0, p[2]]
  endelse
end


; main-level example program

date = '20211202'
dt = '20211202.185330.59'
basename = string(strmid(dt, 0, 15), format='%s.ucomp.1074.distortion.5.fts')
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, subdir=['..', '..', 'config'], root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

raw_basedir = run->config('raw/basedir')
raw_basename = string(dt, format='%s.ucomp.1074.l0.fts')
raw_filename = filepath(raw_basename, subdir=date, root=raw_basedir)

file = ucomp_file(raw_filename, run=run)

processing_basedir = run->config('processing/basedir')
filename = filepath(basename, subdir=[date, 'level1', '08-distortion'], root=processing_basedir)

ucomp_read_raw_data, filename, $
                     primary_data=primary_data, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     n_extensions=n_extensions

dims = size(ext_data, /dimensions)
n_pol_states = dims[2]

occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
dradius = 25.0

post_angle_guess = run->epoch('post_angle_guess')
post_angle_tolerance = run->epoch('post_angle_tolerance')

rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
rcam_offband_indices = where(file.onband_indices eq 1, n_rcam_offband)
rcam_im = mean(ext_data[*, *, *, 0, rcam_offband_indices], dimension=3, /nan)
while (size(rcam_im, /n_dimensions) gt 2L) do rcam_im = mean(rcam_im, dimension=3, /nan)
rcam_im = smooth(rcam_im, 2)

occulter = ucomp_find_occulter(rcam_im, $
                               chisq=occulter_chisq, $
                               radius_guess=radius_guess, $
                               center_guess=rcam_center_guess, $
                               dradius=dradius, $
                               error=occulter_error, $
                               points=points, $
                               elliptical=elliptical)

print, rcam_center_guess, format='RCAM center guess: %f, %f'
device, decomposed=1
mg_image, bytscl(rcam_im, -20.0, 20.0), /new

; range
t = findgen(361) * !dtor
x_min = (radius_guess - dradius) * cos(t) + rcam_center_guess[0]
y_min = (radius_guess - dradius) * sin(t) + rcam_center_guess[1]
x_max = (radius_guess + dradius) * cos(t) + rcam_center_guess[0]
y_max = (radius_guess + dradius) * sin(t) + rcam_center_guess[1]

plots, points[0, *], points[1, *], /device, color='00ffff'x
plots, x_min, y_min, /device, color='ffff00'x
plots, x_max, y_max, /device, color='ffff00'x

obj_destroy, [file, run]

end
