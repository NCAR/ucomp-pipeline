
;+
; NAME:
;        GET_SUNCENTER
; PURPOSE:
;        Calculate the suncenter position (in SXT pixel coordinates) from
;        the HXA and IRU info in the PNT files.
;        Data reflects the spacecraft jitter.  Useful to de-jitter SXT images.
; CATEGORY:
; CALLING SEQUENCE:
;        sunc = get_suncenter(pnt)
;        sunc = get_suncenter(index=index)
; NOTE:
;        Most applications will not need to use any keyword parameters except
;        INDEX.
; INPUTS:
;        pnt = pnt structure.  Optional if index keyword supplied.  In that
;              case, the pnt file is read automatically.
; KEYWORDS (INPUT):
;        index = sxt index structure.  If supplied, the suncenter position is
;                calculated only for the times given in the index structure.
;                In addition, the suncenter coordinates for the optical images
;                are corrected for the appropriate filter offsets.
;        /nofilt = do not test and correct for offsets of optical filters.
;                  Useful if INDEX is not a SXT index or roadmap structure.
;        /noorbit = do not correct for orbital variations of the offset
;                   between HXT and SXT.  (fem file not read in this case.)
;        /nosecular = do not correct for secular variation of the offset
;                     between HXT and SXT.
;        fem = fem orbital data structure.  Optional, fem file read
;              automatically if not supplied.
;        sxt_xyt = float(4,*). Reference pixel offsets in sxt pixel units.
;                  Will be used in place of HXA, if supplied.
;                  Same format as SUNC
; OUTPUTS:
;        sunc = suncenter coordinates in SXT full resolution pixels.
;               sunc(0,*) = x, sunc(1,*) = y, sunc(2,*) = pnt.time,
;               sunc(3,*) = pnt.day
; KEYWORDS (OUTPUT):
;        code = vector.  Indicates the reliability of each sun center position.
;               0 : error, no result, 1: result may be poor, no IRU correction,
;               2 : IRU jitter correction done (= normal result).
;        delta = vector.  Time difference (in s) between index time and pnt
;                time for each sun center position.  A value larger than a few
;                seconds indicates that the suncenter position may not be
;                reliable.
;        hxa_out = float(4,*).  Returns all hxa data.  Same format as SUNC.
;                  Only works if sxt_xyt is NOT supplied.
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
; RESTRICTIONS:
;        The program reads all the pnt data at once, which may be a (memory)
;        problem for data that covers more than a week or two.
; PROCEDURE:
;        The HXA detectors provide absolute suncenter positions, but with a
;        relatively coarse resolution.  The gyros (IRU) have better resolution
;        but poor longterm stability.  The program fits the gyro data onto
;        the HXA data to obtain the absolute accuracy of the HXA, and the
;        high resolution of the gyros.  The gyros show a drift which can be
;        assumed to be linear for time intervals of up to about 10 minutes.
;        If the covered time period is longer, the program splits the data
;        into shorter intervals and performs a linear fit for each interval.
; MODIFICATION HISTORY:
;        JPW, Jan. 1993.  Evolved out of getcal_att and hxa_suncenter.
;        JPW, Apr. 1993.  Bug fix (def. of tchi)
;	 1-Jun-93 (MDM) - Modification to not crash when having trouble
;			  finding the proper time
;	 4-Jun-93 (MDM) - Similar modification to 1-Jun-93
;	 5-Jun-93 (MDM) - Expanded to use the commanded S/C pointing in the
;			  case that the HXA data is bad.
;        13-Jul-93 (JPW)  Added filter to weed out IRU glitches.
;	 28-Aug-93 (SLF)  Add quiet keyword
;        27-Sep-93 (JPW)  Replaced inline filter with call to iru_filt.
;        27-Sep-93 (JPW)  Added call to iru_s2y to correct for iru switch.
;-

function get_suncenter,pnt0,code=code,index=index, $
   noorbit=noorb,nosecular=nosec,nofilt=nofilt,fem=fem, $
   sxt_xyt=xyt,hxa_out=cxy,delta=delta, quiet=quiet

quiet=keyword_set(quiet)

; various constants
spix = 0.08/2.455      ; giro unit / sxt pixel size
naban_ox = -0.36
naban_oy = +1.47
wdban_ox = -0.36 + 0.6
wdban_oy = +1.47 - 0.2
tstep = 200000L        ; time step (in msec) used for recalc. linear IRU fit
msday = 24L*60L*60L*1000L
toldif = 2             ; tolerance for time difference (in seconds)
t_iru = 1000L          ; threshold for "bad" iru values

; read pnt file if necessary
ind_flg = n_elements(index)        ; flag if index supplied
if ind_flg gt 0 then begin         ; yes
   ivec = anytim2ints(index)
   n_iv = n_elements(ivec)
   sip0 = size(pnt0)
   if sip0(sip0(0)+1) ne 8 then rd_pnt,ivec(0),ivec(n_iv-1),pnt else pnt=pnt0
endif else begin                   ; no, use the whole pnt data set
   pnt = pnt0
   ivec = anytim2ints(pnt)
   n_iv = n_elements(ivec)
endelse

; filter out bad iru values (in-line code).  wwp only contains the good ones.
;n_pnt = n_elements(pnt)
;if n_pnt ge 3 then begin
;   d_iru0 = abs(pnt.iru(0)-smooth(pnt.iru(0),3))
;   d_iru1 = abs(pnt.iru(1)-smooth(pnt.iru(1),3))
;   wwp = where((d_iru0 lt t_iru) and (d_iru1 lt t_iru))
;endif else wwp = lindgen(n_pnt > 1)

; filter out bad iru values with iru_filt.  wwp only contains the good ones.
iru_tmp = pnt.iru
iru_filt,pnt,iru_tmp,w_good=wwp
pnt.iru = iru_tmp

; correct for iru switch after 20-sep-93
pnt.iru = iru_s2y(pnt,pnt.iru)

pvec = anytim2ints(pnt)

wip = tim2dset(pvec(wwp),ivec,delta=delta)    ; pointers to pnt data for
wip = wwp(wip)                                ; each index
if max(abs(delta)) gt toldif and 1-keyword_set(quiet) then begin
   print,'Warning: PNT data does not fully match index. '
   print,'         Max. time difference:',max(abs(delta)),' s. '
   print,'Check the DELTA output keyword for the data points affected.'
endif

out = fltarr(4,n_iv)                     ; output variable
out(2,*) = gt_time(pnt(wip))             ; output time
out(3,*) = gt_day(pnt(wip))              ; output day
code = intarr(n_iv)                      ; output data quality code

; calculate the reference point arrays used for the calibration of the giro's
if n_elements(xyt) eq 0 then begin            ; use hxa as reference

   cxy = hxa_suncenter(pnt(wwp), $
                       code=hcod,noorb=noorb,nosec=nosec,/nofilt,fem=fem)
   wcp = where(hcod gt 0)                ; pointers to reliable reference data
   ;if n_elements(wcp) lt 1 then begin
   if (wcp(0) eq -1) then begin		;MDM modification 4-Jun-93
      ;;print,'Error: No reliable HXA data.  Program terminated. '
      ;;return,0
      print, 'WARNING: No reliable HXA data.  Using Commanded S/C values'
      tbeep, 3
      wcp = where(hcod eq -1)
      if (wcp(0) eq -1) then begin
	 print, 'ERROR: No absolute pointing data available (HXA or commanded)
	 return, 0
      end
   endif
   cxy = cxy(*,wcp)                      ; reference suncenter positions
   wcp = wwp(wcp)            ; pointer to pnt(wwp) -> pointer to pnt

endif else begin             ; use supplied sxt pixel offsets as reference

   txyt = anytim2ints(xyt(2:3,*))
   wcp = tim2dset(pvec(wwp),txyt,delta=deltas) ; pointers to
   wcp = wwp(wcp)                              ; reference times in pnt
   if max(abs(deltas)) gt toldif and 1-keyword_set(quiet) then begin
      print,'Warning: PNT data does not fully match sxt_xyt. '
      print,'         Max. time difference:',max(abs(deltas)),' s. '
      print,'Continuing. '
   endif
   cxy = xyt

endelse

list = bytarr(n_iv)+1          ; list to check off data points
wlis = where(list)

repeat begin  ; loop through short time intervals for which gyros are linear

   ; search for the earliest time in the list
   wlo = wip(wlis)                  ; list elements in pnt
   ww = where(gt_day(pnt(wlo)) eq min(gt_day(pnt(wlo))))
   wlo = wlo(ww)                    ; first day elements of list in pnt
   ww = where(gt_time(pnt(wlo)) eq min(gt_time(pnt(wlo))))
   wlo = wlo(ww)                    ; earliest element(s) of list in pnt

   ; limits of data and reference time interval
   tilo = anytim2ints(pnt(wlo(0)))  ; earliest time = low end of data interval
   tihi = tilo                      ; high end of data interval
   tihi.time = (tilo.time + tstep) mod msday
   tihi.day = tilo.day + (tilo.time+tstep)/msday
   tclo = tilo                      ; high end of data interval
   tclo.time = tilo.time - tstep + ((tilo.time-tstep) lt 0L)*msday
   tclo.day = tilo.day - ((tilo.time-tstep) lt 0L)
   tchi = tihi                      ; high end of data interval
   tchi.time = (tihi.time + tstep) mod msday
   tchi.day = tihi.day + (tihi.time+tstep)/msday

   wwi = sel_timrange(pnt(wip(wlis)),tilo,tihi)
   wwi = wlis(wwi)
   list(wwi) = 0B                   ; cross off selected elements in list

   wwc = sel_timrange(pnt(wcp),tclo,tchi)

; for testing, wwi and wwc are just dummies.  Later they will point to the
; selected 10 minute time interval
;   wwi = lindgen(n_elements(wip))
;   wwc = lindgen(n_elements(wcp))

   nnn = n_elements(wwc)		;MDM added 1-Jun-93
   if (wwc(0) eq -1) then nnn = 0	;MDM added 1-Jun-93

   ;;case n_elements(wwc) of
   case nnn of				;MDM added 1-Jun-93

   0 : begin
      code(wwi) = 0
     end

   1 : begin
      code(wwi) = 1
      out(0,wwi) = cxy(0,wwc)
      out(1,wwi) = cxy(1,wwc)
     end

   else : begin

      ofxy = cxy(*,wwc(0))

      ; gyro data for index and reference points
      gix = pnt(wip(wwi)).iru(1)
      giy = pnt(wip(wwi)).iru(0)
      gcx = pnt(wcp(wwc)).iru(1)
      gcy = pnt(wcp(wwc)).iru(0)

      gix = float(gix-gcx(0)) * spix
      giy = float(giy-gcy(0)) * spix
      gcx = float(gcx-gcx(0)) * spix - (cxy(0,wwc)-ofxy(0))
      gcy = float(gcy-gcy(0)) * spix - (cxy(1,wwc)-ofxy(1))
      
      ; floating point time vectors for numerics
      tzero = pnt(wcp(wwc(0)))
      tti = gt_time(pnt(wip(wwi)))-gt_time(tzero) $
            + (gt_day(pnt(wip(wwi)))-gt_day(tzero))*msday
      tti = float(tti)
      ttc = gt_time(pnt(wcp(wwc)))-gt_time(tzero) $
            + (gt_day(pnt(wcp(wwc)))-gt_day(tzero))*msday
      ttc = float(ttc)

      ; linear fit through (hxa corrected) gyro values
      px = svdfit(ttc,gcx,2)
      py = svdfit(ttc,gcy,2)

      ; gyro corrected suncenter pos. for output times
      out(0,wwi) = gix - (px(0) + tti * px(1)) + ofxy(0)
      out(1,wwi) = giy - (py(0) + tti * py(1)) + ofxy(1)

      code(wwi) = 2

     end
   endcase

   wlis = where(list)
endrep until wlis(0) lt 0     ; loop until list empty

If min(code) eq 0 then begin
   print,'Warning!'
   print,'For some data points no valid suncenter position could be found.'
   print,'Check the CODE output keyword for the data points affected.'
endif

if ((ind_flg gt 0) and (not keyword_set(nofilt))) then begin
   whe = where(gt_filta(index) eq 2)   ; NaBan filter?
   if whe(0) ge 0 then begin
      out(0,whe) = out(0,whe) + naban_ox
      out(1,whe) = out(1,whe) + naban_oy
   endif
   whe = where(gt_filta(index) eq 5)   ; WdBan filter?
   if whe(0) ge 0 then begin
      out(0,whe) = out(0,whe) + wdban_ox
      out(1,whe) = out(1,whe) + wdban_oy
   endif
endif

return,out
end

