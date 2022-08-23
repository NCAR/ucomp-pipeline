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
;   dmx_coefs : in, required, type="fltarr(4, 4, 9, 2)"
;     array of D matrix coefficients obtained by restoring IDL save file
;     Dmx_Temp_Coefs.sav
;   mod_temp : in, required, type=float
;     modulator unfiltered temperature [C]
;   wave_region_index : in, required, type=integer
;     index of wavelength region, i.e., 530=0, 637=1, ..., 1083=8
;-
function ucomp_get_dmatrix, dmx_coefs, mod_temp, wave_region_index
  compile_opt strictarr

  dmx = dmx_coefs[*, *, wave_region_index, 0] $
          + mod_temp * dmx_coefs[*, *, wave_region_index, 1]

  return, dmx
end