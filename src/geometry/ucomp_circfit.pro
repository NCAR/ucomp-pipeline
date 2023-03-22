;+
;  Name: circfit
;
;  Description:
;    Procedure to iteractively fit the coordinates of a circle in polar coordinates.
;
;  Input Parameters:
;    theta- the angle coordinates
;    r - the radius coordinates
;
;  Keyword Parameters:
;    chisq - the optional value of the chisq
;
;  Output:
;    The values of the fit are returned in a three element vector in the order:
;    radius of the circle center
;    angle of the circle center
;    radius of the circle
;
;  Author: Tomczyk
;  Modified by: Sitongia
;
;  Example:
;    circfit,theta,r
;-
function circfit,theta,r,chisq=chisq

;  Function to iteratively fit a circle to points in polar coordinates. The coordinates of the fit are returned.
;  The value of chi^2 (chisq) is optionally returned.

common fit,x,y,radius

ans=' '
debug=0

x=theta
rr=r
radius=mean(r)
y=r-radius^2/r
count=1

while count gt 0 do begin
  a=amoeba(1.e-4,p0=[0.,0.,radius],function_name='circ',scale=1.,nmax=10000)

  ; Check if amoeba failed: it returns -1 but usually returns an array, so use
  ; following hack rather than directly checking return value!
  s = size(a)
  if s[0] eq 0 then begin
    print, 'circfit: amoeba failed.'
    a = [-1.,-1.,radius]
    chisq = -1.
    goto,skip
  endif

  rfit=a(0)*cos(x)+a(1)*sin(x)+a(2)
  diff=rfit - y
  chisq=total(diff^2)/float(n_elements(diff))

  rms=stdev(diff)
  bad=where(abs(diff) ge 4.*rms,count,complement=good)
  if count gt 0 then begin
    radius=mean(r(good))
    x=x[good]
    rr=rr[good]
    y=rr-radius^2/rr
    if debug eq 1 then begin
      print,count,' bad points:'
      plot,theta,abs(diff)/rms
      read,'enter return',ans
    endif
  endif
endwhile

skip:
return,a
end

function circ,p
common fit,x,y,radius

yf=p(0)*cos(x)+p(1)*sin(x)+p(2)
return,total( (yf-y)^2 )
end
