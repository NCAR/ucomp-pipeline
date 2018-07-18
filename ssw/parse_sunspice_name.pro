;+
; Project     :	Multimission
;
; Name        :	PARSE_SUNSPICE_NAME
;
; Purpose     :	Parses spacecraft name for SPICE input
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine parses various versions of the names of certain
;               known missions/observatories into the spacecraft ID codes used
;               by the JPL SPICE software.  Unrecognized names are simply
;               trimmed and converted to uppercase.  Numerical codes are
;               converted to their string equivalents.
;
; Syntax      :	Output = PARSE_SUNSPICE_NAME( SPACECRAFT )
;
; Examples    :	'A' returns '-234'
;               'SOLO' returns '-144'
;               'Earth' returns 'EARTH'
;
; Inputs      :	SPACECRAFT = Can be one of the following forms:
;
;                       For STEREO:
;
;                               'A'             'B'
;                               'STA'           'STB'
;                               'Ahead'         'Behind'
;                               'STEREO Ahead'  'STEREO Behind'
;                               'STEREO-Ahead'  'STEREO-Behind'
;                               'STEREO_Ahead'  'STEREO_Behind'
;                               '-234'          '-235'
;
;                            Abbreviations are possible, e.g. 'STEREO-A'
;
;                       For SOHO:
;
;                               'SOHO'
;                               '-21'
;
;                       For Solar Orbiter:
;
;                               'Solar Orbiter'
;                               'Solar-Orbiter'
;                               'Solar_Orbiter'
;                               'Orbiter'
;                               'SOLO'
;                               '-144'
;
;                            The word "Orbiter" can be abbreviated as "Orb".
;
;                       For Parker Solar Probe (formerly Solar Probe Plus)
;
;                               'Parker Solar Probe'
;                               'Parker-Solar-Probe'
;                               'Parker_Solar_Probe'
;                               'Solar Probe Plus'
;                               'Solar-Probe-Plus'
;                               'Solar_Probe_Plus'
;                               'PSP'
;                               'SPP'
;                               '-96'
;
;                            The "Solar" and/or "Plus" can be left out, but
;                            either "Parker" or "Probe" must be spelled out.
;
;                       Case is not important.  If not one of the above forms,
;                       the original string is returned, trimmed and converted
;                       to uppercase.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the spacecraft ID to be passed
;               to SPICE routines.
;
; Opt. Outputs:	None.
;
; Keywords    : None.
;
; Calls       :	CSPICE_BODN2C
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	Based on PARSE_STEREO_NAME
;
; History     :	Version 1, 25-Apr-2016, William Thompson, GSFC
;               Version 2, 02-Jun-2017, WTT, new name Parker Solar Probe
;
; Contact     :	WTHOMPSON
;-
;
function parse_sunspice_name, spacecraft
on_error, 2
;
;  Check the input values.
;
if n_elements(spacecraft) ne 1 then message, $
  'SPACECRAFT must be a scalar'
;
;  Convert the input into a trimmed, uppercase string.
;
sc = strtrim(strupcase(spacecraft),2)
n = strlen(sc)
;
;  If the string is recognized as one of the STEREO spacecraft, then return the
;  appropriate ID value.
;
if (sc eq strmid('AHEAD',0,n>1)) or $
   (sc eq strmid('STEREO AHEAD',0,n>8)) or $
   (sc eq strmid('STEREO-AHEAD',0,n>8)) or $
   (sc eq strmid('STEREO_AHEAD',0,n>8)) or $
   (sc eq 'STA') then return, '-234'
;
if (sc eq strmid('BEHIND',0,n>1)) or $
   (sc eq strmid('STEREO BEHIND',0,n>8)) or $
   (sc eq strmid('STEREO-BEHIND',0,n>8)) or $
   (sc eq strmid('STEREO_BEHIND',0,n>8)) or $
   (sc eq 'STB') then return, '-235'
;
;  If SOHO, then return -21.
;
if (sc eq 'SOHO') then return, '-21'
;
;  If Solar Orbiter then return -144.
;
if (sc eq strmid('SOLAR ORBITER',0,n>9)) or $
   (sc eq strmid('SOLAR-ORBITER',0,n>9)) or $
   (sc eq strmid('SOLAR_ORBITER',0,n>9)) or $
   (sc eq strmid('ORBITER',0,n>3)) or $
   (sc eq 'SOLO') then return, '-144'
;
;  If Solar Probe Plus then return -96.
;
if (sc eq strmid('PARKER SOLAR PROBE',0,n>6)) or $
   (sc eq strmid('PARKER-SOLAR-PROBE',0,n>6)) or $
   (sc eq strmid('PARKER_SOLAR_PROBE',0,n>6)) or $
   (sc eq strmid('SOLAR PROBE PLUS',0,n>11)) or $
   (sc eq strmid('SOLAR-PROBE-PLUS',0,n>11)) or $
   (sc eq strmid('SOLAR_PROBE_PLUS',0,n>11)) or $
   (sc eq strmid('PROBE PLUS',0,n>5)) or $
   (sc eq strmid('PROBE-PLUS',0,n>5)) or $
   (sc eq strmid('PROBE_PLUS',0,n>5)) or $
   (sc eq 'PSP') or (sc eq 'SPP') then return, '-96'
;
;  Try to parse the name using BODN2C.
;
if not valid_num(sc) then begin
    cspice_bodn2c, sc, code, found
    if found then sc = ntrim(code) else $
      message, /continue, 'Warning: ' + sc + ' not recognized'
endif
;
;  Otherwise, simply return the (trimmed and uppercase) original name.
;
return, sc
end
