;+
; Project     :	STEREO
;
; Name        :	WCS_PARSE_UNITS
;
; Purpose     :	Parse FITS/WCS units specification strings
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	Parses a FITS/WCS units specification string, as described in
;               Greisen and Calabretta, 2002, "Representations of world
;               coordinates in FITS", A&A, 395, 1061-1075.  Coordinates are
;               decomposed into their base MKS units, together with an
;               appropriate multiplication factor.
;
; Syntax      :	WCS_PARSE_UNITS, UNITS_STRING, BASE_UNITS, FACTOR
;
; Examples    :	WCS_PARSE_UNITS, 'Angstrom', BASE_UNITS, FACTOR
;
;               Would give as output:   BASE_UNITS = 'm'
;                                       FACTOR = 1E-10
;
; Inputs      :	UNITS_STRING = String containing the units specification.
;
; Opt. Inputs :	None.
;
; Outputs     :	BASE_UNITS = String containing the derived base units, made up
;                            of "m", "kg", "s", "rad", "sr", "K", "A", "mol",
;                            and "cd" (candela).  For example, velocity would
;                            be expressed as "m.s^-1".
;
;               FACTOR = The conversion factor from the input units into the
;                        base units.
;
;               
;
; Opt. Outputs:	None.
;
; Keywords    :	QUIET   = Turn off informational messages
;
; Calls       :	DATATYPE, WCS_PARSE_UNITS_BASE, NTRIM
;
; Common      :	None.
;
; Restrictions:	Functions log(), ln(), and exp() are not supported.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 06-Jun-2005, William Thompson, GSFC
;               Version 2, 12-Dec-2008, WTT, added keyword /QUIET
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_parse_units, units_string, base_units, factor, quiet=quiet
on_error, 2
;
;  Check the calling sequence, and input parameter.
;
if n_params() ne 3 then message, $
  'Syntax: WCS_PARSE_UNITS, UNITS_STRING, BASE_UNITS, FACTOR
if (n_elements(units_string) ne 1) or (datatype(units_string,1) ne 'String') $
  then message, 'UNITS_STRING must be a scalar character string'
;
;  Call WCS_PARSE_UNITS_BASE to do the actual parsing.
;
wcs_parse_units_base, units_string, factor, meters, kilograms, seconds, $
  radians, steradians, kelvins, amperes, moles, candelas, quiet=quiet
;
;  Form the string for the base units.
;
base_units = ''
;
if kilograms ne 0 then begin
    base_units = 'kg'
    if kilograms ne 1 then begin
        base_units = base_units + '^'
        if kilograms ne long(kilograms) then base_units = base_units + '('
        base_units = base_units + ntrim(kilograms)
        if kilograms ne long(kilograms) then base_units = base_units + ')'
    endif
endif
;
if meters ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'm'
    if meters ne 1 then begin
        base_units = base_units + '^'
        if meters ne long(meters) then base_units = base_units + '('
        base_units = base_units + ntrim(meters)
        if meters ne long(meters) then base_units = base_units + ')'
    endif
endif
;
if seconds ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 's'
    if seconds ne 1 then begin
        base_units = base_units + '^'
        if seconds ne long(seconds) then base_units = base_units + '('
        base_units = base_units + ntrim(seconds)
        if seconds ne long(seconds) then base_units = base_units + ')'
    endif
endif
;
if radians ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'rad'
    if radians ne 1 then begin
        base_units = base_units + '^'
        if radians ne long(radians) then base_units = base_units + '('
        base_units = base_units + ntrim(radians)
        if radians ne long(radians) then base_units = base_units + ')'
    endif
endif
;
if steradians ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'sr'
    if steradians ne 1 then begin
        base_units = base_units + '^'
        if steradians ne long(steradians) then base_units = base_units + '('
        base_units = base_units + ntrim(steradians)
        if steradians ne long(steradians) then base_units = base_units + ')'
    endif
endif
;
if kelvins ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'K'
    if kelvins ne 1 then begin
        base_units = base_units + '^'
        if kelvins ne long(kelvins) then base_units = base_units + '('
        base_units = base_units + ntrim(kelvins)
        if kelvins ne long(kelvins) then base_units = base_units + ')'
    endif
endif
;
if amperes ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'A'
    if amperes ne 1 then begin
        base_units = base_units + '^'
        if amperes ne long(amperes) then base_units = base_units + '('
        base_units = base_units + ntrim(amperes)
        if amperes ne long(amperes) then base_units = base_units + ')'
    endif
endif
;
if moles ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'mol'
    if moles ne 1 then begin
        base_units = base_units + '^'
        if moles ne long(moles) then base_units = base_units + '('
        base_units = base_units + ntrim(moles)
        if moles ne long(moles) then base_units = base_units + ')'
    endif
endif
;
if candelas ne 0 then begin
    if base_units ne '' then base_units = base_units + '.'
    base_units = base_units + 'cd'
    if candelas ne 1 then begin
        base_units = base_units + '^'
        if candelas ne long(candelas) then base_units = base_units + '('
        base_units = base_units + ntrim(candelas)
        if candelas ne long(candelas) then base_units = base_units + ')'
    endif
endif
;
return
end
