;+
; Project     :	Multimission
;
; Name        :	TEST_SUNSPICE_DLM()
;
; Purpose     :	Test to see if the SPICE/Icy DLM is available
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Calls CSPICE_B1950 via EXECUTE to see if the SPICE/Icy DLM is
;               available.
;
; Syntax      :	Result = TEST_SUNSPICE_DLM()
;
; Examples    :	IF TEST_SUNSPICE_DLM() THEN ... ELSE ...
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is 1 if the DLM is available;
;               otherwise the result is 0.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 15-Sep-2005, William Thompson, GSFC
;               Version 2, 29-Sep-2005, William Thompson, GSFC
;                       Removed QuietExecution argument for pre-6.1 compliance
;               Version 3, 21-Apr-2016, William Thompson, GSFC
;                       Renamed TEST_SPICE_ICY_DLM to TEST_SUNSPICE_DLM
;
; Contact     :	WTHOMPSON
;-
;
function test_sunspice_dlm
return, execute('test = cspice_b1950()',1)
end
