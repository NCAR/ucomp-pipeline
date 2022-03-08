	PRO Ex2Int, time, msod, ds79
;							17-mar-92
;+
;  Name:
;	Ex2Int
;  Purpose:
;	Convert conventional date and time into days since 1979 
;	and milliseconds of day.
;  Calling Sequence:
;	Ex2Int, time, msod, ds79
;  Inputs:
;	time= 7 element integer array containing, in order,
;		hr min sec msec day mon yr
;  Output:
;	msod= 4-byte integer: milliseconds of the day
;	ds79= 2-byte integer: number of days since 1-Jan-1979
;  Side Effects:
;	
;  Restrictions:
;	None
;  History:
;	version 1.0, was adopted from Ex2Int.FOR (SMM software), 
;	written by GAL, 15-Feb-1991 
;	8-oct-91, Updated, JRL: Make output vectors 1-d if the input
;				time is 2-d, or a scalar if the input
;				time is 1-d.
;	17-mar-92, Modified, JRL: Made for loop index long type.
;	Modified to use all vector operations, ras, 93/6/7
;       Modified to correctly deal with years GE 2000, jmm, 7/28/94
;-
;	-------------------------------------------------------------
	ON_ERROR, 2		;return to caller if an error occurs	
	if n_params() eq 0 then begin
	  print,'ex2int, time, msod, ds79	; time =[h,m,s,ms,d,m,y]'
	  return
	endif


	s_info = SIZE(time)	;check input dimensions
	CASE 1 OF 
	 (s_info(0) EQ 1): ndattimes = 1		;single time entry
	 (s_info(0) EQ 2): ndattimes = s_info(s_info(0));2d array of times
	 ELSE:	BEGIN
		  Print, 'Error-- illegal array dimension on input times'
		  Print, 'Return from Ex2Int, with array dimension error'
		  Return
		END
	ENDCASE

;	Find seconds and milliseconds of day
	secs = LONG(time(0,*))*LONG(3600) + LONG(time(1,*)*60) + LONG(time(2,*))
	msod = secs*LONG(1000) + LONG(time(3,*))

;	Find day number from 1-1-1979 epoch.
;	VALID FROM 1950-2049
	year = [indgen(50)+2000, indgen(50)+1950]

	yy = year( time(6, *) MOD 100 ) ;Jmm, 28-jul-94 for years 2000 and beyond (i.e., time(6,*) gt 100 ) correctly...
        
	jdcnv, 	yy, fix(time(5,*)), fix(time(4,*)), 0.0, jd
	ds79 = long(jd - 2443874.5d)+1 ;

	msod = msod(0:*)		; Collapse to 1-d vector
	ds79 = ds79(0:*)		; Collapse to 1-d vector

	if n_elements(msod) eq 1 then begin
	  msod = msod(0)
	  ds79 = ds79(0)
	endif

	RETURN
	END

