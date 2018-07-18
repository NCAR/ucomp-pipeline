;+
; Project     :	STEREO
;
; Name        :	WCS_PARSE_UNITS_BASE
;
; Purpose     :	Internal subroutine of WCS_PARSE_UNITS
;
; Category    :	FITS, Coordinates, WCS
;
; Explanation :	Called from WCS_PARSE_UNITS
;
; Syntax      :	WCS_PARSE_UNITS_BASE,UNITS_STRING,FACTOR,METERS,KILOGRAMS,$
;                       SECONDS,RADIANS,STERADIANS,KELVINS,AMPERES,MOLES, $
;                       CANDELAS
;
; Inputs      :	UNITS_STRING = String containing the units specification.
;
; Opt. Inputs :	None.
;
; Outputs     :	FACTOR = The conversion factor from the input units into the
;                        base units.
;
;               The remaining output parameters contain the power applied to
;               each basic unit.
;
; Opt. Outputs:	None.
;
; Keywords    :	QUIET   = Turn off informational messages
;
; Calls       :	WCS_PARSE_UNITS_BASE (recursive), WCS_RSUN, WCS_AU
;
; Common      :	None.
;
; Restrictions:	Functions log(), ln(), and exp() are not supported.
;
;               Because this routine is intended to be called only from
;               WCS_PARSE_UNITS, no error checking is performed.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 06-Jun-2005, William Thompson, GSFC
;               Version 2, 13-Jun-2005, William Thompson, GSFC
;                       Support sqrt(), and many non-standard unit strings
;               Version 3, 10-Dec-2008, WTT, call WCS_RSUN() and WCS_AU()
;               Version 4, 12-Dec-2008, WTT, added keyword /QUIET
;               Version 5, 04-Mar-2009, WTT, handle angular units properly
;                       Mainly used for combined units, e.g. "deg/s".
;
; Contact     :	WTHOMPSON
;-
;
;******************************************************************************
pro wcs_parse_units_power, pstring, power
;
;  Subroutine to parse the power string.
;
;  Start by removing beginning and end parentheses.
;
if strmid(pstring, 0, 1) eq '(' then $
  pstring = strmid(pstring, 1, strlen(pstring)-2)
;
;  Look for a slash character.  If found, then calculate the division.
;
slash = strpos(pstring,'/')
if slash lt 0 then power = float(pstring) else begin
    numerator   = float(strmid(pstring,0,slash))
    denominator = float(strmid(pstring,slash+1,strlen(pstring)-slash-1))
    power = numerator / denominator
endelse
;
;  If possible, simplify to an integer.
;
if power eq long(power) then power = long(power)
;
end
;******************************************************************************
;
pro wcs_parse_units_base, units_string, factor, meters, kilograms, seconds, $
                          radians, steradians, kelvins, amperes, moles,     $
                          candelas, quiet=quiet
on_error, 2
;
;  Initialize the factor, and the powers for each base unit.
;
factor     = 1d0
meters     = 0
kilograms  = 0
seconds    = 0
radians    = 0
steradians = 0
kelvins    = 0
amperes    = 0
moles      = 0
candelas   = 0
;
;  Remove any unnecessary white space.
;
units = strcompress( strtrim(units_string,2) )
;
;  Process the next word in the string, recognized by white space, by
;  asterisks, or by periods.
;
while units ne '' do begin
;
;  If the string starts with an open parenthesis, or with "SQRT(", find the
;  corresponding close parenthesis.
;
    sign = 1
check_for_brackets:
    root = strupcase(strmid(units,0,5)) eq 'SQRT('
    if root or (strmid(units, 0, 1) eq '(') then begin
        b = byte(units)
        w1 = where(b eq 41, n1)
        i = 0
        repeat begin
            w0 = where(b[0:w1[i]] eq 40, n0)
            i = i + 1
        endrep until (n0 eq i) or (n1 eq i)
        if i eq n0 then j = w1[i-1] else j = strlen(units)
        if root then subunits = strmid(units,5,j-5) else $
          subunits = strmid(units, 1, j-1)
        wcs_parse_units_base, subunits, factor1, meters1, kilograms1, $
          seconds1, radians1, steradians1, kelvins1, amperes1, moles1, $
          candelas1
        if root then begin
            factor1     = sqrt(factor1)
            meters1     = 0.5 * meters1
            kilograms1  = 0.5 * kilograms1
            seconds1    = 0.5 * seconds1
            radians1    = 0.5 * radians1
            steradians1 = 0.5 * steradians1
            kelvins1    = 0.5 * kelvins1
            amperes1    = 0.5 * amperes1
            moles1      = 0.5 * moles1
            candelas1   = 0.5 * candelas1
        endif
        if sign gt 0 then begin
            factor     = factor     * factor1
            meters     = meters     + meters1
            kilograms  = kilograms  + kilograms1
            seconds    = seconds    + seconds1
            radians    = radians    + radians1
            steradians = steradians + steradians1
            kelvins    = kelvins    + kelvins1
            amperes    = amperes    + amperes1
            moles      = moles      + moles1
            candelas   = candelas   + candelas1
        end else begin
            factor     = factor     / factor1
            meters     = meters     - meters1
            kilograms  = kilograms  - kilograms1
            seconds    = seconds    - seconds1
            radians    = radians    - radians1
            steradians = steradians - steradians1
            kelvins    = kelvins    - kelvins1
            amperes    = amperes    - amperes1
            moles      = moles      - moles1
            candelas   = candelas   - candelas1
        endelse
        units = strmid(units, j+1, strlen(units)-j-1)
        sign = 1
    endif
;
;  If the string starts with the / character, then check for an open
;  parenthesis again.
;
    if strmid(units, 0, 1) eq '/' then begin
        sign = -1
        units = strmid(units, 1, strlen(units)-1)
        goto, check_for_brackets
    endif
;
;  Find the first word.
;
    space  = strpos(units,' ')  &  if space  eq -1 then space  = strlen(units)
    aster  = strpos(units,'*')  &  if aster  eq -1 then aster  = strlen(units)
    period = strpos(units,'.')  &  if period eq -1 then period = strlen(units)
    closed = strpos(units,')')  &  if closed eq -1 then closed = strlen(units)
    slash  = strpos(units,'/')  &  if slash  eq -1 then slash  = strlen(units)
    sep = space < aster < period < closed < slash
    word = strmid(units, 0, sep)
;
;  If the word contains the "(" character, then find the corresponding ")"
;  character.
;
    if strpos(word,'(') ge 0 then begin
        b = byte(units)
        w1 = where(b eq 41, n1)
        i = 0
        repeat begin
            w0 = where(b[0:w1[i]] eq 40, n0)
            i = i + 1
        endrep until (n0 eq i) or (n1 eq i)
        if i eq n0 then sep = w1[i-1]+1 else sep = strlen(units)
        word = strmid(units,0,sep)
;
;  If the character after the close paranthesis is a blank, asterisk, or
;  period, then skip over it.
;
        char = strmid(units,sep,1)
        if (char eq ' ') or (char eq '*') or (char eq '.') then sep = sep + 1
    endif
;
;  Separate out the rest of the units.  If the separator is the slash
;  character, then include it.
;
    if strmid(units,sep,1) eq '/' then $
      units = strmid(units, sep, strlen(units)) else $
      units = strmid(units, sep+1, strlen(units))
;
;  Look for a power expression.
;
    power = 1
    psep = strpos(word, '**')
    if psep gt 0 then begin
        pstring = strmid(word, psep+2, strlen(word)-psep-2)
        wcs_parse_units_power, pstring, power
        word = strmid(word, 0, psep)
    endif
;
    psep = strpos(word, '^')
    if psep gt 0 then begin
        pstring = strmid(word, psep+1, strlen(word)-psep-1)
        wcs_parse_units_power, pstring, power
        word = strmid(word, 0, psep)
    endif
;
    psep = strpos(word, '(')
    if psep gt 0 then begin
        pstring = strmid(word, psep+1, strlen(word)-psep-2)
        wcs_parse_units_power, pstring, power
        word = strmid(word, 0, psep)
    endif
;
    psep = strpos(word, '+')
    if psep gt 0 then begin
        pstring = strmid(word, psep, strlen(word)-psep)
        wcs_parse_units_power, pstring, power
        word = strmid(word, 0, psep)
    endif
;
    psep = strpos(word, '-')
    if psep gt 0 then begin
        pstring = strmid(word, psep, strlen(word)-psep)
        wcs_parse_units_power, pstring, power
        word = strmid(word, 0, psep)
    endif
;
;  Apply the sign.
;
    power = power * sign
;
;  Try to recognize the word.  The correct standard is marked in each case.
;
times_through = 0
factor1 = 1d0
;
recognize_word:
lword = strlowcase(word)
if (word eq '*') or (word eq '.') then begin    ;Extraneous spaces
    dummy = 0
end else if word eq '/' then begin              ;Extraneous spaces
    units = '/' + units
end else if word eq '10' then begin             ;General multiplier
    factor = factor * (1d1)^power
end else if (word eq 'm') or (lword eq 'meter') or (lword eq 'meters') $
  then begin                                    ;meter (std: m)
    meters = meters + power
end else if (word eq 'g') or (lword eq 'gram') or (lword eq 'grams') $
  then begin                                    ;gram (std: g)
    kilograms = kilograms + power
    factor = factor * (1d-3)^power
end else if (word eq 's') or (lword eq 'sec') or (lword eq 'second') or $
  (lword eq 'seconds') then begin               ;second (std: s)
    seconds = seconds + power
end else if (lword eq 'rad') or (lword eq 'radian') or (lword eq 'radians') $
  then begin                                    ;radian (std: rad)
    radians = radians + power
end else if (strmid(lword,0,3) eq 'deg') then begin ;degrees (std: deg)
    factor = factor * !dpi / 180.d0
    radians = radians + power
end else if (strmid(lword,0,6) eq 'arcmin') then begin ;arcmin (std: arcmin)
    factor = factor * !dpi / 180.d0 / 60.d0
    radians = radians + power
end else if (strmid(lword,0,6) eq 'arcsec') then begin ;arcsec (std: arcsec)
    factor = factor * !dpi / 180.d0 / 3600.d0
    radians = radians + power
end else if (lword eq 'mas') then begin         ;milli-arcsec (std: mas)
    factor = factor * !dpi / 180.d0 / 3600.d3
    radians = radians + power
end else if (word eq 'sr') or (lword eq 'sterad') or (lword eq 'steradian') $
  or (lword eq 'steradians') then begin         ;steradian (std: sr)
    steradians = steradians + power
end else if (word eq 'K') or (lword eq 'kelvin') or (lword eq 'kelvins') $
  then begin                                    ;kelvins (std: K)
    kelvins = kelvins + power
end else if (word eq 'A') or (lword eq 'ampere') or (lword eq 'amperes') $
  then begin                                    ;ampere (std: A)
    amperes = amperes + power
end else if (word eq 'mol') or (lword eq 'mole') or (lword eq 'moles') $
  then begin                                    ;mole (std: mol)
    moles = moles + power
end else if (word eq 'cd') or (lword eq 'candela') or (lword eq 'candelas') $
  then begin                                    ;candela (std: cd)
    candelas = candelas + power
end else if (lword eq 'hz') or (lword eq 'hertz') then begin
    seconds = seconds - power                   ;hertz (std: Hz)
end else if (word eq 'J') or (lword eq 'joule') or (lword eq 'joules') $
  then begin                                    ;joule (std: J)
    kilograms = kilograms + power
    meters = meters + 2*power
    seconds = seconds - 2*power
end else if (word eq 'W') or (lword eq 'watt') or (lword eq 'watts') then begin
    kilograms = kilograms + power               ;watt (std: W)
    meters = meters + 2*power
    seconds = seconds - 3*power
end else if (word eq 'V') or (lword eq 'volt') or (lword eq 'volts') then begin
    kilograms = kilograms + power               ;volt (std: V)
    meters = meters + 2*power
    seconds = seconds - 3*power
    amperes = amperes - power
end else if (word eq 'N') or (lword eq 'newton') or (lword eq 'newtons') $
  then begin                                    ;newton (std: N)
    kilograms = kilograms + power
    meters = meters + power
    seconds = seconds - 2*power
end else if (word eq 'C') or (lword eq 'coulomb') or (lword eq 'coulombs') $
  then begin                                    ;coulomb (std: C)
    amperes = amperes + power
    seconds = seconds + power
end else if (lword eq 'ohm') or (lword eq 'ohms') then begin
    kilograms = kilograms + power               ;ohm (std: Ohm)
    meters = meters + 2*power
    seconds = seconds - 3*power
    amperes = amperes - 2*power
end else if (word eq 'S') or (lword eq 'siemen') or (lword eq 'siemens') $
  then begin                                    ;siemen (std: S)
    kilograms = kilograms - power
    meters = meters - 2*power
    seconds = seconds + 3*power
    amperes = amperes + 2*power
end else if (word eq 'F') or (lword eq 'farad') or (lword eq 'farads') $
  then begin                                    ;farad (std: F)
    kilograms = kilograms - power
    meters = meters - 2*power
    seconds = seconds + 4*power
    amperes = amperes + 2*power
end else if (lword eq 'wb') or (lword eq 'weber') or (lword eq 'webers') $
  then begin                                    ;weber (std: Wb)
    kilograms = kilograms + power
    meters = meters + 2*power
    seconds = seconds - 2*power
    amperes = amperes - power
end else if (word eq 'T') or (lword eq 'tesla') or (lword eq 'teslas') $
  then begin                                    ;tesla (std: T)
    kilograms = kilograms + power
    seconds = seconds - 2*power
    amperes = amperes - power
end else if (word eq 'H') or (lword eq 'henry') or (lword eq 'henrys') $
  then begin                                    ;henry (std: H)
    kilograms = kilograms + power
    meters = meters + 2*power
    seconds = seconds - 2*power
    amperes = amperes - 2*power
end else if (word eq 'lm') or (lword eq 'lumen') or (lword eq 'lumen') $
  then begin                                    ;lumen (std: lm)
    candelas = candelas + power
    steradians = steradians + power
end else if (word eq 'lx') or (lword eq 'lux') then begin
    candelas = candelas + power                 ;lux (std: lx)
    steradians = steradians + power
    meters = meters - 2*power
end else if (lword eq 'min') or (lword eq 'minute') or (lword eq 'minutes') $
  then begin                                    ;minute (std: min)
    seconds = seconds + power
    factor = factor * (6d1)^power
end else if (word eq 'h') or (word eq 'hr') or (lword eq 'hour') or $
  (lword eq 'hours') then begin                 ;hour (std: h)
    seconds = seconds + power
    factor = factor * (3.6d3)^power
end else if (word eq 'd') or (lword eq 'day') or (lword eq 'days') then begin
    seconds = seconds + power                   ;day (std: d)
    factor = factor * (8.64d4)^power
end else if (word eq 'yr') or (word eq 'a') or (lword eq 'year') or $
  (lword eq 'years') then begin                 ;year (Julian, std: yr or a)
    seconds = seconds + power
    factor = factor * (3.15576d7)^power
end else if word eq 'eV' then begin             ;electron volt
    kilograms = kilograms + power
    meters = meters + 2*power
    seconds = seconds - 2*power
    factor = factor * (1.6021765d-19)^power
end else if (lword eq 'erg') or (lword eq 'ergs') then begin
    kilograms = kilograms + power               ;erg (std: erg)
    meters = meters + 2*power
    seconds = seconds - 2*power
    factor = factor * (1d-7)^power
end else if (word eq 'Ry') or (lword eq 'rydberg') or (lword eq 'rydbergs') $
  then begin                                    ;rydberg (std: Ry)
    kilograms = kilograms + power
    meters = meters + 2*power
    seconds = seconds - 2*power
    factor = factor * (1.6021765d-19*13.605692d0)^power
end else if lword eq 'solmass' then begin       ;solar masses (std: solMass)
    kilograms = kilograms + power
    factor = factor * (1.9891d30)^power
end else if word eq 'u' then begin              ;atomic mass units
    kilograms = kilograms + power
    factor = factor * (1.6605387d-27)^power
end else if lword eq 'sollum' then begin        ;solar luminosity (std: solLum)
    kilograms = kilograms + power
    meters = meters + 2*power
    seconds = seconds - 3*power
    factor = factor * (3.8268d26)^power
end else if (lword eq 'angstrom') or (lword eq 'angstroms') then begin
    meters = meters + power                     ;Angstrom (std: Angstrom)
    factor = factor * (1d-10)^power
end else if lword eq 'solrad' then begin        ;solar radius (std: solRad)
    meters = meters + power
    factor = factor * wcs_rsun()^power
end else if word eq 'AU' then begin             ;astronomical unit
    meters = meters + power
    factor = factor * wcs_au()^power
end else if (word eq 'lyr') or (lword eq 'lightyear') or $
  (lword eq 'lightyears') then begin            ;lightyear (std: lyr)
    meters = meters + power
    factor = factor * (9.460730d15)^power
end else if (word eq 'pc') or (lword eq 'parsec') or (lword eq 'parsecs') $
  then begin                                    ;parsec (std: pc)
    meters = meters + power
    factor = factor * (3.0857d16)^power
end else if (word eq 'Jy') or (lword eq 'jansky') or (lword eq 'janskys') $
  then begin                                    ;jansky (std: 'Jy')
    kilograms = kilograms + power
    seconds = seconds - 2*power
    factor = factor * (1d-26)^power
end else if (word eq 'R') or (lword eq 'rayleigh') or (lword eq 'rayleighs') $
  then begin                                    ;rayleigh (std: R)
    meters = meters - 2*power
    seconds = seconds - power
    steradians = steradians - power
    factor = factor * (2.5d9/!dpi)^power
end else if (word eq 'G') or (lword eq 'gauss') then begin
    kilograms = kilograms + power               ;gauss (std: G)
    seconds = seconds - 2*power
    amperes = amperes - power
    factor = factor * (1d-4)^power
end else if (lword eq 'barn') or (lword eq 'barns') then begin
    meters = meters + 2*power                   ;barn (std: barn)
    factor = factor * (1d-28)^power
end else if (word eq 'D') or (lword eq 'debye') or (lword eq 'debyes') $
  then begin                                    ;debye (std: D)
    amperes = amperes + power
    seconds = seconds + power
    meters = meters + power
    factor = factor * (1d-29/3d0)^power
;
;  Standard dimensionless units.
;
;       mag = stellar magnitude
;       Sun = relative to Sun (e.g. abundances)
;
end else if (word eq 'mag') or (word eq 'pixel') or (word eq 'pix') or $
  (word eq 'count') or (word eq 'ct') or (word eq 'photon') or $
  (word eq 'ph') or (word eq 'Sun') or (word eq 'chan') or (word eq 'bin') or $
  (word eq 'voxel') or (word eq 'bit') or (word eq 'byte') or $
  (word eq 'adu') or (word eq 'beam') then begin
    dummy=0
;
;  If not recognized, and the first time through, try seeing if the units can
;  be recognized as a prefix plus word.
;
end else begin
    if times_through ne 0 then begin
        factor1 = 1d0
        if not keyword_set(quiet) then message, /informational, $
          'Unrecognized unit string ' + orig_word
    end else begin
        times_through = 1
        orig_word = word
;
;  Look for non-standard prefixes.
;
        if strmid(lword,0,4) eq 'deci' then begin
            factor1 = 1d-1
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'centi' then begin
            factor1 = 1d-2
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'milli' then begin
            factor1 = 1d-3
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'micro' then begin
            factor1 = 1d-6
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'nano' then begin
            factor1 = 1d-9
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'pico' then begin
            factor1 = 1d-12
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'femto' then begin
            factor1 = 1d-15
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'atto' then begin
            factor1 = 1d-18
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'zepto' then begin
            factor1 = 1d-21
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'yocto' then begin
            factor1 = 1d-24
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'deca' then begin
            factor1 = 10d0
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'hecto' then begin
            factor1 = 1d2
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'kilo' then begin
            factor1 = 1d3
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'mega' then begin
            factor1 = 1d6
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'giga' then begin
            factor1 = 1d9
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'tera' then begin
            factor1 = 1d12
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,4) eq 'peta' then begin
            factor1 = 1d15
            word = strmid(word, 4, strlen(word)-4)
            goto, recognize_word
        end else if strmid(lword,0,3) eq 'exa' then begin
            factor1 = 1d18
            word = strmid(word, 3, strlen(word)-3)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'zetta' then begin
            factor1 = 1d21
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
        end else if strmid(lword,0,5) eq 'yotta' then begin
            factor1 = 1d24
            word = strmid(word, 5, strlen(word)-5)
            goto, recognize_word
;
;  Look for the standard prefixes.
;
        end else if strmid(word,0,2) eq 'da' then begin
            factor1 = 10d0
            word = strmid(word, 2, strlen(word)-2)
            goto, recognize_word
        end else begin
            case strmid(word,0,1) of
                'd': factor1 = 1d-1 ;deci
                'c': factor1 = 1d-2 ;centi
                'm': factor1 = 1d-3 ;milli
                'u': factor1 = 1d-6 ;micro
                'n': factor1 = 1d-9 ;nano
                'p': factor1 = 1d-12 ;pico
                'f': factor1 = 1d-15 ;femto
                'a': factor1 = 1d-18 ;atto
                'z': factor1 = 1d-21 ;zepto
                'y': factor1 = 1d-24 ;yocto
                'h': factor1 = 1d2 ;hecto
                'k': factor1 = 1d3 ;kilo
                'M': factor1 = 1d6 ;mega
                'G': factor1 = 1d9 ;giga
                'T': factor1 = 1d12 ;tera
                'P': factor1 = 1d15 ;peta
                'E': factor1 = 1d18 ;exa
                'Z': factor1 = 1d21 ;zetta
                'Y': factor1 = 1d24 ;yotta
                else: dummy=0
            endcase
            if factor1 ne 1d0 then begin
                word = strmid(word, 1, strlen(word)-1)
                goto, recognize_word
            endif
        endelse
    endelse
endelse
;
;  Apply factor1, and continue to the next word.
;
    if factor1 ne 1d0 then factor = factor * factor1^power
endwhile
;
return
end
