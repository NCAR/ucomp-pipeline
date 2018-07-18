pro orb_struct, orb_record=orb_rec

;+
;       NAME:
;               ORB_STRUCT
;       PURPOSE:
;		Structure containing information about the orbital position of 
;		the spacecraft, typically every 300 secs.
;	  	Defines orb_record
;       CALLING SEQUENCE:
;               ORB_STRUCT
;       HISTORY:
;               Written 28-Aug-96 by R.D.Bentley
;
;-

orb_rec = {oidx, $
time:           long(0), $	;ms since start of day
day:            fix(0), $	;days since 1-Jan-1979
lat:            float(0), $	;spacecraft latitude in degrees
long:           float(0), $	;spacecraft longitude in degrees
height:         float(0), $     ;height of spacecraft above the Earth (km)
radius:		float(0), $	;spacecraft radius from center of the Earth (km)
rig:            float(0), $	;rigidity (cosmic background)
sc_day:         byte(0), $	;flag of spaccraft day status (1=in daylight)
saa:            byte(0), $	;flag of spacecraft SAA status (1=in SAA)
spare:          bytarr(4)}

end
