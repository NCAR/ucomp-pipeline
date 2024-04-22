;+
;  Name: UCoMP_Compute_Omatrix
;
;  Description:
;    Procedure to compute the Modulation matrix (O matrix) from the Calibration observations and the
;    E matrix.
;
;    Formulation is based on del Toro Iniesta & Collados, App. Opt. 39, 2000 and
;    the presentation by deWijn "The Concept of Optimal Calibration".
;    See UCoMP Calibration writeup for details and references
;
;  Inputs:
;    Imeas - calibration observations [ncal columns x nmod rows] comprised of the nmod modulated intensities obtained
;            by observing the ncal calibration states
;    Ematrix - the E matrix [4 columns x ncal rows] computed by the UCoMP_Compute_Ematrix routine.
;
;  Outputs:
;    Omatrix - the modulation matrix (4 columns x nmod rows)
;
;  Keywords:
;    none
;
;  Examples:
;    UCoMP_Compute_Omatrix,Imeas,Ematrix,Omatrix
;
;  Author: S. Tomczyk
;
;  Modification History:
;
;-
pro UCoMP_Compute_Omatrix,Imeas,Ematrix,Omatrix

Omatrix = Imeas##Ematrix

end
