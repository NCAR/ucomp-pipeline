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
pro ucomp_grid, rsun, field_radius, center, $
                color=color
  compile_opt strictarr

  minor_increment = 5   ; degrees
  major_increment = 10  ; degrees
  minor_angles = minor_increment * findgen(360 / minor_increment)
  major_angles = major_increment * findgen(360 / major_increment)

  usersym, [-1.0, 1.0, 1.0, -1.0, -1.0], $
           [1.0, 1.0, -1.0, -1.0, 1.0], $
           /fill

  if (n_elements(rsun) gt 0L) then begin
    ; internal minor angle marks on Rsun
    x = rsun * cos(minor_angles * !dtor) + center[0]
    y = rsun * sin(minor_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=3

    ; internal minor angle marks on Rsun
    x = rsun * cos(major_angles * !dtor) + center[0]
    y = rsun * sin(major_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=8, symsize=0.5
  endif

  if (n_elements(field_radius) gt 0L) then begin
    ; external minor angle marks on field radius
    x = field_radius * cos(minor_angles * !dtor) + center[0]
    y = field_radius * sin(minor_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=3

    ; external minor angle marks on field radius
    x = field_radius * cos(major_angles * !dtor) + center[0]
    y = field_radius * sin(major_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=8, symsize=0.5
  endif
end


; main-level program

date = '20240409'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

basename = '20240409.214658.ucomp.1074.l1.p5.intensity.gif'
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
