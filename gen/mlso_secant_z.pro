; docformat = 'rst'

;+
; Compute the secant Z.
;
; :Returns:
;   `float`/`fltarr`
;
; :Params:
;   sol_dec : in, required, type=float/fltarr
;   ha : in, required, type=float/fltarr
;-
function mlso_secant_z, sol_dec, ha
  compile_opt strictarr

  mlso_lat = 19.5362D
  secz = 1.0D / (sin(mlso_lat) * sin(sol_dec) + cos(mlso_lat) * cos(sol_dec) * cos(ha))
end
