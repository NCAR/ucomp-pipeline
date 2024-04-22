function mueller_retarder,trans,angle,delta,incidence=incidence
;+
;  Procedure to calculate the mueller matrix of a retarder given its
;  transmission, retardation (degrees) and orientation angle (degrees)
;  The convention is that the angle is measured positive counterclockwise
;  from the vertical when looking at the source. The matrix is transposed
;  from the conventional because idl arrays are stored [column,row]
;-
ang=angle*!dpi/180.d0  ;convert to radians
del=delta*!dpi/180.d0

if keyword_set(incidence) then del=del*(1.+(sin(incidence*!dpi/180.)^2)/5.)

c2=cos(2.d0*ang) & s2=sin(2.d0*ang)

matrix = transpose(trans*[[1.d0,0.d0,0.d0,0.d0],$
    [0.d0,c2^2+s2^2*cos(del),c2*s2*(1.-cos(del)),-s2*sin(del)],$
    [0.d0,c2*s2*(1.-cos(del)),s2^2+c2^2*cos(del),c2*sin(del)],$
    [0.d0,s2*sin(del),-c2*sin(del),cos(del)]])

return,matrix
end
