; docformat = 'rst'

;+
; Procedure to find either the edge of the occulting disk.
;
; A 3-element array is returned containing: the x-offset of the image, the
; y-offset of the image, and the occulter radius. The value of chi^2 (`CHISQ`)
; is optionally returned.
;
; :Examples:
;   For example, call like::
;
;     ucomp_find_occulter, data, radius_guess=radius_guess
;
; :Uses:
;   ucomp_radial_derivative, mpfitellipse
;
; :Returns:
;   `fltarr(3)` in the form `[x, y, r]`, or, if ELLIPTICAL is set, `fltarr(5)`
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
;   drad : in, optional, type=float, default=40.0
;     the +/- size of the radius which to scan
;   error : out, optional, type=long
;     0 if no error
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
                              elliptical=elliptical
  compile_opt strictarr

  ; if guess of radius is input, use it, otherwise use default guess
  _radius_guess = n_elements(radius_guess) eq 0L ? 350.0 : radius_guess

  ; if number of points around radius is input, use it, otherwise use default
  ; number of points (+/-) around radius for determination
  _dradius = n_elements(dradius) eq 0L ? 40.0 : dradius

  ; find limb positions, array of angles (theta) and limb positions (r) is returned
  r = ucomp_radial_derivative(data, _radius_guess, _dradius, $
                              angles=angles, $
                              center_guess=center_guess, $
                              points=points)

  x = reform(points[0, *])
  y = reform(points[1, *])
  p = mpfitellipse(x, y, circular=~keyword_set(elliptical), tilt=keyword_set(elliptical), $
                   /quiet, status=status)
  error = status le 0

  return, p[keyword_set(elliptical) ? [2, 3, 0, 1, 4] : [2, 3, 0]]
end


; main-level example program

date = '20210725'
basename = '20210725.230123.ucomp.1074.continuum_correction.7.fts'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'unit', config_filename, /no_log)

filename = filepath(basename, $
                    subdir=[date, 'level1'], $
                    root=run->config('processing/basedir'))

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=4
fits_close, fcb

for c = 0, 1 do begin
  im = total(data[*, *, *, c], 3)
  geometry = ucomp_find_occulter(im, points=points)

  mg_image, bytscl(im, -0.1, 310.0), /new, title=string(c, format='Camera %d')
  plots, points[0, *], points[1, *], /device, color='0000ff'x, thick=1.0, linestyle=2
  t = findgen(360) * !dtor
  x = geometry[2] * cos(t) + geometry[0]
  y = geometry[2] * sin(t) + geometry[1]
  plots, x, y, /device, color='ffff00'x, thick=2.0, linestyle=3
  print, c, geometry, format='camera: %d, x: %0.1f, y: %0.1f, r: %0.1f'
endfor

im0 = total(data[*, *, *, 0], 3)
im1 = total(data[*, *, *, 1], 3)
dims = size(im0, /dimensions)
geometry0 = ucomp_find_occulter(im0)
geometry1 = ucomp_find_occulter(im1)
print, (dims[0] - 1.0) / 2.0 - geometry0[0], $
       (dims[1] - 1.0) / 2.0 - geometry0[1], $
       format='shifting image 0 by %0.1f, %0.1f'
im0 = ucomp_fshift(im0, $
                   (dims[0] - 1.0) / 2.0 - geometry0[0], $
                   (dims[1] - 1.0) / 2.0 - geometry0[1], $
                   interp=2)
print, (dims[0] - 1.0) / 2.0 - geometry1[0], $
       (dims[1] - 1.0) / 2.0 - geometry1[1], $
       format='shifting image 1 by %0.1f, %0.1f'
im1 = ucomp_fshift(im1, $
                   (dims[0] - 1.0) / 2.0 - geometry1[0], $
                   (dims[1] - 1.0) / 2.0 - geometry1[1], $
                   interp=2)
im0 = reverse(reverse(im0, 1), 2)
im1 = reverse(im1, 2)
im = (im0 + im1) / 2.0
mg_image, bytscl(im, -0.1, 310.0), /new, title='Combined'

obj_destroy, run

end
