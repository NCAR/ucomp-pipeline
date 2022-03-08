pro attcmd_funct1, xx, m, out, pder
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
    pder(*,0) = sin((xx+m(1))*!pi*2)
    pder(*,1) = m(0)*cos((xx+m(1))*!pi*2) * (!pi*2)
    pder(*,2) = 1.
endif

out = m(0)*sin((xx+m(1))*!pi*2) + m(2)
end

