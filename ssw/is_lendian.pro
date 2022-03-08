function is_lendian
;+
; NAME:
;    IS_LENDIAN.PRO
;
;
; PURPOSE:
;    Many routines (WRITEFITS, ANAFRD, etc) depend on the endianness
;    of the hardware platform.  This routine centralizes this in one
;    place so new platforms may be added at will.
;
;
; CALLING SEQUENCE:
;    little_endian_flag = is_endian()
;
; 
; INPUTS:
;    None.  is_endian checks !version.os for the platform.
;
;
; OUTPUTS:
;    little_endian_flag = 1     ; Machine is little endian
;                       = 0     ; Machine is big endian
;
;
; MODIFICATION HISTORY:
;    18-Jun-97 - (BNH) - Written (mostly from SLF)
;    
;    29-nov-2006 - S.L.Freeland - do this by calculation, not list
;                  for maintenance simplification and auto-extension
;                  Plagerized from $SSW_EIS/...little_endian.pro
;
;-

;
;  NOTE:  endianness is hardware-dependent, not software.  Hence,
;         Win95, WinNT and Linux should all be the same.  Similarly
;         anything running on an alpha would have the same endian,
;         and anything on a sun box would be the same, be it solaris,
;         sunos, etc.  SO...try to key off this alone.
;


lendlist = 'vax,alpha,mipsel,386i,386,x86,i386' ; list depracated in favor of calculation

; return, is_member(!VERSION.ARCH, str2arr(lendlist), /ignore_case) ; old way

return,(byte(1,0,1))[0]  ; courtesy 'little_endian.pro  Hansteen/Wikstol

end
