
FUNCTION UTIME,UTSTRING0, ERROR=ERROR, DATE=DATE, TIME=TIME, MSGERR=MSGERR
  ;+
  ; NAME:
  ;   UTIME
  ; PURPOSE:
  ;   Function to return time in seconds from 79/1/1,0000 corresponding to
  ;       the ASCII time passed in the argument.
  ;   N.B. Valid only from 1950-2050
  ; CATEGORY:
  ; CALLING SEQUENCE:
  ;   RESULT = UTIME(UTSTRING,/ERROR)
  ; INPUTS:
  ;   UTSTRING -    String containing time in form YY/MM/DD,HHMM:SS.XXX
  ;      or YY/MM/DD HHMM:SS.XXX or YY/MM/DD HH:MM:SS.XXX
  ;          Also accepts Yohkoh format time string:
  ;      DD-MON-YY HH:MM:SS.XXX
  ;      Will not accept HH:MM:SS.XXX DD-MON-YY
  ; Keywords:
  ;   ERROR -     =0/1. If set to 1, there was an error in the ASCII
  ;      time string.
  ;   /date   - return only the calendar date component of the UTIME
  ;   /time   - return only the time day
  ;       MSGERR    = If defined and passed, then any error messages
  ;                           will be returned to the user in this parameter
  ;                           rather than being handled by the IDL MESSAGE
  ;                           utility.  If no errors are encountered, then a
  ;                           null string is returned.  In order to use this
  ;                           feature, the string MSGERR must be defined
  ;                           first, e.g.,
  ;
  ;                               MSGERR = ''
  ;                               RESULT = UTC2STR( UTC, MSGERR=MSGERR )
  ;                               IF MSGERR NE '' THEN ...
  ;      MSGERR used to avoid collisions with sloppy calls to error (using err instead)

  ; OUTPUTS:
  ;   Double precision time in seconds since 79/1/1, 0000.
  ; COMMON BLOCKS:
  ;   None.
  ; SIDE EFFECTS:
  ;       If just a time is passed (no date - detected by absence of slash
  ;       and comma in string), then just the time of day is converted to
  ;   seconds relative to start of day and returned.  If date and time
  ;   are passed, then day and time of day are converted to seconds and
  ;   returned.  In other words, doesn't 'remember' last date used if
  ;   no date is specified.  There is only rudimentary error checking,
  ;   strings like 82/02/30 will have the same value as 82/03/02.
  ; PROCEDURE:
  ;   Parses string into component parts, i.e. YY,MM,DD,HH,MM,SS.XXX,
  ;   converts the strings into double precision seconds using a gregorian
  ;   date to julian date algorithm.  Accepts vectors of strings as well
  ;   as scalar strings.
  ; MODIFICATION HISTORY:
  ;   Written by Kim Tolbert 7/89
  ;   Modified for IDL Version 2 by Richard Schwartz Feb. 1991
  ;   Corrected RAS 91/05/02, error should be initialized to 0
  ;   Modified to accept vectors of dates by RAS, 92/07/07
  ;   Modified to accept vectors of any dimensionality by RAS, 92/08/10
  ;   Modified to automatically convert Yohkoh string format, ras, 01-May-93
  ;   Corrected 07-May-93 to again take whitespace in old date format, RAS
  ;   added time and date keywords, ras, 5-jan-94
  ;   minor changes to error handling, ras, 7-jan-94
  ;   ras, 18-jun-1995, hxrbs style strings may now be parsed with only a
  ;       space between the date and time strings!
  ;   richard.schwartz, 6-dec-1999.  Fixed bug with mixed length strings w/o commas.
  ;     Correct code to insert commas wasn't used, producing possible errors.
  ;   9-jan-2006, richard.schwartz@gsfc.nasa.gov, eliminate problems
  ;     with more than 2^14 elements in utstring.
  ;   26-May-2016, richard.schwartz@nasa.gov, fix one colon problem (previously assumed 09:02 was 
  ;     9 min 2 sec, should be 9 hr 2 min), convert parens for indexing to square brackets, and format
  ;     (Ctrl shift F) for nicer indenting
  ;-
  on_error,2
  error = 1  ; initialize to error
  message = '' ;initialize error string

  typ = datatype(utstring0) ;check for string
  ;if (size(utstring0(0)))(0) eq 0 then scalar = 1 else scalar = 0
  if (size(utstring0))(0) eq 0 then scalar = 1 else scalar = 0
  ;if not a string, or a hxrbs string, make it a hxrbs string
  if typ ne 'STR' or (where( strpos(utstring0,'-') ne -1))(0) ne -1 then $
    utstring = anytim( utstring0, out='hxrbs')  else utstring=utstring0
  ;Look for any time phrases that have only 1 colon that isn't in the final position. If we find any,
  ;add a colon to the end
  ;First see if there are the same of number of lines and  n x number of ':', if there are bit, we do this line by line, otherwise we assume
  ;all the formats are the same
  nlines = n_elements( utstring0 )
  test   = where( byte( utstring0 ) eq 58b, ncolon )
  if ncolon ge 1 and ( ncolon ne 2*nlines ) then begin ;solve the 1 colon problem
    cfp = strpos( utstring0, ':' )
    cfr = strpos( utstring0, ':',/reverse_search );get the trailing string
    cfl = strlen( utstring0 )
    ;If a string has but one ':' and it isn't in the last position, add one
    ;But first see how many characters after the one colon and
    ;make sure there are two by filling with zeroes
    z = where( cfp ne -1 and (cfr eq cfp), nz) ;z lines have one colon
    if nz ge 1 then begin ;
      temp = utstring0[z]
      q    = where( cfl - cfp eq 3, nq)
      if nq ge 1 then temp[q] = temp[q] + ':'
      q    = where( cfl - cfp eq 2, nq)
      if nq ge 1 then temp[q] = temp[q] + '0:'
      q    = where( cfl - cfp eq 1, nq)
      if nq ge 1 then temp[q] = temp[q] + '00:'
      utstring[z] = temp
    endif
  endif
  ;if publication format then 'YY/MM/DD, HH:MM:SS.XXX
  ;Insert commas and eliminate blanks to simplify later parsing
  ;
  ;Here we have supported all blanks so we will remove all whitespace from
  ;strings which don't include dashes.  Yohkoh doesn't accept blanks in the
  ;datestring
  buff1 = utstring[*]
  wnodash = where(strpos( buff1, '-' ) eq -1,nnodash)
  if nnodash ge 1 then begin
    ;We will now support HXRBS strings with spaces as well as  commas by
    ;looking for slashes followed by more than 3 characters without a
    ;comma which we will insert to then enable processing as before,
    ;ras, 18-jun-1995
    ut = strcompress(buff1[wnodash])  ;single spaces only
    ut_byte = byte(ut)
    ;figure out the row(line) of each slash, find the rows with two slashes
    ;those with only one will fail elsewhere
    wslashes = where( ut_byte eq (byte('/'))(0), nslashes)
    if nslashes ge 1 then begin
      if nslashes mod 2 eq 1 then goto, errorlog  ;only 1 slash, this is wrong
      ;just look at 2nd slash
      wslashes = wslashes[ 2*lindgen(nslashes/2)+1 ]
      wline_2slash = wslashes /(size(ut_byte))(1)
      ;The position of this slash is given by:
      pos_2slash   = wslashes mod (size(ut_byte))(1)
      ;choose every second slash as a start position to look for more than
      ;3 characters following the second slash
      ncharac_after = strlen(ut[wline_2slash]) - pos_2slash -1
      ;find out where there are 3 or more characters, but without a comma
      wnocomma = where( ncharac_after ge 3 and $
        strpos(ut[wline_2slash],',') eq -1, num_nocomma)
      ut_byte = 0
      if num_nocomma ge 1 then begin ;parse the line for spaces after the 2nd dash
        ut1 = ut[wline_2slash[wnocomma]]
        pos_2slash = pos_2slash[wnocomma]
        ;Look for regular arrays, where the space follows the 2nd slash
        ;in the same position, if the array is regular then use array
        ;functions like strmid

        ;if num_nocomma ge 2 then begin
        pos_space= strpos(ut1,' ')
        simple_comma_insert = total(abs(pos_space-pos_space[0])) eq 0 and $
          total(abs(pos_2slash-pos_2slash[0])) eq 0 and $
          (pos_space[0] - pos_2slash[0]) ge 2


        if simple_comma_insert then $
          strput, ut1, ',', pos_space[0] else begin
          for i=0L,num_nocomma-1 do begin
            sub_ut = str2arr(strmid(ut1[i], pos_2slash[i], 25),delim=' ')
            ut1[i] = strmid(ut1[i],0,pos_2slash[i]) + sub_ut[0]+','
            if n_elements(sub_ut) ge 1 then $
              ut1[i]=ut1[i]+arr2str( sub_ut[1:*],delim='')
          endfor

        endelse
        ;endif
        ut[wline_2slash[wnocomma]] = ut1
        buff1[wnodash] = ut
        ut1=0
        ut =0
      endif

    endif
    buff1[wnodash] = strcompress(buff1[wnodash],/remove)    ;no whitespace





  endif
  ;All whitespace removed from non dash strings, just as before

  buff1 = byte( buff1 )

  if n_elements(buff1) gt 1 then  begin ;must be more than 1 character in array
    wblnk = where( (buff1[1:*] eq 32b) and (buff1 ne 44b), nblnk)+1
    if nblnk ge 1 then buff1[wblnk] = 44b ;insert commas
  endif

  buff1 = string( buff1 ) ;convert back to a string array
  buff1 = strupcase(strcompress(buff1,/remove)) ;eliminate whitespace
  ;

  ;Look for dashes indicating Yohkoh format, if found, convert to yy/mm/dd

  dash = strpos( buff1, '-')
  wdash = where( dash ne -1, ndash)

  if ndash ge 1 then begin ;change yohkoh format into yy/mm/dd
    buff1 = byte(buff1[wdash]) ;
    buff1[where(buff1 eq 45b)] = byte('/') ;dashes to slashes
    wmonths = where( (buff1 ge 65b) and (buff1 le 90b),nmonths)
    if nmonths eq 0 then goto, errorlog   ; added by AKT 7/2/93
    months = string( reform(buff1[wmonths],3,nmonths/3))
    months = byte(strmid(strtrim(string(100+month_id(months)),2),1,2)+' ')
    buff1[wmonths] = months
    buff1 = strcompress( buff1, /rem)
  endif

  ;default time is 79/01/01
  n = n_elements(buff1)
  yy = intarr(n) + 1979
  mm = intarr(n) + 1
  dd = intarr(n) + 1
  hh = dblarr(n)
  ;PARSE THE YEAR, MONTH, AND DAY AND CONVERT THEM TO INT*2
  buff1 = byte(buff1)
  ;Look for publication format and clobber the second colon
  wcolon = where( buff1 eq 58b, ncolon)
  if ncolon gt 1 then begin; LOOK FOR COLONS WITHIN 3
    dcolon = wcolon[1:*] - wcolon
    w3 = where( dcolon le 3, n3)
    if n3 ge 1 then begin
      buff1[wcolon[w3]] = 32b ;change it into a blank
      buff1 = byte(strcompress( string(buff1),/rem))
    endif
  endif ;first PUBLICATION FORMAT Colon IS ELIMINATE

  nl = n_elements( buff1[*,0] )

  schar = string(buff1[0:3 <(nl-1),*])
  slash = strpos(schar, '/')
  colon = strpos(schar, ':')
  period = strpos(schar, '.')

  wslash = where( slash ne -1, nslash)
  wcolon = where( colon ne -1, ncolon)
  wperiod = where( period ne -1, nperiod)
  wnone = where( (slash eq -1) and (colon eq -1) and (period eq -1) and $
    (dash eq -1), nnone)

  ;
  buff2 = bytarr(20 > nl, n) ;quantities get placed in here

  if nslash ge 1 then buff2[0:nl-1, wslash] = buff1[*, wslash]
  if ncolon ge 1 then begin
    buff2[9:9+ (10 < (nl-1)),wcolon] = buff1[0:10 < (nl-1),wcolon]
    buff2[0:8,wcolon] = byte('79/01/01,')#replicate(1,1,ncolon)
  endif
  if nnone ge 1 then begin
    buff2[9:9+ (10 < (nl-1)),wnone] = buff1[0:10 < (nl-1),wnone]
    buff2[0:8,wnone] = byte('79/01/01,')#replicate(1,1,nnone)
  endif

  if nperiod ge 1 then begin
    buff2[14:14 + (5 < (nl-1)),wperiod] = buff1[0:5 < (nl-1),wperiod]
    buff2[0:13, wperiod] = byte('79/01/01,0000:')#replicate(1,1,nperiod)
  endif

  sbuff = string(buff2)
  sleng  = strlen(sbuff)
  colon = strpos( sbuff, ':')
  comma = strpos( sbuff, ',')
  slash = strpos( sbuff, '/')

  wcolon = where( colon gt comma, ncolon)
  wcomma = where( comma gt slash and colon eq -1, ncomma)
  wnone = where( (colon eq -1) and (comma eq -1), nnone)

  if ncolon ge 1 then begin ; COLON IS THE LAST NON-DIGIT CHARACTER
    wend = where( sleng[wcolon]-1 eq colon[wcolon], nend )
    if nend ge 1 then buff2[14:19,wcolon[wend]] = $
      byte('00.000')#replicate(1,1,nend)
  endif

  if ncomma ge 1 then begin ; COMMA IS THE LAST NON-DIGIT CHARACTER
    wmore = where( sleng[wcomma]-1 gt comma[wcomma], nmore)
    if nmore ge 1 then buff2[13:19,wcomma[wmore]] = $
      byte(':00.000')#replicate(1,1,nmore)
    wend = where( sleng[wcomma]-1 eq comma[wcomma], nend)
    if nend ge 1 then buff2[9:19,wcomma[wend]] = $
      byte( '0000:00.000')#replicate(1,1,nend)
  endif
  if nnone ge 1 then buff2[8:19,wnone]=byte(',0000:00.000')#replicate(1,1,nnone)

  ;replace all of the zeroes with blanks (32b)
  ;check for characters '/,:.'
  ; 47  44  58  46
  ;change all /,: characters to blanks, 32b

  wzero =where(buff2 eq 0b, nzero) ;eliminate 0's
  inbuff = buff2
  if nzero ge 1 then buff2[wzero] = 32b
  ;temp = buff2
  buff2[ where( (buff2 eq 47b) or (buff2 eq 44b) or (buff2 eq 58b) ,nb)] = 32b

  ;stop
  ;help, nb, n

  if nb ne n*4l then goto,errorlog ; should be 4 blanks per line

  sbuff = string(buff2)


  ymdhs = dblarr( 5,n)

  on_ioerror, errorlog
  reads, sbuff, ymdhs ;
  on_ioerror, null

  ymdhs = transpose( ymdhs) ;for Yohkoh format, year and day are transposed
  if ndash ge 1 then begin
    yy = ymdhs[*,0]
    ymdhs[wdash,0] = ymdhs[wdash,2] ;move years to days
    ymdhs[wdash,2] = yy[wdash] ; move days to years
  endif

  ;VALID FROM 1950-2049
  year = [indgen(50)+2000,indgen(50)+1950]
  yy = year[ ymdhs[*,0] ]
  hhmm = fix(ymdhs[*,3])
  hrs = hhmm/100 + (hhmm mod 100)/60.0d0 + ymdhs[*,4]/3600.0d0
  ;check ranges

  wbad = where(  ( abs(yy-2000) gt 50) or (hrs gt 24.0) or (ymdhs[*,1] gt 12) $
    or (ymdhs[*,2] gt 31), nbad)


  if nbad gt 0 then goto, errorlog


  jdcnv, yy, fix(ymdhs[*,1]), fix(ymdhs[*,2]), hrs, jd

  ut = (jd- 2443874.5d0) * 86400.0d0
  ut = double(strmid(utstring,0,0)) + ut[*]

  if scalar then ut= ut[0]
  ;
  ; Provide users with commonly time and date components
  ; Date keyword supercedes time keyword
  ;
  case 1 of
    keyword_set(date): ut = ut - (ut mod 86400.d0)
    keyword_set(time): ut = ut mod 86400.d0
    1:
  endcase


  error=0
  return, ut

  errorlog:

  ;PRINT,'ERROR = ',ERROR
  error = 1
  message=[utstring0,$
    'Error. Format for time is YY/MM/DD, HHMM:SS.SSS',$
    ' or alternatively, DD-Mon-YY HH:MM:SS.SSS']

  IF N_ELEMENTS(MSGERR) EQ 0 THEN begin
    prstr,/nomore, MESSAGE
    return, utstring0       ;return the input on error, ras 7-jan-94
  endif

  MSGERR = MESSAGE
  RETURN, '-1'
end
