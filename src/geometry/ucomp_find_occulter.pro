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
;   ucomp_radial_derivative, mpfitellipse
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
;   elliptical : in, optional, type=boolean
;     set to find elliptical occulter instead of circular occulter
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
  p = mpfitellipse(x, y, $
                   circular=~keyword_set(elliptical), $
                   tilt=keyword_set(elliptical), $
                   /quiet, $
                   status=status, $
                   bestnorm=chisq)
  error = status le 0

  return, p[keyword_set(elliptical) ? [2, 3, 0, 1, 4] : [2, 3, 0]]
end


; main-level example program

date = '20210725'
center_guess = [(1280.0 - 1.0) / 2.0, (1024.0 - 1.0) / 2.0]
; radius_guess = 350.0
dradius = 40.0
display_max = 310.0


; bad fit
; occulter: 28, occulter-x: 61.40, occulter-y: 13.00
date = '20210806'
basename = '20210807.000539.ucomp.1074.demodulation.7.fts'
display_max = 600.0

; min x-occulter
; date = '20210803'
; basename = '20210803.180700.ucomp.1074.demodulation.7.fts'

; max x-occulter
; occulter: NONE, occulter-x: 61.90, occulter-y: 11.70
; date = '20210801'
; basename = '20210801.192854.ucomp.1074.demodulation.7.fts'

; min y-occulter
; occulter: NONE, occulter-x: 61.85, occulter-y: 11.40
; date = '20210802'
; basename = '20210802.174023.ucomp.1074.demodulation.7.fts'

; max y-occulter
; date = '20210805'
; basename = '20210805.222604.ucomp.1074.demodulation.7.fts'


; OK (super noisy, hard to tell)
; basename = '20210725.230515.ucomp.530.demodulation.7.fts'
; radius_guess = 335.0
; display_max = 310.0
; dradius = 20.0
; camera: 0, x: 626.9, y: 505.0, r: 337.4
; camera: 1, x: 650.9, y: 506.0, r: 338.7
; shifting image 0 by 12.6, 6.5
; shifting image 1 by -11.4, 5.5

; OK
; basename = '20210725.230857.ucomp.637.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 50.0
; dradius = 20.0
; camera: 0, x: 628.7, y: 502.9, r: 355.7
; camera: 1, x: 653.8, y: 504.9, r: 358.3
; shifting image 0 by 10.8, 8.6
; shifting image 1 by -14.3, 6.6

; OK
; basename = '20210725.225844.ucomp.656.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 310.0
; dradius = 20.0
; camera: 0, x: 627.0, y: 503.7, r: 355.0
; camera: 1, x: 654.0, y: 503.0, r: 354.9
; shifting image 0 by 12.5, 7.8
; shifting image 1 by -14.5, 8.5

; OK
; basename = '20210725.231100.ucomp.691.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 10.0
; dradius = 20.0
; camera: 0, x: 627.8, y: 504.0, r: 359.4
; camera: 1, x: 652.7, y: 506.6, r: 357.3
; shifting image 0 by 11.7, 7.5
; shifting image 1 by -13.2, 4.9

; OK
; basename = '20210725.231253.ucomp.706.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 50.0
; dradius = 20.0
; camera: 0, x: 629.4, y: 503.8, r: 358.8
; camera: 1, x: 653.8, y: 506.2, r: 353.7
; shifting image 0 by 10.1, 7.7
; shifting image 1 by -14.3, 5.3

; GOOD
; basename = '20210725.231447.ucomp.789.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 50.0
; dradius = 20.0
; camera: 0, x: 628.5, y: 503.3, r: 356.6
; camera: 1, x: 654.4, y: 505.0, r: 353.3
; shifting image 0 by 8.7, 5.0
; shifting image 1 by -12.4, 6.6

; EXCELLENT
; basename = '20210725.230123.ucomp.1074.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 310.0
; dradius = 20.0
; camera: 0, x: 625.3, y: 505.4, r: 355.6
; camera: 1, x: 660.0, y: 505.8, r: 356.9
; shifting image 0 by 14.2, 6.1
; shifting image 1 by -20.5, 5.7

; GOOD
; basename = '20210725.232333.ucomp.1079.demodulation.7.fts'
; radius_guess = 350.0
; display_max = 100.0
; dradius = 20.0
; camera: 0, x: 629.1, y: 504.1, r: 359.6
; camera: 1, x: 654.5, y: 506.2, r: 357.2
; shifting image 0 by 10.4, 7.4
; shifting image 1 by -15.0, 5.3

; GOOD
; basename = '20210725.225657.ucomp.1083.continuum_subtraction.7.fts'
; radius_guess = 350.0
; display_min = 310.0
; dradius = 20.0
; camera: 0, x: 623.4, y: 504.3, r: 356.2
; camera: 1, x: 658.1, y: 502.1, r: 357.7
; shifting image 0 by 16.1, 7.2
; shifting image 1 by -18.6, 9.4

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'unit', config_filename, /no_log)

filename = filepath(basename, $
                    subdir=[date, 'level1'], $
                    root=run->config('processing/basedir'))

fits_open, filename, fcb
fits_read, fcb, data, primary_header, exten_no=0
fits_read, fcb, rcam_data, header, exten_no=4
fits_read, fcb, tcam_data, header, exten_no=11
fits_close, fcb

date_obs = ucomp_getpar(primary_header, 'DATE-OBS')

occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')
occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
print, occulter_id, occulter_x, occulter_y, $
       format='(%"occulter: %s, occulter-x: %0.2f, occulter-y: %0.2f")'

wave_region = ucomp_getpar(primary_header, 'FILTER')

; occulter-x: 61.60, occulter-y: -28.31
if (occulter_id eq 'NONE') then occulter_id = '28'
arcsec = run->epoch('OC-' + occulter_id + '-arcsec', datetime='20190101')
mm = run->epoch('OC-' + occulter_id + '-mm', datetime='20190101')

plate_scale = run->line(wave_region, 'plate_scale')
radius_guess = arcsec / plate_scale
print, radius_guess, plate_scale, format='radius guess: %0.2f, plate scale: %0.2f'

for c = 0, 1 do begin
  offband_data = c eq 0 ? tcam_data : rcam_data
  onband_data = c eq 0 ? rcam_data : tcam_data
  im = total(offband_data[*, *, *, c], 3)
  camera_center_guess = ucomp_occulter_guess(c, date, occulter_x, occulter_y, run=run)
  geometry = ucomp_find_occulter(im, $
                                 center_guess=camera_center_guess, $
                                 radius_guess=radius_guess, $
                                 dradius=dradius, $
                                 points=points)

  mg_image, bytscl(im, -0.1, display_max), /new, title=string(c, format='Offband Camera %d')
  plots, points[0, *], points[1, *], /device, color='0000ff'x, thick=1.0, linestyle=2
  t = findgen(360) * !dtor
  x = geometry[2] * cos(t) + geometry[0]
  y = geometry[2] * sin(t) + geometry[1]
  plots, x, y, /device, color='ffff00'x, thick=2.0, linestyle=3

  xmin = (radius_guess - dradius) * cos(t) + camera_center_guess[0]
  ymin = (radius_guess - dradius) * sin(t) + camera_center_guess[1]
  plots, xmin, ymin, /device, color='00ffff'x, linestyle=3

  xmax = (radius_guess + dradius) * cos(t) + camera_center_guess[0]
  ymax = (radius_guess + dradius) * sin(t) + camera_center_guess[1]
  plots, xmax, ymax, /device, color='00ffff'x, linestyle=3

  plots, camera_center_guess[0], camera_center_guess[1], color='00ffff'x, psym=1
  plots, geometry[0], geometry[1], color='ffff00'x, psym=1

  print, c, geometry, format='camera: %d, x: %0.1f, y: %0.1f, r: %0.1f'

  print, c, [geometry[0], geometry[1]] - camera_center_guess, $
         geometry[2] - radius_guess, $
         format='Error in camera %d: x: %0.2f, y: %0.2f, r: %0.2f'

  ; im = total(onband_data[*, *, *, c], 3)
  ; mg_image, bytscl(im, -0.1, display_max), /new, title=string(c, format='Onband Camera %d')
endfor

offband_im0 = total(tcam_data[*, *, *, 0], 3)
onband_im0 = total(rcam_data[*, *, *, 0], 3)
offband_im1 = total(rcam_data[*, *, *, 1], 3)
onband_im1 = total(tcam_data[*, *, *, 1], 3)
dims = size(offband_im0, /dimensions)
camera_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
geometry0 = ucomp_find_occulter(offband_im0, $
                                center_guess=camera_center_guess, $
                                radius_guess=radius_guess, $
                                dradius=dradius)
camera_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)
geometry1 = ucomp_find_occulter(offband_im1, $
                                center_guess=camera_center_guess, $
                                radius_guess=radius_guess, $
                                dradius=dradius)
print, (dims[0] - 1.0) / 2.0 - geometry0[0], $
       (dims[1] - 1.0) / 2.0 - geometry0[1], $
       format='shifting image 0 by %0.1f, %0.1f'
im0 = ucomp_fshift(onband_im0, $
                   (dims[0] - 1.0) / 2.0 - geometry0[0], $
                   (dims[1] - 1.0) / 2.0 - geometry0[1], $
                   interp=2)
print, (dims[0] - 1.0) / 2.0 - geometry1[0], $
       (dims[1] - 1.0) / 2.0 - geometry1[1], $
       format='shifting image 1 by %0.1f, %0.1f'
im1 = ucomp_fshift(onband_im1, $
                   (dims[0] - 1.0) / 2.0 - geometry1[0], $
                   (dims[1] - 1.0) / 2.0 - geometry1[1], $
                   interp=2)
im0 = reverse(reverse(im0, 1), 2)
im1 = reverse(im1, 2)
im = (im0 + im1) / 2.0

loadct, 0, /silent
gamma_ct, 0.7
; mg_image, bytscl(im, -0.1, display_max), /new, title='Combined'

obj_destroy, run

end

; "Correct" x-offsets: OCCLTR_X, cam0_xoffset, cam1_xoffset
; 61.40, 10.45, -5.930
; 61.85, -19.04, 23.78
; 61.90, -20.08, 24.54

; cam0_xoffset = 3868.13 - 62.8305 * occulter_x
; cam1_xoffset = -3871.04 + 62.9518 * occulter_x

; "Correct" y-offsets: OCCLTR_Y, cam0_yoffset, cam1_yoffset
; 11.40, 0.13, 1.20
; 11.70, -0.67, -0.42
; 13.00, -9.80, -9.48

; cam0_yoffset = 74.1794 - 6.45092 * occulter_y
; cam1_yoffset = 78.4830 - 6.76313 * occulter_y
