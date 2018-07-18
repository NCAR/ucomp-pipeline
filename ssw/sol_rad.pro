;+
; Project     : HESSI
;
; Name        : SOL_RAD
;
; Purpose     : compute solar radius from solar distance
;
; Category    : utility
;
; Syntax      : IDL> rsun=sol_rad(dsun)
;
; Inputs      : DSUN = distance to Sun in km
;
; Outputs     : RSUN = solar radius in arcsecs
;
; History     : 10-Oct-2007, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function sol_rad,dsun

if not_exist(dsun) then return,0.
if dsun le 0 then return,0.

return,asin(6.95508E5 /dsun) * 180.d0 * 3600.d0 / !dpi

end
