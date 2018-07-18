;+
; Project     : STEREO
;
; Name        : pb0r_stereo
;
; Purpose     : return p0, b0, l0, and solar radius as viewed from
;               STEREO A or STEREO B (EUVI telescopes only)
;
; Category    : imaging, maps
;
; Syntax      : IDL> pbr=pb0r(time,l0=l0,roll_angle=roll_angle)
;
; Inputs      : TIME = UT time to compute 
;
; Outputs     : PBR = [p0,b0,rsun]
;
; Keywords    : STEREO = A or /AHEAD for STEREO A [def]
;                      = B or /BEHIND for STEREO B
;               L0 = central meridian [deg]
;               ROLL_ANGLE = spacecraft roll [deg]
;               ARCSEC = return radius in arcsecs
;               COR1, COR2 = set for coronagraph 1 or 2
;
; History     : Written 21 August 2008 - Zarro (ADNET)
;               11 December 2014, Zarro (ADNET)
;               - corrected roll offsets
;
; Contact     : dzarro@solar.stanford.edu
;-

function pb0r_stereo,time,arcsec=arcsec,l0=l0,error=error,$
                     roll_angle=roll_angle,cor1=cor1,cor2=cor2,$
                     stereo=stereo,ahead=ahead,behind=behind

forward_function get_stereo_lonlat,get_stereo_roll

error=''
l0=0 & roll_angle=0.
pbr=[0.,0.,16.]
if keyword_set(arcsec) then pbr=[0.,0.,960.]
if ~have_proc('get_stereo_lonlat') then begin
 error='STEREO orbital position routine - get_stereo_lonlat - not found'
 message,error,/cont
 return,pbr
endif

proj_time=anytim2tai(time,err=error)
if is_string(error) then begin
 pr_syntax,'pbr=pb0r_stereo(time)'
 return,pbr
endif

stereo_launch=anytim2tai('26-oct-2006')
if proj_time lt stereo_launch then begin
 error='STEREO orbital data unavailable for this input time'
 message,error,/cont
 return,pbr
endif

;-- STEREO values of l0, b0, rsun, and roll for input time

spacecraft='A'
case 1 of
 is_string(stereo): if strupcase(stereo) eq 'B' then spacecraft='B'
 keyword_set(behind): spacecraft='B'
 else: spacecraft='A'
endcase
 
error=''
pos=get_stereo_lonlat(time, spacecraft, system="HEEQ", /degrees,err=error)

if is_string(error) then begin
 message,error,/cont
 return,pbr
endif

b0=pos[2]
l0=pos[1]
rsun=sol_rad(pos[0])
if ~keyword_set(arcsec) then rsun=rsun/60.

;-- compute roll

sroll_corr_a=[.12,0.203826,0.45]
sroll_corr_b=[-1.125, 0.0983413,-0.20]

case 1 of
 keyword_set(cor2): val=2
 keyword_set(cor1): val=1
 else: val=0
endcase

roll_corr_a=sroll_corr_a[val]
roll_corr_b=sroll_corr_b[val]
roll_corr= (spacecraft eq 'A') ? roll_corr_a : roll_corr_b
roll_angle=-get_stereo_roll(time, spacecraft,err=error,/degrees)+roll_corr

if is_string(err) then begin
 message,err,/cont
 return,pbr
endif

;-- compute p0

p0=get_stereo_roll(time,spacecraft,system='HEEQ') - $
    get_stereo_roll(time, spacecraft,system='GEI')

return,[p0,b0,rsun]
end

