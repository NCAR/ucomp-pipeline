; docformat = 'rst'

;+
; Display a grid on a UCoMP image.
;
; :Params:
;   rsun : in, required, type=float
;     radius of sun [pixels]
;   field_radius : in, required, type=float
;     field radius [pixels]
;   center : in, required, type=fltarr(2)
;     center of image [pixels]
;
; :Keywords:
;   color : in, optional, type=long
;     color of annotations
;-
pro ucomp_grid, rsun, field_radius, center, color=color
  compile_opt strictarr

  minor_increment    = 5   ; degrees
  minor_psym         = 3   ; degrees
  minor_symsize      = 1.0 ; normalized

  major_increment    = 10  ; degrees
  major_length       = 4   ; pixels
  major_thickness    = 1.0 ; pixels
  major_psym         = 8   ; degrees
  major_symsize      = 0.5 ; normalized

  fudicial_increment = 30  ; degrees
  fudicial_length    = 9   ; pixels
  fudicial_thick     = 1.5 ; pixels
  fudicial_psym      = 8   ; degrees
  fudicial_symsize   = 1.0 ; normalized

  minor_angles = minor_increment * findgen(360 / minor_increment)
  major_angles = major_increment * findgen(360 / major_increment)
  fudicial_angles = fudicial_increment * findgen(360 / fudicial_increment)

  usersym, [-1.0, 1.0, 1.0, -1.0, -1.0], $
           [1.0, 1.0, -1.0, -1.0, 1.0], $
           /fill

  if (n_elements(rsun) gt 0L) then begin
    ; internal minor angle marks on Rsun
    x = rsun * cos(minor_angles * !dtor) + center[0]
    y = rsun * sin(minor_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=minor_psym, symsize=minor_symsize

    ; internal major angle marks on Rsun
    x = rsun * cos(major_angles * !dtor) + center[0]
    y = rsun * sin(major_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=major_psym, symsize=major_symsize
    ; x_inner = (rsun - major_length) * cos(major_angles * !dtor) + center[0]
    ; y_inner = (rsun - major_length) * sin(major_angles * !dtor) + center[1]
    ; x_outer = rsun * cos(major_angles * !dtor) + center[0]
    ; y_outer = rsun * sin(major_angles * !dtor) + center[1]
    ; for a = 0L, n_elements(major_angles) - 1L do begin
    ;   plots, [x_inner[a], x_outer[a]], [y_inner[a], y_outer[a]], $
    ;          /device, color=color, thick=major_thickness
    ; endfor

    ; internal fudicial angle marks on Rsun
    x = rsun * cos(fudicial_angles * !dtor) + center[0]
    y = rsun * sin(fudicial_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=fudicial_psym, symsize=fudicial_symsize
    ; x_inner = (rsun - fudicial_length) * cos(fudicial_angles * !dtor) + center[0]
    ; y_inner = (rsun - fudicial_length) * sin(fudicial_angles * !dtor) + center[1]
    ; x_outer = rsun * cos(fudicial_angles * !dtor) + center[0]
    ; y_outer = rsun * sin(fudicial_angles * !dtor) + center[1]
    ; for a = 0L, n_elements(fudicial_angles) - 1L do begin
    ;   plots, [x_inner[a], x_outer[a]], [y_inner[a], y_outer[a]], $
    ;          /device, color=color, thick=fudicial_thick
    ; endfor
  endif

  if (n_elements(field_radius) gt 0L) then begin
    ; external minor angle marks on field radius
    x = field_radius * cos(minor_angles * !dtor) + center[0]
    y = field_radius * sin(minor_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=3

    ; external major angle marks on Rsun
    x = field_radius * cos(major_angles * !dtor) + center[0]
    y = field_radius * sin(major_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=major_psym, symsize=major_symsize
    ; x_inner = field_radius * cos(major_angles * !dtor) + center[0]
    ; y_inner = field_radius * sin(major_angles * !dtor) + center[1]
    ; x_outer = (field_radius + major_length) * cos(major_angles * !dtor) + center[0]
    ; y_outer = (field_radius + major_length) * sin(major_angles * !dtor) + center[1]
    ; for a = 0L, n_elements(major_angles) - 1L do begin
    ;   plots, [x_inner[a], x_outer[a]], [y_inner[a], y_outer[a]], $
    ;          /device, color=color, thick=major_thickness
    ; endfor
  endif
end


; main-level program

date = '20221125'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

basename = '20221126.004426.ucomp.1074.l1.p3.intensity.gif'
processing_basedir = run->config('processing/basedir')
filename = filepath(basename, subdir=[date, 'level1'], root=processing_basedir)

read_gif, filename, im, r, g, b

device, decomposed=0
tvlct, r, g, b
mg_image, im, /new, title=basename

dims = size(im, /dimensions)
rsun = 325.37
field_radius = run->epoch('field_radius')
ucomp_grid, rsun, field_radius, (dims[0:1] - 1.0) / 2.0, color=250

obj_destroy, run

end
