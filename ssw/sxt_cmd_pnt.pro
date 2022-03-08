function sxt_cmd_pnt, times, x=x, y=y, z=z, qstop=qstop, rawcmd=rawcmd
;
;+
;NAME:
;	sxt_cmd_pnt
;PURPOSE:
;	Given a set of input times, return the location of the center
;	of the sun in SXT full resolution pixels based on S/C commanded
;	pointing.
;METHOD:
;	The seasonal/mission long drift correction can be disabled
;	the the IDL command: setenv,'ys_no_attcmd_corr=1'
;SAMPLE CALLING SEQUENCE:
;	xy = sxt_cmd_pnt(index)
;       xy = sxt_cmd_pnt(index,rawcmd) ; dont apply seasonal correction
;
;INPUT:
;	times	- A set of times in an of the 3 standard formats
;OUTPUT:
;	returns a vector 2xN of location of the SXT sun center
;		(0) = East/West with East negative
;		(1) = North/South with South negative
;	It does not take into account the 1 arcminute drift (S/C morning
;	"nod") generally seen over an orbit.  Changes in the pointing 
;	commanded bias value are taken into account.
;HISTORY:
;	Written 5-Jun-93 by M.Morrison
;	10-Jun-93 (MDM) - Minor change to documentation header
;	 9-Mar-95 (MDM) - Modified to apply the correction required for
;			  the seasonal/mission long drift between the 
;			  commanded and actual.
;       25-mar-95 (SLF) - add RAWCMD keyword 
;	 8-May-95 (MDM) - Added Katsev secondary correction factor.
;-
;
ref_time = '1-apr-92'
x0 = 499	;don't need more accuracy than this since the orbital
y0 = 563	;drift is several pixels

off = get_del_pnt(times, ref_time)
out = off(0:1,*)
out(0,*) = x0 + out(0,*)/gt_pix_size()
out(1,*) = y0 + out(1,*)/gt_pix_size()
;
if (getenv('ys_no_attcmd_corr') eq '') and (1-keyword_set(rawcmd)) then begin
    ref_time = '1-jan-92'
    x = int2secarr(times, ref_time)
    x_yr = x/(365*86400.)
    x_day = x/86400.
    ;
    param1 = [2.2123401, 0.74076641, 0.17411420]
    param2 = [2.3265929,  5.6742266, 0.24390289, 9.7029480, -4.6606623]
    attcmd_funct1, x_yr, param1, cor1
    attcmd_funct2, x_yr, param2, cor2
    ;
    p=[1.12e-3, 4.256, 0.609375, 4.80, 28.15, 1.20, 14.15, 0.42, 2.0]
    cor2y=(p(0)*x_day+p(1))*(p(2)*cos((x_day-p(3))/p(4))+1)*exp(-(cos((x_day-p(5))/p(6))/p(7))^2)-p(8)
    ;
    out(0,*) = out(0,*) + cor1
    out(1,*) = out(1,*) + cor2 -cor2y	;MDM added "-cor2y" 8-May-95
end else begin
    print, 'ATT-CMD seasonal/mission correction not applied'
end
;
return, out
end
