
;+
; NAME:
;        IRU_S2Y
; PURPOSE:
;        Reconstructs "raw" IRU-Y values by using a combination of IRU-X,
;        IRU-Z, and IRU-S.  This became necessary due to the IRU switch
;        from Y to S on September 20, 1993.  The program applies the
;        correction only to data after 20-sep-93, 4:20 UT.
; CATEGORY:
; CALLING SEQUENCE:
;        iru_xyz = iru_s2y(iru_i,iru_xsz)
; INPUTS:
;        iru_i = pnt, atr, or mk_timarr(ada_index,8,/struct)
;        iru_xsz = array(3,*). iru data, not corrected for iru switch.
; KEYWORDS (INPUT):
; OUTPUTS:
;        iru_xyz = array(3,*). iru data corrected.
; KEYWORDS (OUTPUT):
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;        27-sep-93 (JPW)
;	 27-jan-2000 (Mckenzie, GLS) - Y2K fix 
;-

function iru_s2y,iru_i,iru_xsz

iru_xyz = iru_xsz

ww = sel_timrange(iru_i, '16-sep-93 05:37:51', '16-sep-93 07:25:43', /between)
if (ww(0) ge 0) then iru_xyz(1,ww) = sqrt(3.0d)*iru_xsz(1,ww) - iru_xsz(0,ww) - iru_xsz(2,ww)

;ww = sel_timrange(iru_i, '20-sep-93 04:20', '30-dec-99', /between)
;if (ww(0) ge 0) then iru_xyz(1,ww) = sqrt(3.0d)*iru_xsz(1,ww) - iru_xsz(0,ww) - iru_xsz(2,ww)
ww = where(ssw_time_compare(iru_i, '20-sep-93 04:20', /later), wwcnt)	; Y2K Fix
if wwcnt gt 0 then iru_xyz(1,ww) = sqrt(3.0d)*iru_xsz(1,ww) - iru_xsz(0,ww) - iru_xsz(2,ww)

return,iru_xyz
end


