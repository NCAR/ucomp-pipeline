pro rdwrt, code, lun, ibyt, rsiz, data, qupdate_ibyt, qdebug, quiet=quiet,$
                 err=err
;
;+
;NAME:
;	rdwrt
;PURPOSE:
;	All input and output to the reformatted data files is done
;	by this routine.
;INPUT:
;	code		'W' for write, 'R' for read
;	lun		logical unit of file to write to
;	ibyt		starting byte to write data to
;	rsiz		record size of output file (in bytes)
;INPUT/OUTPUT:
;	data		data array to read/write
;OPTIONAL INPUT:
;	qupdate_ibyt	If set, the value "ibyt" is updated to the current 
;			position within the file
;	qdebug		If set, a debut line is printed
;OPTIONAL KEYWORD INPUT:
;	quiet		If set, do not print error messages when writing
;			does not end of a record boundary
;HISTORY:
;	Written Jun 1991 by M.Morrison
;	19-Oct-91 (MDM) Added option of byte swapping if on Sun system
;	 9-Nov-91 (MDM) Made swaping occur always unless it is run on
;			a VMS or ULTRIX machine
;	12-Dec-91 (MDM) Used "dec2sun" instead of "vax2sun" and "sun2vax"
;	21-May-92 (MDM) Modified so that the input variable "data" is not
;			changed for the cases where the machine writing the
;			data is non-DEC (since it must do byte swapping before
;			the write)
;	12-Oct-92 (MDM) Removed check to see where pointer was left from
;			the last read/write
;			Added QUIET option so that funny shaped images
;			can be saved with SAV_SDA.
;	13-Apr-93 (MDM) Added calls to YOH_IEEE2VAX and YOH_VAX2IEEE to
;			convert the REALs when on the VMS machine
;	 8-Jun-93 (MDM) Added the capability to override the default which
;			is to convert the REAL*4 values from VAX to IEEE
;			format before writing, and then back again during
;			reading.
;	 3-Aug-93 (MDM) Expanded the list of operating systems that do not
;			swap bytes to include 'OSF' (and vms and ultrix)
;	 9-Sep-95 (ATP) Expanded list of operating systems that do not
;			swap bytes to include 'linux' (i386)
;       25-May-98 (DMZ) Further expanded noswap list to Windows systems
;       15-Jan-00 (DMZ) Added ON_IOERROR check and ERR keyword
;	29-Dec-06 (ROM) Added DARWIN to the list of noswap OS
;        2-Jan-07 - S.L.Freeland - 29-dec change caused problems on 
;                   Macs w/ppc - modified to use 'is_lendian.pro' for
;                   auto extension (use calclulation, not OS list)
;-
;
;-------------------------------------------------------------------
;-- I/O error handling code
;-- can only get here when an I/O error occurs

err='' & error=0
if error ne 0 then begin
trap:
 err='error reading file'
 if strupcase(code) eq 'W' then err='error writing to file' 
 if not keyword_set(quiet) then message,err,/cont
 on_ioerror,null
 if n_elements(lun) ne 0 then begin
  close,lun & free_lun,lun
 endif
 return
endif

;------------------------------------------------------------------
common rdwrt_blk, qvms_rconv_read, qvms_rconv_write
;	qvms_rconv_read	- Flag for if on VMS system, whether to do the IEEE2VAX conversion during the read
;	qvms_rconv_write- Flag for if on VMS system, whether to do the VAX2IEEE conversion during the write
;
if (n_elements(qvms_rconv_read) eq 0) then qvms_rconv_read = 1	 ;default is to do ieee2vax conversion
if (n_elements(qvms_rconv_write) eq 0) then qvms_rconv_write = 1 ;default is to do vax2ieee conversion
;
if (n_elements(rsiz) eq 0) then rsiz = 0
if (n_elements(qupdate_ibyt) eq 0) then qupdate_ibyt = 0	;default is not to update
if (n_elements(qdebug) eq 0) then qdebug = 0
;
ibyt0 = ibyt	;save commaded starting point
;
point_lun, lun, ibyt
;
; SLFReeland, 2-Jan-2007 - replace explict list with 'is_lendian.pro'
;noswap_os=['vms','ultrix','OSF','linux','win32','windows','darwin']; list of noswap (extensible)
;chk=where(strlowcase(!version.os) eq strlowcase(noswap_os),nscount)     ; current OS in noswap list?
;qswap = nscount eq 0                            ; assign boolean
qswap = 1-is_lendian() ; 2-jan-2007, use calcualation, not OS list

;
qvms = (!version.os eq 'vms')			;MDM added 13-Apr-93
;
on_ioerror,trap                                 ;Trap I/O error (DMZ)
if (strupcase(code) eq 'W') then begin
    ;if (qswap) then sun2vax, data
    if (qswap or qvms) then begin		;only create a duplicate copy of the input data when it is necessary to swap
	data2 = data				;bytes.  Since DEC2SUN changes the input, this is necessary
	if (qswap) then dec2sun, data2		;changed to dec2sun 12-Dec-91
	;if (qvms) then yoh_vax2ieee, data2	;MDM added 13-Apr-93
	if (qvms and qvms_rconv_write) then yoh_vax2ieee, data2	;MDM 8-Jun-93
	writeu, lun, data2
    end else begin
	writeu, lun, data
    end
end else begin
    readu, lun, data
    ;if (qswap) then vax2sun, data
    if (qswap) then dec2sun, data		;changed to dec2sun 12-Dec-91
    ;if (qvms) then yoh_ieee2vax, data		;MDM added 13-Apr-93
    if (qvms and qvms_rconv_read) then yoh_ieee2vax, data		;MDM 8-Jun-93
end
;
;---- The following code does not work since "point_lun" gives data in
;     multiples of "rsiz" when opening a fixed record length file without the 
;     /BLOCK qualifier.
point_lun, -1*lun, enpos
if (rsiz ne 0) then if ((enpos mod rsiz) ne 0) then begin
    if (not keyword_set(quiet)) then begin
	print, 'Writing of data did not end of a record boundary', string(byte(7))
	print, 'Moving pointer to next record boundary'
    end
    enpos = (long(enpos/rsiz)+1)*rsiz
    ;;stop
end
;
if (qupdate_ibyt) then ibyt = enpos
;
if (qdebug) then print, 'ibyt0, enpos, ibyt    ', code, ' -- ', ibyt0, enpos, ibyt
end



