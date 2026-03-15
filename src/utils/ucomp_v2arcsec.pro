; docformat = 'rst'

;+
; Convert voltage to arcsec for `SGSRAV` and `SGSDECV`.
;
; :Returns:
;   float [arcsec]
;
; :Params:
;   voltage : in, required, type=float
;     voltage [V] in `SGSRAV` and `SGSDECV`
;   dimv : in, required, type=float
;     `SGSDIMV` value [V]
;   r_sun : in, required, type=float
;     radius of the sun [arcsec]
;-
function ucomp_v2arcsec, voltage, dimv, r_sun
  compile_opt strictarr

  return, voltage / dimv * (!pi * r_sun / 4.0)
end


; main-level example program

; For 20240409.180748.30.ucomp.1074.l0.fts:
;
; DATE-BEG= '2024-04-09T18:07:48.30' / Date time of the beginning of data for this
; SGSDIMV =              8.22400 / [V] SGS Dim Mean
; SGSRAV  =              0.00020 / [V] SGS RA Mean
; SGSDECV =             -0.00070 / [V] SGS DEC Mean
; SGSRAZR =            -21.40000 / [arcsec] SGS RA zero point
; SGSDECZR=             50.50000 / [arcsec] SGS DEC zero point

dt = '2024-04-09T18:07:48.30'
dimv = 8.22400
rav = 0.00020
decv = -0.00070

tokens = long(strsplit(dt, '-T:.', /extract))
hours = (tokens[3] + (tokens[4] + tokens[5] / 60.0) / 60.0) / 24.0

sun, tokens[0], tokens[1], tokens[2], hours, sd=r_sun

print, ucomp_v2arcsec(rav, dimv, r_sun)
print, ucomp_v2arcsec(decv, dimv, r_sun)

end
