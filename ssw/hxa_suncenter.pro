
;+
; NAME:
;        HXA_SUNCENTER
; PURPOSE:
;        Calculate the suncenter position (in SXT pixel coordinates) from
;        the HXA info in the PNT files.  Tries to reconstruct hidden limbs.
; CATEGORY:
; CALLING SEQUENCE:
;        sunc = hxa_suncenter(pnt)
;        sunc = hxa_suncenter(index=index)
; INPUTS:
;        pnt = pnt structure.  Optional if index keyword supplied.  In that
;              case, the pnt file is read automatically.
; KEYWORDS (INPUT):
;        index = sxt index structure.  If supplied, the suncenter position is
;                calculated only for the times given in the index structure.
;                In addition, the suncenter coordinates for the optical images
;                are corrected for the appropriate filter offsets.
;        /hxa = Output in hxa coordinates instead of SXT pixel coordinates
;        /noorbit = do not correct for orbital variations of the offset
;                   between HXT and SXT.  (fem file not read in this case.)
;        /nosecular = do not correct for secular variation of the offset
;                     between HXT and SXT.
;        /nofilt = do not test and correct for offsets of optical filters.
;                  Use if INDEX is not a SXT index or roadmap structure.
;        fem = fem orbital data structure.  Optional, fem file read
;              automatically if not supplied.
; OUTPUTS:
;        sunc = suncenter coordinates in SXT full resolution pixels.
;               sunc(0,*) = x, sunc(1,*) = y, sunc(2,*) = pnt.time,
;               sunc(3,*) = pnt.day
; KEYWORDS (OUTPUT):
;        code = vector.  Indicates how each sun center position was obtained.
;               0 : error, no result, 1 : ADS used, 2 : result deduced from
;               2 limbs, 3: result deduced from 3 limbs, 4 : all limbs used.
;		-1: S/C commanded value used
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
; RESTRICTIONS:
;        Use of ADS in case of failure is not implemented yet.
;        The secular variation of the offset between HXT and SXT is
;        well corrected for the first year of Yohkoh.  The correction
;        needs to be updated as the project goes on.
; PROCEDURE:
; MODIFICATION HISTORY:
;        JPW, Oct. 1992 added index keyword, added offset SXT - aspect tel.
;        JPW, Oct. 1992 added corrections for orbital and secular variations
;	  5-Jun-93 (MDM) - Added ZON keyword output option
;			 - Added a print statment
;			 - Added code(*) = -1 option to return S/C commanded
;			   value instead of just returning zeros (replaced
;			   code = 0)
;	14-Jun-93 (MDM) - Did a range check on HXA data values (0 to 2047)
;	18-Jul-93 (MDM) - Replaced SUN_R call with GET_RB0P
;       30-sep-93 (JPW) - Changed coordinate system from halfres. OFR to FRE
;                         (a 0.5 pixel difference)
;       23-sep-94 (JPW) - Suppressing the secular variation correction for
;                         dates after Jan-93.
;-

function hxa_suncenter,pnt0,code=code,hxa=hxaflag,index=sindex, $
   noorbit=noorb,nosecular=nosec,nofilt=nofilt,fem=fem,zon=zon

; read pnt file if necessary
n_sind = n_elements(sindex)
if n_sind gt 0 then begin
   sip0 = size(pnt0)
   if sip0(sip0(0)+1) ne 8 then rd_pnt,sindex(0),sindex(n_sind-1),pnt0
   whe = tim2dset(pnt0,sindex)
   pnt = pnt0(whe)
endif else pnt = pnt0

; various constants
cdx93 = -0.28                       ; constant secular correction after jan-93
cdy93 = -0.44

spix = 2.072/2.455
phi = 44.35
sxt_offx = 503.6 + 0.36 + cdx93
sxt_offy = 665.1 - 1.47 + cdy93
sxt_offx = sxt_offx + 0.5           ; OFR -> FRE
sxt_offy = sxt_offy + 0.5           ; OFR -> FRE
naban_ox = -0.36
naban_oy = +1.47
wdban_ox = -0.36 + 0.6
wdban_oy = +1.47 - 0.2
hpix = 2.072d                       ; factor hxa -> sun_r
h_xx = 1006.0d                      ; hxa axes cross at x = h_xx
h_yy = 1038.0d                      ; hxa axes cross at y = h_yy
cxx = [+0.21,-6.23e-4,+1.82e-7]     ; coefficients for orbital time correction
cyy = [+1.22,-1.326e-3,+2.82e-7]
cny = [+0.32,+1.198e-3,-1.019e-6]   ; coefficients for orbit duration (y only)
cdx = [+1.88-cdx93,-3.130e-3,+1.068e-6]   ; coefficients for secular correction
cdy = [-8.57-cdy93,+1.889e-2,-1.024e-5]   ; until the end of 1992
tmcut = 5115                        ; = gt_day('1-jan-93')

; prepare variables to resolve for hidden limbs
;sunr = sun_r(pnt.day)/hpix          ; solar radius in hxa pixel units	 - MDM removed 18-Jul-93
sunr = get_rb0p(pnt,/radius)/hpix	; solar radius in hxa pixel units
hxa = double(pnt.hxa)               ; 0 at crossing point
hxa(0:1,*) = hxa(0:1,*) - h_xx
hxa(2:3,*) = hxa(2:3,*) - h_yy
n = n_elements(pnt)
sunc = dblarr(2,n)
sunc(0,*) = (hxa(0,*)+hxa(1,*))/2.0d
sunc(1,*) = (hxa(2,*)+hxa(3,*))/2.0d
code = intarr(n)

pnt.hxa = pnt.hxa >0<2047	;MDM added 14-Jun-93

; create bit pattern of hidden limbs.
forzones,xzon,yzon
zon = intarr(n)
whe = where(xzon(pnt.hxa(0)))
if whe(0) ge 0 then zon(whe) = zon(whe) or 1
whe = where(xzon(pnt.hxa(1)))
if whe(0) ge 0 then zon(whe) = zon(whe) or 2
whe = where(yzon(pnt.hxa(2)))
if whe(0) ge 0 then zon(whe) = zon(whe) or 4
whe = where(yzon(pnt.hxa(3)))
if whe(0) ge 0 then zon(whe) = zon(whe) or 8

; go through the various possible cases of hidden/nonhidden limbs

; 4 limbs visible : no fix required
whe = where(zon eq 0)
if whe(0) ge 0 then code(whe) = 4

; 3 limbs visible.  4 cases
whe = where(zon eq 1)
if whe(0) ge 0 then begin
   ; fix hxa0
   aux = sunr(whe)*sunr(whe) - sunc(1,whe)*sunc(1,whe)
   ; test if root nonzero
   ww = where(aux ge 0.0d)
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa0 = hxa(1,whe) - 2.0d*sqrt(aux(ww))
      ; test if not too far from hidden limb (fid. marks about 50 pixel wide)
      err1 = hxa(0,whe)-hxa0
      ww = where((err1 le 55.0d) and (err1 ge -5.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa(0,whe) = hxa0(ww)
         sunc(0,whe) = (hxa(0,whe)+hxa(1,whe))/2.0d
         code(whe) = 3
      endif
   endif
endif
whe = where(zon eq 2)
if whe(0) ge 0 then begin
   ; fix hxa1
   aux = sunr(whe)*sunr(whe) - sunc(1,whe)*sunc(1,whe)
   ; test if root nonzero
   ww = where(aux ge 0.0d)
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa1 = hxa(0,whe) + 2.0d*sqrt(aux(ww))
      ; test if not too far from hidden limb (fid. marks about 50 pixel wide)
      err1 = hxa1-hxa(1,whe)
      ww = where((err1 le 55.0d) and (err1 ge -5.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa(1,whe) = hxa1(ww)
         sunc(0,whe) = (hxa(0,whe)+hxa(1,whe))/2.0d
         code(whe) = 3
      endif
   endif
endif
whe = where(zon eq 4)
if whe(0) ge 0 then begin
   ; fix hxa2
   aux = sunr(whe)*sunr(whe) - sunc(0,whe)*sunc(0,whe)
   ; test if root nonzero
   ww = where(aux ge 0.0d)
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa2 = hxa(3,whe) - 2.0d*sqrt(aux(ww))
      ; test if not too far from hidden limb (fid. marks about 50 pixel wide)
      err1 = hxa(2,whe)-hxa2
      ww = where((err1 le 55.0d) and (err1 ge -5.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa(2,whe) = hxa2(ww)
         sunc(1,whe) = (hxa(2,whe)+hxa(3,whe))/2.0d
         code(whe) = 3
      endif
   endif
endif
whe = where(zon eq 8)
if whe(0) ge 0 then begin
   ; fix hxa3
   aux = sunr(whe)*sunr(whe) - sunc(0,whe)*sunc(0,whe)
   ; test if root nonzero
   ww = where(aux ge 0.0d)
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa3 = hxa(2,whe) + 2.0d*sqrt(aux(ww))
      ; test if not too far from hidden limb (fid. marks about 50 pixel wide)
      err1 = hxa3-hxa(3,whe)
      ww = where((err1 le 55.0d) and (err1 ge -5.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa(3,whe) = hxa3(ww)
         sunc(1,whe) = (hxa(2,whe)+hxa(3,whe))/2.0d
         code(whe) = 3
      endif
   endif
endif

; 2 limbs visible.  4 cases
; assumes that hxa0 hxa2 always neg. and hxa1 and hxa3 always pos.
; since solution not unique
whe = where(zon eq 5)
if whe(0) ge 0 then begin
   ; fix hxa0 and hxa2
   ww = where((hxa(1,whe) gt 1.0d) and (hxa(3,whe) gt 1.0d))
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa1=hxa(1,whe)*hxa(1,whe)
      hxa3=hxa(3,whe)*hxa(3,whe)
      srad=sunr(whe)*sunr(whe)
      hxa0 = hxa3*(4.0d*srad-hxa1-hxa3)/(hxa1+hxa3)
      hxa2 = hxa1*(4.0d*srad-hxa1-hxa3)/(hxa1+hxa3)
      ww = where((hxa0 ge 0.0d) and (hxa2 ge 0.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa0 = -sqrt(hxa0(ww))
         hxa2 = -sqrt(hxa2(ww))
         ; test if not too far from hidden limb (fid. marks < 50 pixel wide)
         err1 = hxa(0,whe)-hxa0
         err2 = hxa(2,whe)-hxa2
         ww = where((err1 le 55.0d) and (err1 ge -5.0d) and $
                    (err2 le 55.0d) and (err2 ge -5.0d))
         if ww(0) ge 0 then begin
            whe = whe(ww)
            hxa(0,whe) = hxa0(ww)
            hxa(2,whe) = hxa2(ww)
            sunc(0,whe) = (hxa(0,whe)+hxa(1,whe))/2.0d
            sunc(1,whe) = (hxa(2,whe)+hxa(3,whe))/2.0d
            code(whe) = 2
         endif
      endif
   endif
endif
whe = where(zon eq 6)
if whe(0) ge 0 then begin
   ; fix hxa1 and hxa2
   ww = where((hxa(0,whe) lt -1.0d) and (hxa(3,whe) gt 1.0d))
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa0=hxa(0,whe)*hxa(0,whe)
      hxa3=hxa(3,whe)*hxa(3,whe)
      srad=sunr(whe)*sunr(whe)
      hxa1 = hxa3*(4.0d*srad-hxa0-hxa3)/(hxa0+hxa3)
      hxa2 = hxa0*(4.0d*srad-hxa0-hxa3)/(hxa0+hxa3)
      ww = where((hxa1 ge 0.0d) and (hxa2 ge 0.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa1 = +sqrt(hxa1(ww))
         hxa2 = -sqrt(hxa2(ww))
         ; test if not too far from hidden limb (fid. marks < 50 pixel wide)
         err1 = hxa1-hxa(1,whe)
         err2 = hxa(2,whe)-hxa2
         ww = where((err1 le 55.0d) and (err1 ge -5.0d) and $
                    (err2 le 55.0d) and (err2 ge -5.0d))
         if ww(0) ge 0 then begin
            whe = whe(ww)
            hxa(1,whe) = hxa1(ww)
            hxa(2,whe) = hxa2(ww)
            sunc(0,whe) = (hxa(0,whe)+hxa(1,whe))/2.0d
            sunc(1,whe) = (hxa(2,whe)+hxa(3,whe))/2.0d
            code(whe) = 2
         endif
      endif
   endif
endif
whe = where(zon eq 9)
if whe(0) ge 0 then begin
   ; fix hxa0 and hxa3
   ww = where((hxa(1,whe) gt 1.0d) and (hxa(2,whe) lt -1.0d))
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa1=hxa(1,whe)*hxa(1,whe)
      hxa2=hxa(2,whe)*hxa(2,whe)
      srad=sunr(whe)*sunr(whe)
      hxa0 = hxa2*(4.0d*srad-hxa1-hxa2)/(hxa1+hxa2)
      hxa3 = hxa1*(4.0d*srad-hxa1-hxa2)/(hxa1+hxa2)
      ww = where((hxa0 ge 0.0d) and (hxa3 ge 0.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa0 = -sqrt(hxa0(ww))
         hxa3 = +sqrt(hxa3(ww))
         ; test if not too far from hidden limb (fid. marks < 50 pixel wide)
         err1 = hxa(0,whe)-hxa0
         err2 = hxa3-hxa(3,whe)
         ww = where((err1 le 55.0d) and (err1 ge -5.0d) and $
                    (err2 le 55.0d) and (err2 ge -5.0d))
         if ww(0) ge 0 then begin
            whe = whe(ww)
            hxa(0,whe) = hxa0(ww)
            hxa(3,whe) = hxa3(ww)
            sunc(0,whe) = (hxa(0,whe)+hxa(1,whe))/2.0d
            sunc(1,whe) = (hxa(2,whe)+hxa(3,whe))/2.0d
            code(whe) = 2
         endif
      endif
   endif
endif
whe = where(zon eq 10)
if whe(0) ge 0 then begin
   ; fix hxa1 and hxa3
   ww = where((hxa(0,whe) lt -1.0d) and (hxa(2,whe) lt -1.0d))
   if ww(0) ge 0 then begin
      whe = whe(ww)
      hxa0=hxa(0,whe)*hxa(0,whe)
      hxa2=hxa(2,whe)*hxa(2,whe)
      srad=sunr(whe)*sunr(whe)
      hxa1 = hxa2*(4.0d*srad-hxa0-hxa2)/(hxa0+hxa2)
      hxa3 = hxa0*(4.0d*srad-hxa0-hxa2)/(hxa0+hxa2)
      ww = where((hxa1 ge 0.0d) and (hxa3 ge 0.0d))
      if ww(0) ge 0 then begin
         whe = whe(ww)
         hxa1 = +sqrt(hxa1(ww))
         hxa3 = +sqrt(hxa3(ww))
         ; test if not too far from hidden limb (fid. marks < 50 pixel wide)
         err1 = hxa1-hxa(1,whe)
         err2 = hxa3-hxa(3,whe)
         ww = where((err1 le 55.0d) and (err1 ge -5.0d) and $
                    (err2 le 55.0d) and (err2 ge -5.0d))
         if ww(0) ge 0 then begin
            whe = whe(ww)
            hxa(1,whe) = hxa1(ww)
            hxa(3,whe) = hxa3(ww)
            sunc(0,whe) = (hxa(0,whe)+hxa(1,whe))/2.0d
            sunc(1,whe) = (hxa(2,whe)+hxa(3,whe))/2.0d
            code(whe) = 2
         endif
      endif
   endif
endif

; do some testing for garbage results
whe = where((zon/4 ne 3) and (zon mod 4 ne 3))
if whe(0) ge 0 then begin
   ;print, 'Testing for cases where only have 2 non-fiducial marks'
   ; test
   xoff = sunc(0,whe)
   yoff = sunc(1,whe)
   xrad = (hxa(1,whe)-hxa(0,whe))/2.0d
   yrad = (hxa(3,whe)-hxa(2,whe))/2.0d
   err1 = abs(sqrt(xrad*xrad + yoff*yoff) - sunr(whe))
   err2 = abs(sqrt(yrad*yrad + xoff*xoff) - sunr(whe))
   werr = where((err1 gt 3.0d) or (err2 gt 3.0d))
   if werr(0) ge 0 then begin
	code(whe(werr)) = 0  ; set error code
	;;print, 'Checking the radius for cases of < 3 fiducial marks.'
	;;print, 'Setting ', n_elements(werr), ' values out of ', n_elements(err1), ' to zero because of large error
   end
endif

whe = where(code eq 0)
if whe(0) ge 0 then sunc(*,whe) = 0.0d

sunout = fltarr(4,n)
sunout(2,*) = pnt.time
sunout(3,*) = pnt.day
if keyword_set(hxaflag) then begin

   sunout(0,*) = sunc(0,*) + h_xx
   sunout(1,*) = sunc(1,*) + h_yy

endif else begin

   ; sxt transformation
   sinphi = sin(phi/!radeg)
   cosphi = cos(phi/!radeg)
   sunout(0,*) = spix * (sunc(0,*)*cosphi + sunc(1,*)*sinphi) + sxt_offx
   sunout(1,*) = spix * (sunc(0,*)*sinphi - sunc(1,*)*cosphi) + sxt_offy

   ;--- MDM added the portion below 5-Jun-93
   whe = where(code eq 0)
   if whe(0) ge 0 then begin		;MDM expanded to call SXT_CMD_PNT
      sc_cmd = sxt_cmd_pnt(pnt(whe))
      sunout(0:1,whe) = sc_cmd
      code(whe) = -1
   end

   ; orbital time correction and correction for duration of day
   if (not keyword_set(noorb)) then begin
     ; get fem data if required.
     sifem = size(fem)
     if sifem(sifem(0)+1) ne 8 then begin
       startpnt=pnt(0)                ; bug in rd_fem
       startpnt.day=startpnt.day-1    ; requires this fix
        rd_fem,startpnt,pnt(n-1),fem
     endif

     whe = tim2dset(fem,pnt)          ; closest orbit
     ; get time elapsed since sunrise
     t_orb = (pnt.time-fem(whe).time)/1e3 + (pnt.day-fem(whe).day)*(24.0*3.6e3)
     ; tim2dset gives closest orbit, but not necessarily current orbit:
     ww = where(t_orb lt 0.0)
     if ww(0) ge 0 then whe(ww) = whe(ww) - 1     ; get previous orbit
     whe = whe > 0                    ; make shure index is not negative
     ; calculate time again with correct orbits
     t_orb = (pnt.time-fem(whe).time)/1e3 + (pnt.day-fem(whe).day)*(24.0*3.6e3)
     t_nit = float(fem(whe).night-4000)   ; duration of day - 4000 s

     ; check if really correct orbit.  Make corrections only for those
     ww = where((t_orb ge 0.0) and (t_orb le 6e3))
     if ww(0) ge 0 then begin
       t_orb = t_orb(ww)
       t_nit = t_nit(ww)
       sunout(0,ww) = sunout(0,ww) + cxx(0) + cxx(1)*t_orb + cxx(2)*t_orb*t_orb
       sunout(1,ww) = sunout(1,ww) + cyy(0) + cyy(1)*t_orb + cyy(2)*t_orb*t_orb
       ; t_nit correction only required in y
       sunout(1,ww) = sunout(1,ww) + cny(0) + cny(1)*t_nit + cny(2)*t_nit*t_nit
     endif
   endif

   ; correction for secular variation
   if (not keyword_set(nosec)) then begin
     wc = where(pnt.day lt tmcut,ncut)     ; data before 1-jan-93
     if ncut gt 0 then begin
       t_day = float(pnt(wc).day-4000)  ; time for secular variations
       sunout(0,wc) = sunout(0,wc) + cdx(0) + cdx(1)*t_day + cdx(2)*t_day*t_day
       sunout(1,wc) = sunout(1,wc) + cdy(0) + cdy(1)*t_day + cdy(2)*t_day*t_day
     endif
   endif

   if ((n_sind gt 0) and (not keyword_set(nofilt))) then begin
      whe = where(gt_filta(sindex) eq 2)   ; NaBan filter?
      if whe(0) ge 0 then begin
         sunout(0,whe) = sunout(0,whe) + naban_ox
         sunout(1,whe) = sunout(1,whe) + naban_oy
      endif
      whe = where(gt_filta(sindex) eq 5)   ; WdBan filter?
      if whe(0) ge 0 then begin
         sunout(0,whe) = sunout(0,whe) + wdban_ox
         sunout(1,whe) = sunout(1,whe) + wdban_oy
      endif
   endif
endelse

return,sunout
end
