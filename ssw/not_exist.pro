;+
; Project     :	SDAC
;
; Name        :	NOT_EXIST
;
; Purpose     :	check if variable doesn't exist
;
; Explanation :	So obvious, that explaining it will take more
;               lines than the code.
;
; Use         :	A=NOT_EXIST(VAR)
;
; Inputs      :	VAR = variable name
;
; Opt. Inputs : None.
;
; Outputs     :	1 if variable doesn't exist
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Category    :	Useful stuff
;
; Written     :	6 October 2007, Zarro (ADNET)
;-

function not_exist,var

return,n_elements(var) eq 0

end

