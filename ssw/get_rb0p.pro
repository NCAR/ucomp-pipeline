
function get_rb0p, item, radius=radius, b0angle=b0angle, pangle=pangle, $
  old=old, quiet=quiet, deg=deg,pb0r=_pb0r,_extra=extra

;+
;NAME:
;	get_rb0p
;PURPOSE:
;	Determine the solar radius, b0 angle, and p angle for a set of times
;CALLING SEQUENCE:
;	rb0p    = get_rb0p(time)
;	r       = get_rb0p(index, /radius)
;	b0angle = get_rb0p(roadmap, /b0angle, /deg)
;	pangle  = get_rb0p('1-jun-93', /pangle)
;INPUT:
;	item	- A structure or scalar.  It can be an array.
;OPTIONAL KEYWORD INPUT:
;	radius	- If set, just return the radius
;	b0angle	- If set, just return the b0 angle
;	pangle	- If set, just return the p angle
;	deg	- If set, then return angles in degrees (default is radians)
;       old     - If set, runs as before
;       quiet   - If set, turns of the warning about pb0r use
;       pb0r    - If set, return output in [p,b0,r] order
;OUTPUT:
;	rb0p	- Returns a 3xN vector containing the following parameters
;		  when /RADIUS, /B0ANGLE, or /PANGLE are not set:
;       	P  = Position angle of the northern extremity of the axis
;                    of the sun's rotation, measured eastward from the
;                    geographic north point of the solar disk. 
;       	B0 = Heliographic latitude of the central point of the
;                    solar disk
;       	R  = Solar radius measured outside earth's atmosphere in
;		     arcseconds
;HISTORY:
;	Written 22-Nov-91 by G. Slater using Morrison style parameters
;	18-Jul-93 (MDM) - Added /RADIUS, /B0ANGLE, and /PANGLE 
;			- Deleted "header" option (was not implemented)
;			- Changed the time conversion code somewhat
;			- Added /PB0R option
;	18-Jan-94 (GLS) - Made GET_RB0P front end to GET_SUN, which
;			  calculates a variety of solar ephemeris data,
;			  and was derived from SUN, a Johns Hopkins U.
;			  routine
;	15-Feb-94 (GLS)	- Checked for 1 element OUT
;       22-Mar-13 (HSH) - Replaced SUN as the basic reference with PB0R.
;                         For the radius value itself, this is equivalent
;                         at the time of writing with adopting the results
;                         of Brown & Christensen-Dalsgaard (1998), via 
;                         WCS_RSUN(), rather than those of Auwers (1891)
;       24-Mar-13 (DMZ) - optimized
;       26-Mar-13 (DMZ) - added support for YOHKOH INDEX input and /PB0R
;       2-Apr-13  (DMZ) - added check for FITS index input
;       14-Nov-13 Kim   - changed to use message routine for printing warning 
;-

if ~exist(item) then begin
 pr_syntax,'output=get_rb0p(item, deg=deg, b0=b0, p=p, old=old, quiet=quiet,deg=deg)'
 return,[-1.d,-1.d,-1.d]
endif

;-- old bypass

if keyword_set(old) then $
 return,get_rb0p_old(item, radius=radius, b0angle=b0angle, pangle=pangle, deg=deg, pb0r=_pb0r)

message0= ' Now using pb0r as a reference instead of SUN. '
message1= ['  The results will differ by < 0.1%.  ',$
           'To get the old values call get_rb0p with /old. To remove this message use /quiet.']

if ~keyword_set(quiet) then begin
  message,/cont,message0
  print, message1
endif

;-- check for valid time input

error=0
if is_struct(item) then if have_tag(item,'date_obs') then time=item.date_obs
if ~exist(time) then time=anytim(item,/ecs,error=error)
if error eq 1 then return,[-1.d,-1.d,-1.d]

dradeg = 180D0/!dpi

ntim=n_elements(time)
out = dblarr(3,ntim)
for ii = 0, ntim-1 do begin
 output=pb0r(time[ii],/arcsec)
 if ~keyword_set(deg) then output[[0,1]]=output[[0,1]]/dradeg
 out[*,ii]=output
endfor

if ~keyword_set(_pb0r) then begin
 out=out[[2,1,0],*]
 case 1 of
  keyword_set(radius): out=out[0,*]
  keyword_set(b0angle): out=out[1,*]
  keyword_set(pangle): out=out[2,*]
  else:do_nothing=1
 endcase
endif

out=(n_elements(out) gt 1)? reform(out) : out[0]
return,out

end

