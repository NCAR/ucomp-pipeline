;+
; Project     : HINODE/EIS
;
; Name        : GET_LEAP_SEC
;
; Purpose     : Returns the Modified Julian Day number of all known
;               leap seconds.  
;
; Inputs      : None
;
; Outputs     : MJD = An array containing the Modified Julian Day
;                     numbers for all dates on which a leap second 
;                     was inserted, starting with 31 December 1971.
;
; Keywords    : ERRMSG = string error message
;
; Version     : Written 15-Nov-2006, Zarro (ADNET/GSFC)
;               - based on original GET_LEAP_SEC by Bill Thompson.
;
; Contact     : dzarro@solar.stanford.edu
;-
	
PRO GET_LEAP_SEC, MJD, ERRMSG=ERRMSG

ERRMSG=''
COMMON LEAP_SECONDS2, LEAP_MJD

leap_days=[$
'41316   10      1971 Dec 31',$
'41498   11      1972 Jun 30',$
'41682   12      1972 Dec 31',$
'42047   13      1973 Dec 31',$
'42412   14      1974 Dec 31',$
'42777   15      1975 Dec 31',$
'43143   16      1976 Dec 31',$
'43508   17      1977 Dec 31',$
'43873   18      1978 Dec 31',$
'44238   19      1979 Dec 31',$
'44785   20      1981 Jun 30',$
'45150   21      1982 Jun 30',$
'45515   22      1983 Jun 30',$
'46246   23      1985 Jun 30',$
'47160   24      1987 Dec 31',$
'47891   25      1989 Dec 31',$
'48256   26      1990 Dec 31',$
'48803   27      1992 Jun 30',$
'49168   28      1993 Jun 30',$
'49533   29      1994 Jun 30',$
'50082   30      1995 Dec 31',$
'50629   31      1997 Jun 30',$
'51178   32      1998 Dec 31',$
'53735   33      2005 Dec 31',$
'54831   34      2008 Dec 31',$
'56108   35      2012 Jun 30',$
'57203   36      2015 Jun 30',$
'57753   37      2016 Dec 31']

if not exist(leap_mjd) then leap_mjd=long(stregex(leap_days,'([0-9]+ )',/ext))
mjd=leap_mjd

return
end
