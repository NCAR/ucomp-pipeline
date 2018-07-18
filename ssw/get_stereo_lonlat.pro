;+
; Project     :	STEREO - SSC
;
; Name        :	GET_STEREO_LONLAT
;
; Purpose     :	Legacy front-end to GET_SUNSPICE_LONLAT
;
; History     :	Version 8, 09-May-2016, WTT, call GET_SUNSPICE_LONLAT
;
; Contact     :	WTHOMPSON
;-
;
function get_stereo_lonlat, date, spacecraft, system=k_system, ltime=ltime, $
                            corr=corr, precess=precess, target=target, $
                            planetographic=planetographic, errmsg=errmsg, $
                            meters=meters, au=au, degrees=degrees, $
                            pos_long=pos_long, found=found, _extra=_extra
return, get_sunspice_lonlat(date, spacecraft, system=k_system, ltime=ltime, $
                            corr=corr, precess=precess, target=target, $
                            planetographic=planetographic, errmsg=errmsg, $
                            meters=meters, au=au, degrees=degrees, $
                            pos_long=pos_long, found=found, _extra=_extra)
end
