; docformat = 'rst'

;+
; Function to compute the demodulation matrix given the coefficient array and
; the modulator temperature.
;
; To apply the calibration, matrix multiply the 4-vector of modulated
; intensities by the returned D matrix, i.e., Stokes = Dmx ## I_measured.
;
; :Returns:
;   `fltarr(4, 4)` demodulation matrix
;
; :Params:
;   dmx_coefs : in, required, type="fltarr(4, 4, n_wave_regions, 2)"
;     array of D matrix coefficients obtained by restoring IDL save file
;     Dmx_Temp_Coefs.sav
;   mod_temp : in, required, type=float
;     modulator unfiltered temperature [C]
;-
function ucomp_get_dmatrix, dmx_coefs, mod_temp
  compile_opt strictarr

  return, dmx_coefs[*, *, 0] + mod_temp * dmx_coefs[*, *, 1]
end
