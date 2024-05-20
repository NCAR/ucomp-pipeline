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

    ; internal fudicial angle marks on Rsun
    x = rsun * cos(fudicial_angles * !dtor) + center[0]
    y = rsun * sin(fudicial_angles * !dtor) + center[1]
    plots, x, y, /device, color=color, psym=fudicial_psym, symsize=fudicial_symsize
  endif
end
