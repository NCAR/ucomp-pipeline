pro rd_pnt_hist, data, infil=infil, simple_rd=simple_rd
;
;+
;NAME:
;	rd_pnt_hist
;PURPOSE:
;	To read the Yohkoh pointing history log file
;CALLING SEQUENCE:
;	rd_pnt_hist, data
;OPTIONAL KEYWORD INPUT:
;	infil	- The data file to read.  If not passed, it
;		  uses ???
;OUTPUT:
;	data	- A structure with the following fields:
;			.time
;			.day
;			.offset - 3 element array in arcseconds from
;				  a TFSS BIAS value of FFB8 FF9E which
;				  is the setting established on 29-Oct-91
;					(0) = E/W
;					(1) = N/S
;					(2) = Roll
;HISTORY:
;	Written 4-Jun-92 by M.Morrison
;	 5-Jun-92 (MDM) - Modified to read the BIAS file and adjust
;			  the output accordingly.
;	18-Jul-93 (MDM) - Made the file header have 9 lines
;	 5-Oct-93 (MDM) - Time sorted 
;	16-Mar-95 (MDM) - Changed to use RD_TFILE to speed things up
;-
;
if (n_elements(infil) eq 0) then infil = concat_dir('$DIR_GEN_STATUS', 'pointing.history')
;
data0 = {rd_pnt_hist, day: fix(0), $
			time: long(0), $
			offset: fltarr(3)}
nbuff = 100
data = replicate(data0, nbuff)
idata = 0
conv1 = 5.5555555e-5*60.*60.		;arcsec per commanded value (S/C offpointing)
conv2 = 1.0				;arcsec per commanded value (TFSS)  - correct?
conv = conv1
if (keyword_set(simple_rd)) then conv = conv2
;
mat = rd_tfile(infil)
mat = mat(9:*)		;drop first nine lines - header
;
n = n_elements(mat)
data = replicate(data0, n)
date = strmid(mat, 5, 2) + '-' + strmid(mat, 2, 3) + '-' + strmid(mat, 0, 2) + '  ' + strmid(mat, 20, 8)
daytim = anytim2ints(date)
buff = intarr(3,n)
reads, strmid(mat, 32, 15), buff, format='(3(z4.4,1x))'
data.day	= daytim.day
data.time	= daytim.time
data.offset	= buff*conv
;
;;openr, lun, infil, /get_lun
;;lin = '                                '
;;for i=1,9 do readf, lun, lin	;skip header
;
;;fmt = '(a32, 3(z4.4,1x))'
;;buff = intarr(3)
;;while not eof (lun) do begin
;;    readf, lun, lin, buff, format=fmt
;;    date = strmid(lin, 5, 2) + '-' + strmid(lin, 2, 3) + '-' + strmid(lin, 0, 2) + '  ' + strmid(lin, 20, 8)
;;    daytim = anytim2ints(date)
;;    data0.time		= daytim.time
;;    data0.day		= daytim.day
;;    data0.offset	= buff*conv		;convert to arcseconds
;;    ;
;;    data(idata) = data0
;;    idata = idata + 1
;;    if (idata ge n_elements(data)) then data = [data, replicate(data0, nbuff)]
;;end
;
;;data = data(0:idata-1)
;;free_lun, lun
;
if (keyword_set(simple_rd)) then return
data.offset = data.offset([1,0,2])	;reverse x and y - don't reverse bias reading
;
rd_pnt_hist, bias, infil=concat_dir('$DIR_GEN_STATUS', 'pointing.bias'), /simple_rd
ref = fix(['FFB8'x, 'FF7E'x, 0])*conv2		;convert to arcseconds
;
for i=0,n_elements(data)-1 do begin
    xx = int2secarr(bias, data(i))		;want last bias time before data(i) time
    ss = where(xx le 0, count)
    offset = ref - bias(ss(count-1)).offset
    ;; offset(0) = -1*offset(0)			;reverse the sign of X offset
    ;;print, fmt_tim(data(i)), offset
    data(i).offset = data(i).offset - offset
end
;
ss = sort(int2secarr(data))
data = data(ss)
end
