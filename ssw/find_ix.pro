;+
; Project     : SDAC
;                   
; Name        : FIND_IX
;               
; Purpose     : This function finds the nearest neighbor index in the 
;		primary array for the values in the secondary array
;               
; Category    : UTIL
;               
; Explanation : This is a routine needed as the first step in all 1-d
;	interpolations on irregular grid positions.  This routine is
;	fast because it uses the sort and where functions to find
;	indices where alternate routines use loops or double loops.
;               
; Use         : 
;    
; Inputs      : X - The primary array, must be monotonic.
;               U   - The secondary array for which indices are needed for X.
; Opt. Inputs : None
;               
; Outputs     : The function returns the index, I,  in X for every value
;		of U corresponding the the element of X such that
;		X(I(j)) < U(j) < X(I(j)+1) for X increasing
;		and
;		X(I(j)) < U(j) < X(I(j)-1) for X decreasing.
;		Returns (top+1) or (bottom-1) of range of indices for U out of range.
;
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls	      :
;
; Common      : None
;               
; Restrictions: Supports real numbers.
;               
; Side effects: None.
;               
; Prev. Hist  :
;
; Modified    : RAS, 6-May-1997, Version 1, written to support INTERPOL.
;		RAS, 21-May-1997, Version 2, changed do loop to while loop
;		to support extremely large x arrays.  Could be rewritten
;		to put singles into final array w/o loop.  
;-            
;==============================================================================
function find_ix, x, u


m = n_elements(x)
limsx = minmax(x)
rev = limsx(0) eq x(m-1)

n = n_elements(u)
ix = lonarr(n)
wout = where( u lt limsx(0) or u gt limsx(1), nout)
if nout gt 0 then ix(wout) = ([-1,m])(  (u(wout) ge limsx(1)) xor rev)

if nout ge 1 then n = n - nout
if n eq 0 then return, ix

wu = where(ix eq 0)

if rev then x=temporary( reverse(x))

sr =  bsort(temporary( [x(*), u(wu)]))
w = where( sr ge m)
w1 = [-1, w, n+m+1]
dw=w1(1:*)-w1
wdiff = where( dw ne 1, nwdiff)
wstart = w( wdiff(0:nwdiff-2))
nw = wdiff(1:*)-wdiff

iput = 0
i = 0l
while i le (nwdiff-2)  do begin
	ix(wu(iput:iput+nw(i)-1)) = sr(wstart(i)-1)
	iput = iput + nw(i)
	i = i + 1
	endwhile
	

sr2=sr(where(sr ge (m)))-(m)
;
; Finally load the elements of ix in the order of the input array u
; according to the sorted indices in SR.  SR2 are just those elements
; pointing to the array U where SR2 is extracted from SR by noting
; that the elements pointing to U must have values greater than or equal
; to M.
;
ixx = ix
ixx(wu(sr2)) = ix(wu)
ix = ixx	
	

if rev then begin
	ix = m-1-ix
	x=temporary( reverse(x))
	endif	

return, ix
end
