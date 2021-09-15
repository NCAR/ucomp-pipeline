function UCoMP_Get_Dmatrix,Dmx_coefs,mod_temp,region
;+
;    function to compute the demodulation matrix given the coefficient array and the modulator temperature
;  
;     Input: 
;         Dmx_coefs - array of D matrix coefficients obained by restoring idl save file Dmx_Temp_Coefs.sav
;         mod_temp - modulator unfiltered temperature (C)
;         region - wavelength region (string) '530.3', '637.4', '656.28', '691.8', '706.2', '789.4', '1074.7', '1079.8' or '1083.0'  
;       
;     Returned:
;         4 x 4 element demodulation matrix, Dmx
;       
;     To apply the calibration, matrix multiply the 4-vector of modulated intensities by the returned D matrix, i.e.  Stokes = Dmx##Imeas
;-
regs = [530.3,637.4,656.28,691.8,706.2,789.4,1074.7,1079.8,1083.0]
ind = where(regs eq region)

dmx = fltarr(4,4)
for i=0,3 do for j=0,3 do dmx[i,j] = Dmx_coefs[i,j,ind,0] + Dmx_coefs[i,j,ind,1]*mod_temp 

return,dmx
end