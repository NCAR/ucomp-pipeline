;+
;  Name: UCoMP_Fit_Pol_Cal
;
;  Description:
;    Procedure to fit the polarization calibration data to obtain the characteristics of the
;    calibration optics
;
;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Inputs: (input with common block fit)
;    Imeas - calibration observations [ncal columns x nmod rows] comprised of the nmod modulated intensities obtained
;            by observing the ncal calibration states
;    pol_angle - array of the polarizer angles (deg)
;    ret_angle - array of the retarder angles (deg)
;    cal_inout - array to tell if cal optics are in or out of the beam ('in' or 'out')
;    wave - the wavelength of the calibration (nm)
;
;  Output Fit Quantities:
;    Sc - the Stokes vector input into the calibration optics (4 vector) The I term is assumed to be
;      equal to 1, so the Q, U and V terms are fit
;    delta - the retardation of the cal retarder (deg)
;    cal_trans - calibration optics transmission
;    Dmatrix - demodulation matrix at the specified wavelength
;    ret_offset - the offset angle of the calibration retarder (deg)
;
;  Keywords:
;    none
;
;  Author: S. Tomczyk
;
;  Modification History:
;-
pro UCoMP_Fit_Pol_Cal,Sc,delta,cal_trans,ret_offset,Dmatrix

common pol_fit,Imeas,pol_angle,ret_angle,cal_inout,wave

;  create initial guess
;  0. for the Q, U, V terms of the input Stokes vector, 0.40 for the cal optics transmissio
;  and the retardation of the calibration retarder assuming no dispersion of birefringence

del_guess = 90.*750./wave      ;retardance (delta) of cal retarder (deg)
;guess = [0.,0.,0.,del_guess,0.43]     ;guess without retarder offset
guess = [0.,0.,0.,del_guess,0.4,0.]     ;guess with retarder offset

n_par = n_elements(guess)   ;number of parameters to fit
xi = fltarr(n_par,n_par)
for i=0,n_par-1 do xi[i,i] = 1.
ftol = 1.e-4
p = guess

powell,p,xi,ftol,fmin,'powfunc',itmax=2000

Sc = [1.,p[0],p[1],p[2]]
delta = p[3]
cal_trans = p[4]
if n_par eq 6 then ret_offset = p[5] else ret_offset = 0.

UCoMP_Calculate_Matrices,Sc,delta,cal_trans,pol_angle,ret_angle+ret_offset,cal_inout,Imeas,Dmatrix

end
