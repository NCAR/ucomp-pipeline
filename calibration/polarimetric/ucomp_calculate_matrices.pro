;+
;  Name: UCoMP_Calculate_matrices
;
;  Description:
;    Procedure to compute UCoMP matrices used for calibration and return the demodulation matrix,
;    and optionally the other matrices and efficiencies
;
;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Inputs:
;    Sc - Stokes vector input to calibration optics [4]
;    delta - retardation of calibration retarder (deg)
;    cal_trans - transmission of calibration optics
;    pol_angle - array of the polarizer angles (deg) [ncal]
;    ret_angle - array of the retarder angles (deg) [ncal]
;    cal_inout - array to tell if cal optics are in or out of the beam ('in' or 'out') [ncal]
;    Imeas - calibration observations [ncal columns x nmod rows] comprised of the nmod modulated intensities
;      obtained by observing the ncal calibration states
;
;  Outputs:
;    Dmatrix - demodulation matrix [nmod columns x 4 rows] used to convert modulated intensities to Stokes
;      vector
;
;  Keywords:
;    Cmatrix - optionally returns Calibration matrix comprised of the ncal Stokes vectors produced
;      by the calibration optics [ncal,4]

;    Ematrix - optionally returns E matrix is the nominal inverse of C as described by deWijn [4 x ncal]
;    Omatrix - optionally returns the modulation matrix [4,nmod]
;    Dmatrix - optionally returns the demodulation matrix [nmod,4]
;    pol_eff - optionally returns the polarimetric efficiency [4]
;    cal_eff - optionally returns the calibration efficiency [nmod]
;
;    nmod - the number of modulation states
;    ncal - the number of calibration states
;
;  Note that calibration retarder has a nominal retardance of quarter-wave at 750 nm
;
;-
pro UCoMP_Calculate_Matrices,Sc,delta,cal_trans,pol_angle,ret_angle,cal_inout,Imeas,Dmatrix,$
  Cmatrix=Cmatrix,Ematrix=Ematrix,Omatrix=Omatrix,pol_eff=pol_eff,cal_eff=cal_eff

UCoMP_Create_Cmatrix,Sc,delta,cal_trans,pol_angle,ret_angle,cal_inout,Cmatrix   ;compute calibration matrix (Cmatrix)

UCoMP_Compute_Ematrix,Cmatrix,Ematrix,cal_eff=cal_eff   ;compute Ematrix from Cmatrix

UCoMP_Compute_Omatrix,Imeas,Ematrix,Omatrix   ;compute Omatrix from Ematrix and intensities

UCoMP_Compute_Dmatrix,Omatrix,Dmatrix,pol_eff=pol_eff   ;compute demodulation matrix (Dmatrix)

end
