;+
;   Procedure: TAI2_SEC1979
;
;   Purpose:  This function converts an array of seconds with ref to 1-jan-1958
;     including leap seconds to an array referenced to 1-jan-1979


;   History;
;       11-jan-2006, richard.schwartz@gsfc.nasa.gov
;-

function tai2_sec1979, tai

  get_leap_sec, leapmjd
  nel = n_elements( leapmjd )
  leaptai = 86400.0d0 * ( leapmjd  - 36203L ) + 10+lindgen(nel)

  leap = lonarr( 2, nel)
  leap[0,0] = reform( leaptai, 1, nel)
  leap[1,0] = 10L + lindgen(1,nel)
  ;help, mjd
  nel = nel - 1L
  if since_version('5.3') then $
    s   = value_locate( leap[0,*], tai) > 0 < nel $
  else $
    s =  find_ix( reform(leap[0,*]), tai) >0 <nel
  out = tai - leap[1,s]  - 6.6268800d8
  return, out
end
;+
;   Procedure: SEC1979_2TAI
;
;   Purpose:  This function converts an array of seconds with ref to 1-jan-1979
;     to an array referenced to 1-jan-1958 plus leap seconds


;   History;
;       11-jan-2006, richard.schwartz@gsfc.nasa.gov
;-
function sec1979_2tai, sec1979

  get_leap_sec, leapmjd
  nel = n_elements( leapmjd )

  leap = lonarr( 2, nel)
  leap[0,0] = reform( leapmjd, 1, nel)
  leap[1,0] = 10L + lindgen(1,nel)

  mjd = long(sec1979/86400.d0)  +43873L
  nmjd = n_elements(mjd)
  mjd = (nmjd eq 1)? mjd + lonarr(2) : mjd

  nel = nel - 1L
  if since_version('5.3') then $
    s   = value_locate( leap[0,*], mjd) > 0 < nel      else $
    s = find_ix( reform(leap[0,*]), mjd) >0 <nel

  s = nmjd le 1 ? s[0] : s
  out = sec1979 + leap[1,s]  + 6.6268800d8
  return, out
end
;+
;   Procedure: ANYTIM_SEC_TEST
;
;   Purpose: This function returns 1 if it detects an anytim seconds format.
;-
function anytim_sec_test, input, ordinate, error=error

  on_error, 2
  error = 1      ;ras 18-nov-93; tbd

  isz = not is_struct(input) ? size(/struct, input ) : $
    tag_names(input,/str) eq 'IDL_SIZE'? isz : size(/str,input)
  osz = not is_struct(ordinate) ? size(/struct, ordinate ) : $
    tag_names(ordinate,/str) eq 'IDL_SIZE'? isz : size(/str,ordinate)
  typnam = isz.type_name
  is_sec = 0
  ;Check the input, looking for String, Struct, Integer type, Float type, Scalar, or Array
  ;in_style = 'SEC' ;default
  ;in_style = typnam eq 'STRUCT' or typnam eq 'STRING'
  is_int = max(typnam eq ['UINT','INT','LONG','ULONG','ULONG64','LONG64'] )
  ;is_string = typnam eq 'STRING'
  ;is_struct = typnam eq 'STRUCT'
  is_sec    = max( typnam eq ['DOUBLE','FLOAT'])
  ;It may still be sec if IS_INT is set.  If not 2xN or 7xN then it's sec as well
  If IS_INT then begin
    is_sec    = 1
    ;Unless
    case isz.n_dimensions of
      0 :
      1 : begin
        nord   = osz.n_elements > 1
        is_sec = min(abs(nord*[2ll,7ll] - isz.n_elements)) ne 0

      end
      2 : is_sec = min(abs(isz.dimensions[0]-[2,7])) ne 0
      else:
    endcase
  endif

  error=0
  return, byte(is_sec)
end

;
;+
;NAME:
;   anytim
;PURPOSE:
;   This function converts one of several recognized time formats into the selected
;   output format.
;
;CALLING SEQUENCE:
;       xx = anytim(roadmap, out_styl='ints')
;       or
;       xx = anytim(roadmap, /INTS)
;
;       xx = anytim('12:33 5-Nov-91', out_sty='ex')
;       or
;       xx = anytim('12:33 5-Nov-91', /EX)
;
;       xx = anytim('12:33 91/11/5',/EX)
;
;
;       xx = anytim([0, 4000], out_style= 'sec')
;       or
;       xx = anytim([0, 4000], /SEC)
;
;CATEGORY:
;   Time, Utplot, time conversions
;INPUT:
;   item  - The input time
;       Form can be
;      (1) structure with a .time and .day
;       tags, those tags may also appear in a .gen tag
;       which is the first tag of the top structure,
;       if one element in structure, will return scalar output
;       for 1-d datatypes,  or
;      (2) the standard 7-element longword external (EX) representation [hh,mm,ss,msec,dd,mm,(yy)yy],
;       or (3) a string of the format "hh:mm dd-mmm-yy" or "yy/mm/dd",
;       or (4) a 2xN array where the two dimensions hold (MSOD, DS79),
;       .i.e. (MilliSecondsOfDay, DaySince 1-jan-1979), so called Internal Structure (INTS),
;          1-jan-1979 is {anytim2ints_full, time:0L, day:1L}
;
;       or (5) a double or float array of seconds from 1-jan-79.
;       1-d, single time element inputs, the EX or array form of INTS, i.e.
;      size(item) is   [ 1, 7, 2, 7] or [1, 2, 3, 2] return scalar results for
;       /sec output.
;       N.B.  Within other SSW procedures, notably those of CDS and probably others, the epoch
;      for double(single) precision seconds is NOT 00:00:00.00 1 January 1979.  This
;      function DOES NOT work properly with times relative to other epochs.  To work with
;      times with other epochs, there is normally a conversion routine to put the
;      time in unversal format, such as the UTC_INT or UTC_EXT format. Please see
;      the aaareadme.txt file in $SSW/gen/idl/time/aaareadme.txt
;      You'll find many useful time handling routines in
;      $SSW/gen/idl/time, $SSW/gen/idl/genutil, $SSW/gen/idl/utplot,
;      $SSW/gen/idl_libs/astron/...
;
;   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;   N.B. 2 digit year representations in EX or String formats are interpreted between
;   years 1950 and 2049.
;   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;       The UTC procedures, utc2int, str2utc, and int2utc are included using
;   CALL_FUNCTION so anytim will compile and work without these routines
;   and their subsequent calls to procedures in the utc directory.
;   Allowed formats include those supported under UTC  code, see STR2UTC.PRO:
;        = A character string containing the date and time.  The
;        target format is the CCSDS ASCII Calendar Segmented
;        Time Code format (ISO 8601), e.g.
;
;          "1988-01-18T17:20:43.123Z"
;
;        The "Z" is optional.  The month and day can be
;        replaced with the day-of-year, e.g.
;
;          "1988-018T17:20:43.123Z"
;
;        Other variations include
;
;          "1988-01-18T17:20:43.12345"
;          "1988-01-18T17:20:43"
;          "1988-01-18"
;          "17:20:43.123"
;
;        Also, the "T" can be replaced by a blank, and the
;        dashes "-" can be replaced by a slash "/".  This is
;        the format used by the SOHO ECS.
;
;        In addition this routine can parse dates where only
;        two digits of the year is given--the year is assumed
;        to be between 1950 and 2049.
;
;        Character string months, e.g. "JAN" or "January", can
;        be used instead of the number.  In that case, it
;        assumes that the date is either in day-month-year or
;        month-day-year format, e.g. "18-JAN-1988" or
;        "Jan-18-1988".  However, if the first parameter is
;        four digits, then year-month-day is assumed, e.g.
;        "1988-Jan-18".
;
;        Dates in a different order than year-month-day are
;        supported, but unless the month is given as a
;        character string, then these are only supported
;        through the /MDY and /DMY keywords.
;
;   End UTC documentation
;
;OPTIONAL KEYWORD INPUT:
;   out_style - Output representation, specified by a string:.r ../anytim

;       INTS    - structure with [msod, ds79] - day 0 N.B. 31-dec-1978
;      IDL> help,/st,anytim('1-jan-1979',/ints)
;          ** Structure ANYTIM2INTS_FULL, 2 tags, length=8, data length=8:
;             TIME            LONG                 0
;             DAY             LONG                 1
;     STC     - same as INTS
;           2XN        - longword array [msod,ds79] X N
;           EX         - 7 element external representation (hh,mm,ss,msec,dd,mm,yyyy)
;     UTIME    - Utime format, Real*8 seconds since 1-jan-79, DEFAULT!!!!
;               SEC     - same as Utime format
;               SECONDS - same as Utime format
;     TAI  - standard seconds from 1-jan-1958.  Includes leap seconds unlike "SECONDS" output.
;      NB- The TAI format cannot be used as an input to ANYTIM because it will be interpreted as
;      number of days (in seconds) from 1-jan-1979.
;     ATIME   - Variable Atime format, Yohkoh
;        Yohkoh style - 'dd-mon-yy hh:mm:ss.xxx'   or
;        HXRBS pub style  - 'yy/mm/dd, hh:mm:ss.xxx'
;        depending on atime_format set by
;        hxrbs_format or yohkoh_format
;     YOHKOH  - yohkoh style string
;     HXRBS   - HXRBS Atime format /pub, 'yy/mm/dd, hh:mm:ss.xxx'
;               YY/MM/DD- same as HXRBS
;     MJD     - UTC-type structure
;      = The UTC date/time as a data structure with the
;        elements:
;
;          MJD    = The Modified Julian Day number
;          TIME   = The time of day, in milliseconds
;               since the start of the day.
;
;        Both are long integers.
;     UTC_INT - Same as MJD
;     UTC_EXT - UTC external format, a structure
;               containing the elements, YEAR, MONTH, DAY, HOUR, MINUTE,
;               SECOND, and MILLISECOND as shortword integers.
;     CCSDS   - A string variable containing the calendar date in the
;       format recommended by the Consultative Committee for
;       Space Data Systems (ISO 8601), e.g.
;
;          "1988-01-18T17:20:43.123Z"
;
;     ECS     - A variation on the CCSDS format used by the EOF Core
;       System.  The "T" and "Z" separators are eliminated, and
;       slashes are used instead of dashes in the date, e.g.
;
;          "1988/01/18 17:20:43.123"
;
;     VMS     - Similar to that used by the VMS operating system, this
;       format uses a three-character abbreviation for the
;       month, and rearranges the day and the year, e.g.
;
;          "18-JAN-1988 17:20:43.123"
;
;     STIME   - Based on !STIME in IDL, this format is the same as the
;       second accuracy, e.g.
;       VMS format, except that the time is only given to 0.01
;       second accuracy, e.g.
;
;          "18-JAN-1988 17:20:43.12"
;     SYSTEM  -  Based on IDL's system time, seconds from 1-jan-1970
;     TAI   - another seconds from time specification. This time from
;     1-jan-1958 including leap seconds
;
;   or by keywords
;     /ints   -
;           /stc
;     /_2xn
;     /external
;     /utime
;     /seconds
;     /atimes
;     /yohkoh
;     /hxrbs
;     /yymmdd
;     /mjd
;     /utc_int
;     /utc_ext
;     /ccsds
;     /ecs
;     /vms
;     /stime
;     /TAI
;
;   mdy   - If set, use the MM/DD/YY order for converting the string date
;
;     date_only - return only the calendar date portion,
;                     e.g. anytim('93/6/1, 20:00:00',/date_only,/hxrbs) ==> '93/06/01'
;     time_only - return only the time of day portion
;                     e.g. anytim('93/6/1, 20:00:00',/time_only,/hxrbs) ==> '20:00:00.000'
;   truncate - truncate the msec portion of the time displayed in strings.
;   FIDUCIAL - string input
;     If the string contains 'tai' or 'sys' then the fiducial used to interpret
;     seconds input and output is changed from the default one of 1-jan-1979 to
;     1-jan-1958 or 1-jan-1970 respectively.  Otherwise the 1-jan-1979 epoch is
;     used to reference double precision floating point values.
;   ORDINATE - the number of elements in this variable is compared to the number of elements
;     in item if item is an integer format. If the ratio of number of elements is 2 or 7 then
;     the routine will interpret item as being in the 2xN or 7xN formats
;keyword output:
;   error - set if an error, dummy for now, ras 18-Nov-93
;restrictions:
;   one dimensional or scalar longwords will be interpreted as
;   double precision seconds unless they have either two or seven
;   elements
;       Should not be used to interpret an array of mixed string formats.
;       If the formats are mixed then the array should be processed element by element.
;HISTORY:
;   Written 31-Oct-93 ras
;   modified 4-jan-94 ras, made argument recognition more robust
;     also made output dimensions similar for /yohkoh  and /hxrbs
;   modified 25-jan-94 ras, made SEC or SECONDS work
;   ras 30-jan-94, fixed string outputs for /date and /time
;   ras 9-feb-94, fixed typo
;   ras 15-jun-1995, integrated Bill Thompson's UTC formats, for input and output
;     start adjusting to 4 digit years
;   ras, 20-jun-1995, put calls to utc functions inside call_function to reduce need
;   to include utc directories, default structure is Yohkoh as before,
;   utc structures are tested for explicitly
;       ras, 23-jun-1995, stopped searching for 'T' to identify CCSDS format, now 'Z'
;      made sear for 4 digit year more exacting
;   ras, 28-jul-95, restored item using item_old if necessary
;   Version 11, ras, 27-mar-1997, added truncate keyword
;   Version 12, ras, 16-jul-1997, fixed truncation problem with date strings
;   using atime, yohkoh, hxrbs, or yymmdd keywords.
;   Version 13, richard.schwartz@gsfc.nasa.gov
;     1. Supports input and output of 4 digit years.
;     2. Longword support on all integer day structures.
;     3. No modulo reduction of ex year format.
;     4. Simplify structure checking for input.
;   Version 14, richard.schwartz@gsfc.nasa.gov, 24-oct-1997, cleared bug in checking tags
;   in structure inhibiting finding of yohkoh gen tag.  Bug put in on mod 13.
;   Version 15, richard.schwartz@gsfc.nasa.gov, 28-oct-1997, DATE and TRUNCATE
;   keywords can be used together with vms, ecs, and stime output format
;   without producing null strings, same effect as using only DATE keyword.
;   Version 16, richard.schwartz@gsfc.nasa.gov, 30-oct-1997, change
;   time and date keywords to time_only and date_only for consistency
;   with SSW/gen/idl/time routines by W. Thompson.
;   Version 17, richard.schwartz@gsfc.nasa.gov, 16-Mar-1998, scalar output for EX format
;   in only 1-D array.
;   Version 18, richard.schwartz@gsfc.nasa.gov, 20-Apr-1998, added TAI output and supports
;       'hh:mm:ss.xxx yy/mm/dd' now.
;       Version 19, richard.schwartz@gsfc.nasa.gov, 13-aug-1998, route 4+ month strings to STR2UTC.
;   Version 20, richard.schwartz@gsfc.nasa.gov, 9-sep-1998, converts 2 digit years in EXternal format to
;   4 digit years using 1950-2049 window.
;   Version 21, richard.schwartz@gsfc.nasa.gov, 24-oct-1998, passes double and single precision seconds through
;   unchanged except float converted to double.
;   Version 22, richard.schwartz@gsfc.nasa.gov, 12-nov-1999, uses error code in str2utc to trap errors for that
;   function.
;   Version 23, richard.schwartz@gsfc.nasa.gov, 15-dec-1999, handle strings like dd/mon/yy with STR2UTC.
;   Version 23, richard.schwartz@gsfc.nasa.gov, 20-jun-2000.  Fixed problem with non 1d structures. Now
;   it can handle them and return the same dimensions.
;   Version 24, richard.schwartz@gsfc.nasa.gov, 16-feb-2001. Made compatible with new timstr2ex.
;   Version 25, richard.schwartz@gsfc.nasa.gov, 2-apr-2001. Use input dimensions for output as default
;   when possible, that is for all input/output formats except 2xN and 7xN int and longword. Also, treat
;   single element string arrays as scalars for output.
;   Version 26, richard.schwartz@gsfc.nasa.gov, 14-jun-2001. unsigned and double long integers
;   are now supported identically to normal integers within anytim.
;   1-jul-2001, richard.schwartz@gsfc.nasa.gov, replace [0] with (0)
;   2-jul-2002, richard.schwartz@gsfc.nasa.gov, changed documentation re fiducial for
;     INTS (STC) output and input formats.
;   8-sep-2005, richard.schwartz@gsfc.nasa.gov, fix longword input for seconds roundoff
;     problem.
;   21-dec-2005, richard.schwartz@gsfc.nasa.gov, added FIDUCIAL to allow switching
;     time bases from idl system of 1-jan-1970, to hxrbs standard 1-jan-1979, or tai system
;     starting 1-jan-1958 but including leap seconds
;   6-jan-2006, added test routine for determining seconds input format. Assumes that floats and
;     doubles are seconds as before, organizes the acceptance of integer formats better. Integers
;     are accepted as long as they aren't blocked 2xN or 7xN which are assumed to be special
;     integer formats EXTERNAL and _2xn, added keyword ordinate which can be used
;     with item to eliminate ambiguity of the integer formats.
;   19-may-2016, richard.schwartz@nasa.gov, removed parens on array calls, used standard code formatting
;   26-May-2016, richard.schwartz@nasa.gov, convert parens for indexing to square brackets, and format
;     (Ctrl shift F) for nicer indenting
;-
;-
;

function anytim, item, out_style=out_style, mdy=mdy, $
  ints=ints, stc=stc, _2xn=_2xn, external=external, utime=utimes, $
  seconds=sec, atimes=atimes,yohkoh=yohkoh,  hxrbs=hxrbs, yymmdd=yymmdd, $
  date_only=date, time_only=time, mjd=mjd, utc_int=utc_int, utc_ext=utc_ext, ccsds=ccsds, $
  ecs=ecs, vms=vms, stime=stime, truncate=truncate, tai=tai, system=system,$
  fiducial=fiducial, ordinate=ordinate, $
  error=error

  on_error, 2
  error = 1      ;ras 18-nov-93; tbd

  ;offset between Modified Julian Days and days since 1-jan-1979
  mjd_fiducial = 43873L

  sec_ref = 0.0d0
  fid_used='HXRBS'
  sys_ref = 2.8399680d8
  if datatype(fiducial) eq 'STR' then case 1 of
  strpos(strupcase(fiducial), 'TAI') ne -1: begin
    fid_used='TAI'
    ;sec_ref = -6.6268800d8  ;1-jan-1958 utc
  end
  strpos(strupcase(fiducial), 'SYS') ne -1: begin
    fid_used='SYSTEM'

    sec_ref = 0 - sys_ref  ;1-jan-1970 utc
  end
  else: sec_ref=0.0d0
endcase
use_fid = 0
if sec_ref ne 0 then use_fid =1
;error checking on EX vector
;ex is hh,mm,ss,msec,dd,mm,yy
;exrange= reform( [0,23,0,59,0,59,0,999,1,31,1,12,0,99], 2,7)
;4 digit years in future, ras, 15-jun-1995
exrange= reform( [0,23,0,59,0,59,0,999,1,31,1,12,0,9999], 2,7)

typ = datatype(item[0])
is_int = (where_arr(['UIN','INT','LON','ULO','U64','L64'],typ))(0) ne -1
siz = size(item)

sec_input = anytim_sec_test( item, ordinate)

if ( siz[0] eq 0 )       or $
  ( typ eq 'STC' and siz[1] eq 1)  or $
  ( typ eq 'STR' and siz[1] eq 1)  or $               ;Version 25
  ( IS_INT and siz[0] eq 1 and (siz[1] eq 7 or siz[1] eq 2)) $
  then scalar=1 else scalar =0
if not sec_input then begin
  ;  Find the input format class
  case 1 of
    is_int: in_style = 'INT'
    typ eq 'STC' : in_style = 'STRUCT'
    typ eq 'STR' : in_style = 'STRING'
    else: in_style = 'SEC'
  endcase
endif else in_style = 'SEC'
;Convert to EX representation unless input and output are double precision and /sec or /utime
;
;  Choose the output format

checkvar, out_style, 'UTIME'

out = strupcase(out_style)

if keyword_set(utimes) then out = 'UTIME'
if keyword_set(sec) then out = 'SEC'
if keyword_set(atimes) then out = 'ATIME'
if keyword_set(external) then out = 'EX'
if keyword_set(ints) then out = 'INTS'
if keyword_set(stc) then out = 'STC'
if keyword_set(_2xn) then out = '2XN'
if keyword_set(hxrbs) then out = 'HXRBS'
if keyword_set(yymmdd) then out = 'YY/MM/DD'
if keyword_set(yohkoh) then out = 'YOHKOH'
if keyword_set(mjd)  or keyword_set(utc_int) then out = 'UTC_INT'
if keyword_set(utc_ext) then out='UTC_EXT'
if keyword_set(ccsds) then out='CCSDS'
if keyword_set(ecs) then out='ECS'
if keyword_set(vms) then out='VMS'
if keyword_set(stime) then out='STIME'
if keyword_set(tai) then out='TAI'       ;time in sec from 1-jan-1958 plus leap seconds
if keyword_set(system) then out='SYSTEM' ;time in sec from 1-jan-1970
if out eq 'MJD' then out = 'UTC_INT'

if fid_used eq 'tai' AND (out eq  'UTIME' or out eq 'SEC' or out eq 'SECONDS') then out = 'TAI'
;
; Check for seconds and out to preserve sub-millisecond timing.
;

just_seconds = (out eq  'UTIME' or out eq 'SEC' or out eq 'SECONDS' or out eq 'TAI' or out eq 'SYSTEM') $
  and in_style eq 'SEC'

if just_seconds and in_style eq 'SEC' and not keyword_set(date) and not keyword_set(time) then begin
  ;We have 9 possibilities

  case 1 of
    fid_used eq 'TAI'    : begin

      if out eq 'TAI' then result = item $
      else begin
        result = tai2_sec1979(item)
        result = out eq 'SYSTEM' ? result + sys_ref : result

      endelse

    end
    fid_used eq 'SYSTEM' : begin
      if out eq 'SYSTEM' then result = item $
      else begin
        result = item - sys_ref
        result = out ne 'TAI' ? result : sec1979_2tai( result)

      endelse
    end
    else: begin
      if out ne 'TAI' and out ne 'SYSTEM' then result = item $
      else begin
        result = sec1979_2tai(item)
        result = out eq 'TAI' ? result : item + sys_ref

      endelse
    end
  end
  result = scalar ? result[0] : reform(result, siz[1:siz[0]])
  result = size(/tname, result) eq 'DOUBLE' ? result : double(result)
  goto, valid_return ;error set to 0 and result is returned
endif

case 1 of
  (typ eq 'STC'): begin

    ;To support the UTC formats, we must check for and convert the two UTC structure formats
    ;their internal format with tags MJD and TIME and
    ;their external format with 7 tags.
    ;Check for Yohkoh structure tag names (day, time) $
    ;vs CDS structure tag names, (mjd,time), or (year,month,day,hour,minute,second,millisecond)
    result = item[*]
    tags = tag_names(item[0])
    ntags_mjd = 0
    ntags_day = 0
    w = where_arr( tags, str_sep('YEAR MONTH DAY HOUR MINUTE SECOND MILLISECOND',' '), ntags_ex)
    if ntags_ex ne 7 then begin
      w = where_arr( tags, ['MJD', 'TIME'], ntags_mjd)
      if ntags_mjd ne 2 then w = where_arr( tags, ['DAY', 'TIME'], ntags_day)
    endif

    case 1 of
      (ntags_ex eq 7) : begin
        ex = call_function('utc2int', item[*])  ;convert external to internal
        ;It's Modified Julian Day!
        result = utime2str(fltarr( n_elements(item)))
        result.time= ex[*].time
        result.day = ex[*].mjd - mjd_fiducial
      end
      (ntags_mjd eq 2) : begin
        ;It's Modified Julian Day!
        result = utime2str(fltarr( n_elements(item)))

        result.time = item[*].time
        result.day = item[*].mjd - mjd_fiducial
      end
      (ntags_day eq 2) :
      else: begin
        ;GEN TAG MUST BE FIRST FOR YOHKOH FORMAT!
        if tags[0] eq 'GEN' then w = where_arr( tag_names(item[0].gen), ['DAY', 'TIME'], ntags_day)

        if ntags_day ne 2 then begin
          message,/continue, 'Unrecognized time structure passed.
          goto, error_out
        endif
      end
    endcase

    int2ex, gt_time(result), gt_day(result), ex, /nomod
  end
  in_style eq 'SEC' : begin ;ras, 6-jan-2006
    ;    (typ eq 'DOU' or typ eq 'FLO') or $
    ;    ( IS_INT and ( (n_elements(item) eq 1) or $
    ;    (siz(0) eq 1 and (siz(1) ne 2 and siz(1) ne 7)))):  begin
    ;    ustr = utime2str( item, utbase=0.0)
    ;    ustr = utime2str( item(*), utbase=0.0)  ;ras, 4-jan-94
    case 1 of

      fid_used eq 'TAI': begin
        ex = mjd2any(/ex,tai2utc(1.0d0*item[*]))
      end
      else: begin
        ustr = utime2str( item[*],utbase=sec_ref)  ;ras, 8-sep-2005, prevent longword roundoff problem
        int2ex, ustr.time, ustr.day, ex, /nomod
      end
    endcase
  endcase

  (IS_INT  and n_elements(item) ge 2): begin
    case siz[1] of
      7: begin
        ex = item
        wshort = where( ex[6,*] lt 100, nshort)
        if nshort ge 1 then ex[6,wshort] = ex[6,wshort] + 1900 + 100 * ([0,1])(ex[6,wshort] lt 50)
      end

      2: int2ex, item[0,*], item[1,*], ex, /nomod
      else: begin
        Print, 'Not a valid input to Anytim! Error!'
        goto, error_out
      end
    endcase
  end

  (typ eq 'STR'): begin
    use_utc= 0  ;default is not to use UTC processing
    ;Look for UTC formats, check the first entry and assume the rest match!
    ;First look for the year month day delimiter, '-' or '/'

    delim = '-'
    nslash = 0
    delim_pos = strpos( item[*], delim)

    is_dash_diff_gt4 = where( (str_lastpos(item[*], delim) - delim_pos) gt 4, char4_month)

    wdelim_pos = where( delim_pos ne -1, ndash)
    if ndash eq 0 then begin      ;check for alternate delimiter '/'
      delim = '/'
      delim_pos = strpos( item[*], delim)
      wdelim_pos = where( delim_pos ne -1, nslash)
      ;
      ; Insert trap for dd/mon/yy where mon is a string like  DEC.  Send on to STR2UTC.
      if nslash gt 0 then $
        ;look for instances of /mon/ and send to str2utc
        is_dash_diff_gt4 = where( (str_lastpos(item, delim) - delim_pos) ge 4, char4_month)

    endif
    char4_month = char4_month < 1
    ;If there is a delimiter, then we must send 4 digit dates onto the UTC string converters
    ;until the Yohkoh time string converter, timstr2ex.pro, supports 4 digits completely
    ;and the HXRBS converter, utime.pro, supports 4 digits completely, ras 18-jun-1995
    ;Search for comma's first and convert them to spaces.
    result = byte( item[*] )
    comma_pos  = where( result eq (byte(','))(0), ncomma )
    if ncomma ge 1 then begin
      result[comma_pos] = (byte(' '))(0) ;replace with a space
      item_old = item[*]
      item = strcompress( result )
    endif
    year_4_digits = 0
    if ndash ge 1 or nslash ge 1 then begin
      result = str2arr( strcompress( strtrim( item[ wdelim_pos[0] ], 2) ), delim=' ')
      ;There can't be more than 2 elements separated by a space.
      if n_elements(result) gt 2 then goto, error_out   else begin
        test = result[0]
        if strpos(test,delim)  eq -1 then test=result[1]
        result = str2arr( test, delim=delim)
        lresult = strlen(result)

        w4 = where( lresult ge 4, n4more)
        if n4more ge 1 then begin
          result = result[ w4]
          for i=0,n4more - 1 do begin
            test = (byte(result[i]))(0:3)
            wdigits = where( test ge 48 and test le 57, nwdigits)
            if nwdigits eq 4 then year_4_digits =1
          endfor
        endif
      endelse
      result = str2arr( item[wdelim_pos[0]], delim=delim)
      any_zs = where( strpos( strupcase(item),(byte('Z'))(0)) ne -1, n_any_zs)
      ;Find the colon position, if the colon precedes the slash send it to the utc parser.
      colon_first = 0
      if not year_4_digits or n_any_zs then begin

        wcolon = (where( ((strpos(item[*], ':')+1)<1)  *  ((strpos(item[*],'/')+1)<1) , ncolon))(0)
        if ncolon ge 1 then colon_first = strpos(item[wcolon],':') lt strpos(item[wcolon],'/')
      endif

      if year_4_digits or n_any_zs or colon_first ge 1 or char4_month then begin
        ;Use UTC parsing until Yohkoh is upgraded to handle 4 digit numbers
        ;When Yohkoh software has 4 digit capability then pipe the "/"
        ;"-" formats to their more vector oriented routines instead of STR2UTC
        ;Look for commas, and make them blanks
        comma_pos  = strpos( item[*], ',' )
        any_commas = (where(comma_pos ne -1, ncomma))(0) ne -1
        ;if commas and 4 digits, clear the commas and process under UTC
        if any_commas then begin
          wcomma = where(comma_pos ne -1)
          result = item[wcomma]
          comma_pos = comma_pos[wcomma]
          for i=0,ncomma-1 do result[i] = $
            strmid( result[i],0,comma_pos[i]) $
            + ' ' + strmid( result[i],comma_pos[i]+1,strlen(result[i]))
          item[wcomma] = result
        endif
        errmsg = ''
        item_utc = call_function('str2utc', item[*], errmsg=errmsg )
        if keyword_set(errmsg) then goto, error_out
        result = utime2str(fltarr(n_elements(item_utc)))
        result.time = item_utc.time
        result.day = item_utc.mjd - mjd_fiducial
        int2ex, result.time, result.day, ex, /nomod
        use_utc = 1
        ;The time has been converted using UTC codes!!
      endif
    endif
    if not use_utc then begin

      if keyword_set(mdy) then begin; Special format!
        wyo_count = n_elements(item)
        wno_count = 0
        wyohkoh= indgen(wyo_count)
      endif else begin
        test = strpos(item[*],'-') ne -1
        wyohkoh = where( test, wyo_count)
        wnot    = where( test ne 1, wno_count)
      endelse

      ;Interpret all Yohkoh strings,
      ;   Although Utime will support simple Yohkoh strings,
      ;   it doesn't support reverse order and 4 digits for the year, ie 1993
      ;   For the moment, 1-Nov-93, all Yohkoh strings interpreted here

      if wyo_count ge 1 then begin
        ex1 = timstr2ex( item[ wyohkoh ],mdy=mdy )
        ;These are all 2 digit times, which by default are interpreted
        ;from 1950-2049.  Correct them to 4 digit times.
        w = where( ex1[6,*] ge 50 and ex1[6,*] lt 1000, nw)
        if nw gt 0 then ex1[6,w] = ex1[6,w] + 1900
        w = where( ex1[6,*] le 49, nw)
        if nw gt 0 then ex1[6,w] = ex1[6,w] + 2000

        ;Check for errors in Yohkoh string interpretation
        for i=0,6 do begin
          out_of_range= where( ex1[i,*] lt exrange[0,i] or ex1[i,*] gt $
            exrange[1,i], num_out)
          if num_out ge 1 then begin
            Print, 'Error in Yohkoh string interpretation out of Timstr2ex,'
            Print, 'Could not interpret - ',(item[wyohkoh])(out_of_range)
            Print, 'Correct input format:'
            Print, '4-Jan-91 22:00:15.234, range is 1-jan-(19)50 to 31-dec-(20)49'
            goto, error_out
          endif
        endfor
      endif
      ;Interpret HXRBS style strings and strings w/o dates, 'yy/mm/dd, hh:mm:ss.xxx'
      if wno_count ge 1 then begin
        ut = utime( item[wnot], error=error_utime )        ;not yet if ever, mdy=mdy )
        if error_utime then begin
          Print, 'Error in HXRBS string interpretation by Utime'
          Print, 'Could not interpret - ',(item[wnot])(0)     ;ras, 9-feb-94
          Print, 'Correct input format:'
          Print, '89/12/15, 22:00:15.234, range is 1-jan-(19)50 to 31-dec-(20)49'
          goto, error_out
          Print,'goto, error_out
        endif
        ustr= utime2str(ut, utbase = 0.0)
        int2ex, ustr.time, ustr.day, ex2,/nomod
      endif

      if wyo_count eq 0 then ex = ex2 else $
        if wno_count eq 0 then ex = ex1 else $
        ex=[[reform(ex1,7,wyo_count)],[reform(ex2,7,wno_count)]]
    endif               ;close non-UTC string processing
  end
  1: begin
    Print, 'Not a valid input to Anytim! Error!'
    goto, error_out
  end
endcase

if n_elements(item_old) ge 1 then item=item_old

wcount = n_elements(ex) / 7

case 1 of
  keyword_set(date): $
    if wcount eq 1 then ex[0:3] = 0 else ex[0:3,*] = 0
  keyword_set(time): $
    if wcount eq 1 then ex[4:6] = [1,1,1979] else ex[4:6,*] = rebin([1,1,1979],3,wcount)
  1: ;NOACTION
endcase
;
;Now we have the time in the 7xN external format, convert

if out eq  'UTIME' or out eq 'SEC' or out eq 'SECONDS' then begin

  if just_seconds then begin
    result = double(item)
    if keyword_set(date) then result = result - (result mod 86400.d0)
    if keyword_set(time) then result = result mod 86400.d0
  endif else begin
    ex2int, ex, msod, ds79, /nomod
    nmsod = n_elements(msod)
    result = [ reform(msod[*],1,nmsod), reform(ds79[*]*1L,1,nmsod)]
    result = int2sec( result )
    if typ eq 'STC' then result = reform( result, siz[1:siz[0]], /overwrite)
    if (typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR') then $
      result = double(strmid(item,0,0)+'0') + result - sec_ref
  endelse
endif

if out eq 'EX' then result = ex

if out eq 'INTS' or out eq 'STC' then begin
  ex2int, ex, msod, ds79, /nomod
  result = replicate( {anytim2ints_full, time:0L, day:0L}, n_elements(msod))
  result.time = msod
  result.day  = ds79
endif

if out eq '2XN' then begin
  ex2int, ex, msod, ds79, /nomod
  result = replicate( {anytim2ints_full, time:0L, day:0L}, n_elements(msod))
  result.time = msod
  result.day  = ds79
  result = transpose( [[result.time],[result.day]] )
endif

if out eq 'ATIME' or out eq 'YOHKOH' or out eq 'HXRBS' or out eq 'YY/MM/DD' then begin

  case out of
    'ATIME' :begin
      result = atime(/pub, ex, date=date, time=time)
    end
    'YOHKOH':begin
      result = atime(/yohkoh, ex, date=date, time=time)
      if (typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR') then $ ;ras, 4-jan-94
        result = strmid(item,0,0) + result
    end
    ELSE: begin
      result = int2sec( anytim2ints( ex ) )
      result = atime( result,/hxrbs,/pub,date=date, time=time )
      if (typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR') then $
        result = strmid(item,0,0) + result
    end
  endcase
  ;
  ;  Add the conditional truncation.  I don't know why it wasn't there. RAS, 16-jul-1997
  ;
  if keyword_set(truncate) and strpos(result[0],'.') ne -1 then $
    result = strmid( result, 0, strpos(result[0],'.'))
endif

if out eq 'UTC_INT' or out eq 'UTC_EXT' or out eq 'CCSDS' or out eq 'ECS' or $
  out eq 'VMS' or out eq 'STIME' or out eq 'TAI' then begin
  ;use UTC converters
  ex2int, ex, msod, ds79, /nomod
  result = replicate(call_function('str2utc','01-jan-1979'), n_elements(ds79))
  result.mjd = result.mjd-1+ds79
  result.time = msod
  if out eq 'UTC_EXT' or out eq 'CCSDS' or out eq 'ECS' or $
    out eq 'VMS' or out eq 'STIME' or out eq 'TAI' then result=call_function('int2utc',result, $
    ccsds=(out eq 'CCSDS'), ecs=(out eq 'ECS'), vms=(out eq 'VMS'), stime=(out eq 'STIME'), $
    date_only=date, time_only=time)
  if out eq 'TAI' then begin
    result = anytim2tai( result )

  endif
  if keyword_set(truncate) and not keyword_set(date) and $
    ( out eq 'ECS' or out eq 'VMS' or out eq 'STIME' or out eq 'CCSDS') then $
    result = strmid( result, 0, strpos(result[0],'.'))
endif

if scalar and n_elements(result) eq 1 then result= result[0]

;Version 25
twoint_or_ex_format = ( IS_INT and $
  siz[0] eq 2 and (siz[1] eq 7 or siz[1] eq 2)) or $ ;Input side
  out eq '2XN' or out eq 'EX'

if  ((1 - twoint_or_ex_format) and (not scalar)) then $
  result = reform( result[*], siz[1:siz[0]], /overwrite)  ;
;Version 25
valid_return:
error = 0
return, result
error_out:
return, item
end

