;+
;  Name: UCoMP_Compute_Dmatrix
;
;  Description:
;    Procedure to compute the demodulation matrix (D matrix) from the modulation matrix (O matrix)

;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Inputs:
;    Omatrix - modulation matrix [4 columns x nmod rows] that defines the encoding of Stokes vector into
;    modulated intensity states by the polarimeter, where nmod is the number of modulation states
;
;  Outputs:
;    Dmatrix - demodulation matrix [nmod columns x 4 rows] used to convert modulated intensities to Stokes
;    vector
;
;  Keywords:
;    pol_eff - polarimetric efficiency (optional, 4 vector), if present this routine will return the efficiency
;
;  Examples:
;    UCoMP_Compute_Dmatrix,Omatrix,Dmatrix
;    UCoMP_Compute_Dmatrix,Omatrix,Dmatrix,pol_eff=pol_eff
;
;  Author: S. Tomczyk
;
;  Modification History:
;
;-
pro UCoMP_Compute_Dmatrix,Omatrix,Dmatrix,pol_eff=pol_eff

debug = 'no'     ;debug mode ('yes' or 'no')

Amatrix = transpose(Omatrix)##Omatrix
if debug eq 'yes' then print,'Amatrix:'
if debug eq 'yes' then print,Amatrix

A_invert = invert(Amatrix,status,/double)
;if status ne 0 then print,'Status:',status

Dmatrix = A_invert##transpose(Omatrix)

if arg_present(pol_eff) then begin
  s = size(A_invert)
  n = s[1]
  pol_eff = dblarr(n)
  for i=0,n-1 do pol_eff[i] = 1./sqrt(n*A_invert[i,i])
endif

end
