
function get_rb0p, item, radius=radius, b0angle=b0angle, pangle=pangle, $
  pb0r=pb0r, deg=deg

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
;	pb0r	- If set, return a 3xN array of [p, b0, r]
;		  This option is available so that the old routine PB0R can
;		  be replaced.
;	deg	- If set, then return angles in degrees (default is radians)
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
;-

  if (n_params(0) eq 0) then $
    return,'function get_rb0p, item, rad=rad,b0=b0, p=p, pb0r=pb0r'

  daytim = anytim2ints(item)
  decd79 = double(daytim.day) + double(daytim.time)/8.64e7

  sun_data = get_sun(item)
  if (keyword_set(deg) eq 0) then begin
    sun_data(11,*) = sun_data(11,*)/!radeg
    sun_data(12,*) = sun_data(12,*)/!radeg
  endif

  if (keyword_set(radius)) then out = reform(sun_data(1,*))
  if (keyword_set(b0angle)) then out = reform(sun_data(11,*))
  if (keyword_set(pangle)) then out = reform(sun_data(12,*))
  if (keyword_set(pb0r)) then $
    out = transpose([[reform(sun_data(12,*))],[reform(sun_data(11,*))], $
		     [reform(sun_data(1,*))]])
  if (n_elements(out) eq 0) then $
    out = transpose([[reform(sun_data(1,*))],[reform(sun_data(11,*))], $
		     [reform(sun_data(12,*))]])

  if n_elements(out) eq 1 then out = out(0)
  return, out

  end

