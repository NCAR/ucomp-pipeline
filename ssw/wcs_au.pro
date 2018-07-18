;+
; Project     :	SOHO - CDS
;
; Name        :	WCS_AU()
;
; Purpose     :	Returns the astronomical unit in meters
;
; Category    :	Coordinates, WCS
;
; Explanation :	Returns the value of an astronomical unit as 1.49597870691d11
;               meters, based on the website
;
;               http://ssd.jpl.nasa.gov/?constants
;
;               and on Standish, E.M. (1995) "Report of the IAU WGAS Sub-Group
;               on Numerical Standards", in Highlights of Astronomy
;               (I. Appenzeller, ed.), Table 1, Kluwer Academic Publishers,
;               Dordrecht.
;
;               The purpose of having this in a separate routine is so that
;               various routines using this parameter can access it from a
;               single location, avoiding inconsistent definitions across
;               routines.
;
; Syntax      :	au = WCS_AU()
;
; Keywords    : UNITS   = By default, this routine returns the value of 1
;                         A.U. in meters, since that is the FITS standard.
;                         Other length units can be passed through the UNITS
;                         keyword, e.g.
;
;                               au = WCS_AU(units='km')
;
;                         The routine WCS_PARSE_UNITS is used to parse the
;                         UNITS string.  Note that the units string is case
;                         sensitive: 'mm' is different from 'Mm'.
;
; Calls       : WCS_PARSE_UNITS
;
; History     :	Version 1, 8-Dec-2008, William Thompson, GSFC
;               Version 2, 9-Sep-2009, WTT, added keyword UNITS
;
; Contact     :	WTHOMPSON
;-
;
function wcs_au, units=units
on_error, 2
;
au = 1.49597870691d11
;
if datatype(units) eq 'STR' then begin
    if n_elements(units) gt 1 then message, 'UNITS must be a scalar'
    wcs_parse_units, units, base_units, factor, /quiet
    if base_units ne 'm' then begin
        wcs_parse_units, strlowcase(units), base_units, factor, /quiet
        if base_units ne 'm' then begin
            wcs_parse_units, strupcase(units), base_units, factor, /quiet
            if base_units ne 'm' then message, 'Units "' + units + $
              '" not recognized as units of length'
        endif
    endif
    au = au / factor
endif
;
return, au
end
