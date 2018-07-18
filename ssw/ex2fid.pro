function ex2fid, tarr, sec=sec
;
;+
;NAME:
;	ex2fid
;PURPOSE:
;	Given a 7-element time array, generate the fileID (YYMMDD.HHMM)
;	for that time.
;CALLING SEQUENCE:
;	fid = ex2fid(tarr)
;	fid = ex2fid(tarr, /sec)
;INPUT:
;	tarr
;OPTIONAL INPUT:
;	sec	- If present, return (YYMMDD.HHMMSS)
;HISTORY:
;	Written 11-Dec-91 by M.Morrison
;	14-Oct-92 (MDM) - Modified to accept an array of times
;	04-Jan-2000 (GLS) - Call time2file for y2k compliance
;-
;

retval=time2file(tarr,delim='.',second=sec,/year2digit)
return,retval

end

