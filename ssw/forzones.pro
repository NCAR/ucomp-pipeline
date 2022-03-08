;+
; NAME:
;	FORZONES
; PURPOSE:
;	Generate arrays showing "forbidden zones" of HXA pixels, i.e.
;	those that are masked by the fiducial grids.
; CALLING SEQUENCE:
;	forzones,x_add,y_add
; WARNING:
;	The zones may change with time! This is preliminary, be careful!
; HISTORY:
;	Written by Hugh Hudson, Jan. 27, 1992
;       All forzones extended by 6 units on their lower ends,
;       and 3 units on their upper ends. JPW, Sep. 92
;	14-Jun-93 (MDM) - Added 0 and 2047 as forbidden zones since the
;			  raw HXA value will be forced to be between 0
;			  and 2047 and if they are out of that range,
;			  then they should be forbidden.
;-
pro forzones,x_add,y_add
x_arr = [0,0, 202,246, 408,451, 613,655, 819,860, 1025,1066, 1229,1271,$
  1433,1477, 1637,1683, 2047,2047]
y_arr = [0,0, 164,212, 372,415, 578,619, 783,825, 989,1030, 1193,1238, $ 
  1401,1441, 1604,1649, 2047,2047]
x_add = intarr(2048)
y_add = intarr(2048)
for i = 0,9 do begin
  for ii = x_arr(2*i),x_arr(2*i+1) do x_add(ii) = 1
  for ii = y_arr(2*i),y_arr(2*i+1) do y_add(ii) = 1
endfor
end

