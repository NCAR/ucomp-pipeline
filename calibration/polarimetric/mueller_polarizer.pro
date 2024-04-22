function mueller_polarizer,trans,angle
;+
;  Procedure to calculate the mueller matrix of a polarizer given its
;  transmission and orientation angle (degrees).
;  The convention is that the angle is measured positive counterclockwise
;  from the vertical when looking at the source.
;-
ang=angle*!dpi/180.d0  ;convert to radians
c2=cos(2.d0*ang) & s2=sin(2.d0*ang)

matrix = trans*[[1.d0,c2,s2,0.d0],$
             [c2,c2^2,c2*s2,0.d0],$
             [s2,s2*c2,s2^2,0.d0],$
             [0.d0,0.d0,0.d0,0.d0]]

return,matrix
end
