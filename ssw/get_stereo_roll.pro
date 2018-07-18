;+
; Project     :	STEREO - SSC
;
; Name        :	GET_STEREO_ROLL
;
; Purpose     :	Legacy front-end to GET_SUNSPICE_ROLL
;
; Category    :	STEREO, Orbit
;
; History     :	Version 6, 09-May-2016, WTT, call GET_SUNSPICE_ROLL
;
; Contact     :	WTHOMPSON
;-
;
function get_stereo_roll, date, spacecraft, yaw, pitch, system=k_system, $
                          found=found, instrument=instrument, $
                          degrees=degrees, radians=radians, $
                          post_conjunction=post_conjunction, $
                          tolerance=tolerance, errmsg=errmsg, _extra=_extra
return, get_sunspice_roll(date, spacecraft, yaw, pitch, system=k_system, $
                          found=found, instrument=instrument, $
                          degrees=degrees, radians=radians, $
                          post_conjunction=post_conjunction, $
                          tolerance=tolerance, errmsg=errmsg, _extra=_extra)
end
