	PRO Int2Ex, msod, ds79, time, error=error
;							16-Nov-92
;+
;  Name:
;	Int2Ex
;  Purpose:
;	Convert days since 1979 and milliseconds of day into 
;	conventional date and time.
;  Calling Sequence:
;	Int2Ex, msod, ds79, time
;  Inputs:
;	msod= 4-byte integer: milliseconds of the day
;	ds79= 2-byte integer: number of days since 1-Jan-1979
;  Output:
;	time= 7 element integer array containing, in order,
;		hr min sec msec day mon yr
;	error - set on error in arguments
;  Side Effects:
;	Results are always in the form of a 2-dimensional array,
;	even if input is scalar.
;  Restrictions:
;	None
;  History:
;	version 1.0, was adopted from Int2Ex.FOR (SMM software), 
;	written by GAL, 15-Feb-1991 
;       16-nov-92, Modified, JRL:  Made loop variable I*4 for the case of
;				   a large input variable.
;	31-oct-93, ras, eliminated loop for yr,month,day by using jdcnv
;	16-nov-93, ras, added error keyword
;-
;	-------------------------------------------------------------
	ON_ERROR, 2		;return to caller if an error occurs	

	error = 0
	sav_msod = msod	;MDM added 26-Aug-91 (it was changing data type)
	sav_ds79 = ds79

	s_info_m = SIZE(msod)
	s_info_d = SIZE(ds79)
	IF (s_info_m(0) ne s_info_d(0)) THEN BEGIN
	  Print, 'Incompatible array dimensions on input parameters'
	  Print, 'Error-return from Int2Ex'
	  error=1 						;ras, 93/11/16
	  RETURN
	ENDIF

	ndim = s_info_m(0)	;number of dimensions

	CASE 1 OF
	  (ndim EQ 0):	BEGIN	;input is scalar
			  a = msod
			  msod = LONARR(1,1)
			  msod(0,0) = a
			  a = ds79
			  ds79 = INTARR(1,1)
			  ds79(0,0) = a 
			  nele = 1
			END
	  (ndim EQ 1):  BEGIN	;input is a column vector
			  nele = s_info_m(1)
			  msod = REFORM(msod, 1, nele)
			  ds79 = REFORM(ds79, 1, nele)
			END
	  (ndim EQ 2):	BEGIN	;input is a array
			  nele = s_info_m(2)
			END
	  ELSE	:	BEGIN
			  Print, 'Error illegal array dimensions'
			  print, 'Errror- return from Int2Ex'
			  error = 1				;ras, 93/11/16
			  RETURN
			END
	ENDCASE
	
 	time = Intarr(7,nele)	;create array for time and date
        jd= ds79-1 + 2443874.5d0 ;convert days from 79/1/1 to Julian date

	daycnv, jd, yr, month, dom

;	Convert milliseconds of data (sod) to hr, min, sec, msec
        secs = msod/LONG(1000)	;total number of seconds
	mins = FIX(secs/60)
	time(0,0) = mins/60				;hrs
	time(1,0) = mins - time(0,*)*60     		;mins
	time(2,0) = FIX(secs - LONG(mins)*LONG(60))	;sec
	time(3,0) = msod - secs*LONG(1000)		;msec
        time(4,0) = dom					;day of month
	time(5,0) = month
	time(6,0) = yr mod 100

	msod = sav_msod
	ds79 = sav_ds79

        RETURN
	END	
