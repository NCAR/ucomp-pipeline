function ucomp_annulus,radius1,radius2,dx=dx,dy=dy
;+
;  procedure to create annular field mask equal to 1. between radius1 and radius2 centered on the center of the mask
;  if dx and dy are present, the mask will be shifted by dx,dy
;-
nx = 1280
ny = 1024

mask=fltarr(nx,ny)+1.

x0 = nx/2.-0.5
y0 = ny/2.-0.5
x=rebin(indgen(nx)-x0,nx,ny)
y=transpose(rebin(indgen(ny)-y0,ny,nx))
if n_elements(dx) gt 0 or n_elements(dy) gt 0 then begin
  x=x-dx
  y=y-dy
endif
r=sqrt(x^2+y^2)

bad=where(r lt radius1 or r gt radius2,count)
if count gt 0 then mask(bad)=0.

return,mask
end
