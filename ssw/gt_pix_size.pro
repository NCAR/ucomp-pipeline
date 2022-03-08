function gt_pix_size, input, wl=wl, area=area
;+
;NAME:
;	gt_pix_size
;PURPOSE:
;	To return the SXT pixel size in arcseconds
;SAMPLE CALLING SEQUENCE:
;	pix = gt_pix_size()
;	pix = gt_pix_size(index)
;	area= gt_pix_size(index, /area)
;OPTIONAL INPUT:
;	input	- The roadmap or index structure.  The output will be the
;		  pixel size in arcseconds for each image depending on the
;		  summation mode of the image.  The default with no parameters
;		  is full resolution
;OPTIONAL KEYWORD INPUT:
;	wl	- If set, return the original value which was derived from
;		  analyzing white light images.
; 	area    - If set, and index is passed, the function returns the pixel
;		  area in cm^2.  The computed area is based on the distance
;		  to the Sun as given by the time in the INPUT structure.
;ROUTINES CALLED
;	get_rb0p, gt_res, tag_names, is_member
;HISTORY:
;	Written by Tom Metcalf 1992
;	12-Jun-93 (MDM) - Added documentation header
;			- Added INPUT parameter option
;			- Changed default value returned from 2.4602 to 2.4528
;			  The new value is the value recorded in the red book
;			  as derived from the focal length.  The old value was
;			  derived by Metcalf looking at the radius of white 
;			  light images.
;	 7-Apr-93 (HSH) - Added /area keyword => area of (full resolution)
;			  pixel in cm^2, userful for em conversion
;        5-oct-94 (SLF) - Updated x-ray pixel size based upon work by
;                         Jean-Pierre Wuelser
;	22-dec-95 (JRL)	- Enabled INPUT to be a vector.
;-

;out = 2.4528		;Red book focal length derived value
out =  2.455		;slf using JPW most recent values

if (keyword_set(wl)) then out = 2.4602 	

if (n_elements(input) ne 0) then begin
  npix = 2.^ gt_res(input)			; Half or quarter resolution?
  out = out*npix
end

if (keyword_set(area)) then begin
  qflag = 0							 ; If 1, can't compute area
  if n_elements(input) eq 0 then qflag = 1 else $		 ; Must be defined
  if (size(input))((size(input))(0)+1) ne 8 then qflag = 1 else $; Must be structure
  begin
    tags = tag_names(input)
    if is_member('TIME',tags) + is_member('GEN',tags) eq 0 then qflag = 1
  endelse

  if qflag then begin				; Need time for solar distance
    message,'Need to enter an index structure for area calculation. Sorry!',/info
    out = 0
  endif else begin
    radius = get_rb0p(input, /radius)		; Solar radius in arcsec
    edge = out * 6.9599e10 / radius		; Pixel edge length (cm)
    out = edge^2				; Pixel area (cm^2)
  endelse
endif

return, out
end
