;+
; PROJECT:
;	SDAC
; NAME:
;	SIGN
; PURPOSE:
;	This function takes two numbers X1,X2 and returns sign(X2)*abs(X1)
;	(by assumption sign(0)=1)
; CATEGORY:
;	NUMERICAL MATH UTILITY
; CALLING SEQUENCE:
;	A = SIGN(X1,X2)
; INPUTS:
;	X1	the absolute value of X1 is used
;	X2	the sign of X2 is used
; OUTPUTS:
;	SIGN	sign(X2)*abs(X1)
; EXAMPLES:
;       IDL> print, sign(3.5, -7)
;            -3.50000
;       IDL> print, sign(3.5, [-7, 5, 2])
;            -3.50000      3.50000      3.50000
;       IDL> print, sign([3.5, -2.7, 1.2], -12)
;            -3.50000     -2.70000     -1.20000
;       IDL> print, sign([3.5, -2.7, 1.2], [-7, 5, 2])
;            -3.50000      2.70000      1.20000
; PROCEDURE:
;	(Equivalent to FORTRAN SIGN function)
;	If X1 and X2 have the same number of elements the result is calculated
;	from corresponding elements in X1 and X2.  If either X1 or X2 is a
;	scalar, the magnitude is taken from X1, and the sign is taken from X2
;	for all elements.
; MODIFICATION HISTORY:
;	APR-1991, Paul Hick (ARC)
;       Version 2, 27-Oct-2016, William Thompson, allow either to be scalar
;-

function SIGN, X1,X2

on_error, 1				; On error return to main level
N1 = n_elements(X1)  
N2 = n_elements(X2)
if (N1 eq 0) or (N2 eq 0) then message, 'Both arguments must exist'
if (N1 ne N2) and (N1 ne 1) and (N2 ne 1) then message, 'Dimension error'

if (N1 eq N2) or (N2 eq 1) then OUT = abs(X1) else begin
    sz = size(X2)
    DIM = sz[1:sz[0]]
    OUT = make_array(dimension=DIM, value=abs(X1[0]))
endelse
W = where(X2 lt 0, COUNT)
if COUNT gt 0 then if N2 GT 1 then OUT[W] = -OUT[W] else OUT = -OUT
return, OUT  
end
