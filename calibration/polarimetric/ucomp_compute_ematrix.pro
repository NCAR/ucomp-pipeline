;+
;  Name: UCoMP_Compute_Ematrix
;
;  Description:
;    Procedure to compute the E matrix from the Calibration matrix (C matrix).
;
;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Inputs:
;    Cmatrix - calibration matrix (ncal columns x 4 rows) comprised of the m Stokes vectors produced
;    by the calibration optics where ncal is the number of calibration states
;
;  Outputs:
;    Ematrix - E matrix (4 columns x ncal rows) is the nominal inverse of C as described by deWijn
;
;  Keywords:
;    cal_eff - calibration efficiency (optional, m vector), if present this routine will return
;              the calibration efficiency
;
;  Examples:
;    UCoMP_Compute_Ematrix,Cmatrix,Ematrix
;    UCoMP_Compute_Ematrix,Cmatrix,Ematrix,cal_eff=cal_eff
;
;  Author: S. Tomczyk
;
;  Modification History:
;
;-
pro UCoMP_Compute_Ematrix,Cmatrix,Ematrix,cal_eff=cal_eff

Bmatrix = Cmatrix##transpose(Cmatrix)

B_invert = invert(Bmatrix,status,/double)
;if status ne 0 then print,'inverse failed'

Ematrix = transpose(Cmatrix)##B_invert

if arg_present(cal_eff) then begin
  s = size(Bmatrix)
  n = s[1]
  cal_eff = dblarr(n)
  for i=0,s[1]-1 do cal_eff[i] = 1./sqrt(n*B_invert[i,i])
endif

end
