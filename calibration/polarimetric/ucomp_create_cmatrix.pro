;+
;  Name: UCoMP_Create_Cmatrix
;
;  Description:
;    Procedure to create the Calibration matrix (Cmatrix) comprised of the set of Stokes vectors
;    output by the calibration optics at a single wavelength. The Mueller matrices of the calibration
;    optics are given by an ideal waveplate behind an ideal polarizer. Note that idl stores arrays
;    by [column,row].
;
;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Inputs:
;    Sc - the Stokes vector input into the calibration optics (4 vector)
;    delta - the retardation of the cal retarder (deg)
;    cal_trans - calibration optics transmission
;    pol_angle - array of the polarizer angles (deg)
;    ret_angle - array of the retarder angles (deg)
;    cal_inout - array to tell if cal optics are in or out of the beam ('in' or 'out')
;
;  Outputs:
;    Cmatrix - calibration matrix (ncal columns x 4 rows) comprised of the m Stokes vectors produced
;    by the calibration optics where ncal is the number of calibration states
;
;  Examples:
;    UCoMP_Create_Cmatrix,Sc,delta,trans_pol,pol_angle,ret_angle,cal_inout,Cmatrix
;
;  Author: S. Tomczyk
;
;  Modification History:
;-
pro UCoMP_Create_Cmatrix,Sc,delta,cal_trans,pol_angle,ret_angle,cal_inout,Cmatrix

debug = 'no'     ;debug mode ('yes' or 'no')

ncal = n_elements(pol_angle)                           ;number of modulation states
Cmatrix = dblarr(ncal,4)                               ;array to hold Calibration matrix

for i=0,ncal-1 do begin
  if cal_inout[i] eq 'in' or cal_inout[i] eq 'mid' then $
    Cmatrix[i,*] = cal_trans*mueller_retarder(1.0,ret_angle[i],delta)##mueller_polarizer(1.0,pol_angle[i])##Sc else $
    Cmatrix[i,*] = Sc
endfor

if debug eq 'yes' then for i=0,3 do print,format='(6f10.6)',Cmatrix[*,i]

end
