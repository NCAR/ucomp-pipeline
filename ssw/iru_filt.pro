
;+
; NAME:
;        IRU_FILT
; PURPOSE:
;        Returns pointer to "good" IRU values, replaces bad values through
;        linear interpolation of neighbours, and takes care of "roll over"
;        of IRU values from (hex) FFFFFF to 0 (by adding 1000000 if required).
; CATEGORY:
; CALLING SEQUENCE:
;        iru_filt,iru_i,iru_d
; INPUTS:
;        iru_i = pnt, atr, or mk_timarr(ada_index,8,/struct)
;        iru_d = array(3,*). iru data. iru_d is returned with bad values fixed
;                IF THE PARAMETER IS A SIMPLE VARIABLE.
; KEYWORDS (INPUT):
; OUTPUTS:
;        iru_d   (see under inputs above)
; KEYWORDS (OUTPUT):
;        w_good = pointer vector to the originally "good" iru values.
;                 The fixed values are not included in w_good.
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;        detects IRU spikes by subtracting a nearest neighbourhood average.
; MODIFICATION HISTORY:
;        19-Jul-93 (JPW)  From get_suncenter.
;        27-sep-93 (JPW)  Do the filter for all 3 iru's (new: also for Z).
;-

pro iru_filt,iru_i,iru_d,w_good=wwp

t_iru = 2e3          ; threshold for "bad" iru values

n_i = n_elements(iru_i)

; detect the bad iru values.  interpolate the iru value, but only use good
;  values for the correlation with hxa: wwp points to the good ones
if n_i ge 3 then begin

   iru0 = reform(iru_d(0,*))
   iru1 = reform(iru_d(1,*))
   iru2 = reform(iru_d(2,*))

   ; take care of iru "roll over" from hex FFFFFF to 0
   wlo = where(iru0 ge 'C00000'XL)
   whi = where(iru0 lt '400000'XL)
   if (n_elements(wlo) gt 1 and n_elements(whi) gt 1) then begin
      ww = where(iru0 lt '800000'XL)
      iru0(ww) = iru0(ww) + '1000000'XL
   endif
   wlo = where(iru1 ge 'C00000'XL)
   whi = where(iru1 lt '400000'XL)
   if (n_elements(wlo) gt 1 and n_elements(whi) gt 1) then begin
      ww = where(iru1 lt '800000'XL)
      iru1(ww) = iru1(ww) + '1000000'XL
   endif
   wlo = where(iru2 ge 'C00000'XL)
   whi = where(iru2 lt '400000'XL)
   if (n_elements(wlo) gt 1 and n_elements(whi) gt 1) then begin
      ww = where(iru2 lt '800000'XL)
      iru2(ww) = iru2(ww) + '1000000'XL
   endif

   d_iru0 = float(iru0)
   d_iru1 = float(iru1)
   d_iru2 = float(iru2)

   d_iru0 = abs(d_iru0-median(d_iru0,3))
   d_iru1 = abs(d_iru1-median(d_iru1,3))
   d_iru2 = abs(d_iru2-median(d_iru2,3))

   ; replace bad iru_0 values
   ww1 = where(d_iru0 ge t_iru)
   if ww1(0) ge 0 then begin
      d_t1 = int2secarr(iru_i(ww1),iru_i(ww1-1))
      d_t2 = int2secarr(iru_i(ww1+1),iru_i(ww1-1))
      d_val = float(iru0(ww1+1)-iru0(ww1-1))
      ww = where(abs(d_t2) gt 0.1)
      if ww(0) ge 0 then $
        iru_d(0,ww1(ww)) = (iru0(ww1(ww)-1) + $
                           long(d_val(ww)*d_t1(ww)/d_t2(ww))) mod '1000000'XL
   endif

   ; replace bad iru_1 values
   ww1 = where(d_iru1 ge t_iru)
   if ww1(0) ge 0 then begin
      d_t1 = int2secarr(iru_i(ww1),iru_i(ww1-1))
      d_t2 = int2secarr(iru_i(ww1+1),iru_i(ww1-1))
      d_val = float(iru1(ww1+1)-iru1(ww1-1))
      ww = where(abs(d_t2) gt 0.1)
      if ww(0) ge 0 then $
        iru_d(1,ww1(ww)) = (iru1(ww1(ww)-1) +  $
                           long(d_val(ww)*d_t1(ww)/d_t2(ww))) mod '1000000'XL
   endif

   ; replace bad iru_2 values
   ww1 = where(d_iru2 ge t_iru)
   if ww1(0) ge 0 then begin
      d_t1 = int2secarr(iru_i(ww1),iru_i(ww1-1))
      d_t2 = int2secarr(iru_i(ww1+1),iru_i(ww1-1))
      d_val = float(iru2(ww1+1)-iru2(ww1-1))
      ww = where(abs(d_t2) gt 0.1)
      if ww(0) ge 0 then $
        iru_d(2,ww1(ww)) = (iru2(ww1(ww)-1) +  $
                           long(d_val(ww)*d_t1(ww)/d_t2(ww))) mod '1000000'XL
   endif

   ; pointer to good values.
   wwp = where((d_iru0 lt t_iru) and (d_iru1 lt t_iru) and (d_iru2 lt t_iru))
endif else wwp = lindgen(n_i > 1)

return

end
