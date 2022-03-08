pro attcmd_funct2, xx, m, out, pder
;+
;NAME:
;	attcmd_funct
;PURPOSE:
;	Define the function describing the ATT-CMD pointing drift
;HISTORY:
;	Written 8-Mar-95 by M.Morrison
;-
;
if n_params() gt 2 then begin
    pder = fltarr(n_elements(xx), n_elements(m))
    pder(*,0) = xx*sin((xx+m(2))*!pi*2)
    pder(*,1) = sin((xx+m(2))*!pi*2)
    pder(*,2) = (m(0)*xx+m(1))*cos((xx+m(2))*!pi*2) * (!pi*2)
    pder(*,3) = xx
    pder(*,4) = 1.
endif

out = (m(0)*xx+m(1)) * sin((xx+m(2))*!pi*2) + m(3)*xx + m(4)
end

