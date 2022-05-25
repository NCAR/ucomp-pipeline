function togmst,jd
 
;  togmst - subroutine to calculate the greenwich mean sidereal time from
;  a given julian date. (both double precision)
;  sidereal time is in units of hours/24.
 
;  get time since the epoch (jan 0.5 1900ad)
 
jd2=double(fix(jd) +0.5d0)
ii=where(jd2 gt jd,count)
if count gt 0 then jd2(ii)=jd2(ii)-1.d0
tcen=(jd2-2415020.d0)/36525.d0
 
;  get sidereal time at greenwich
 
st=0.276919398d0+100.0021359D0*tcen+0.000001075d0*tcen*tcen
 
;  add on st difference for ut
 
ut=jd -jd2
ii=where(ut lt 0.d0,count)
if count gt 0 then ut(ii)=ut(ii)+1.d0
st=st +1.0027379093D0*ut
 
;  put in proper interval
 
st=st mod 1.0D0
ii=where(st lt 0.d0,count)
if count gt 0 then st(ii)=st(ii)+1.d0
 
return,st
end
