pro break_file, file, disk_log, dir, filnam, ext, fversion, node
;+
; Project     : SOHO - CDS
;
; Name        : 
;	BREAK_FILE
; Purpose     : 
;	Break a filename into its component parts.
; Explanation : 
;	Given a file name, break the filename into the parts
;	of disk/logical, the directory, the filename, the
;	extension, and the file version (for VMS)
; Use         : 
;	BREAK_FILE, FILE, DISK_LOG, DIR, FILNAM, EXT, FVERSION, NODE
; Inputs      : 
;	file	- The file name
; Opt. Inputs : 
;	None.
; Outputs     : 
;	disk_log- The disk or logical (looks for a ":")
;		  This is generally only valid on VMS machines
;	dir	- The directory
;	filnam	- The filename (excluding the ".")
;	ext	- The filename extension (including the ".")
;	fversion- The file version (only VMS)
;	node	- The Node name (only VMS)
; Opt. Outputs: 
;	None.
; Keywords    : 
;	None.
; Calls       : 
;	None.
; Common      : 
;	None.
; Restrictions: 
;	VMS:
;		Assumes that : always precedes []
;	ULTRIX:
;		Right now it has trouble with the ultrix option of use
;		of "." or ".."
; Side effects: 
;	None.
; Category    : 
;	Utilities, Operating_system.
; Prev. Hist. : 
;	Written 1988 by M.Morrison
;	   Aug-91 (MDM) Changed to handle Unix filename convensions
;	28-Feb-92 (MDM) * Adjusted to handle arrays
;	11-Mar-92 (MDM) - Perform a STRTRIM(x,2) on input string before
;			  doing the "break-up"
;	 1-Dec-92 (MDM) - Moved code to do filename, extension and version
;			  number for both VMS and Unix (previously it
;			  did not do version number code for Unix)
;	29-Jan-93 (DMZ/MDM) - checked for node in file name
; Written     : 
;	M. Morrison, August 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;	Version 1.1, William Thompson, GSFC, 7 May 1993.
;		Added IDL for Windows compatibility.
;	Version 2, William Thompson, GSFC, 15 June 1995
;		Merged with Yohkoh version.  Added change 11-Nov-93 by D. Zarro
;       	to check for ".]["  and "[000000" in VMS concealed directory
;		names
;
; Version     : 
;	Version 2, 15 June 1995
;-
;
qvms = 1
dummy = where(strpos(file, '/') ne -1, count)		;dummy is where filename has /
if (count ne 0) then qvms = 0		;if there is a /, then count ne 0, and therefore it is not VMS (lots of negatives there)
;
n = n_elements(file)
node     = strarr(n)
disk_log = strarr(n)
dir      = strarr(n)
filnam   = strarr(n)
ext      = strarr(n)
fversion = strarr(n)
;
for ifil=0,n-1 do begin
    file0 = file(ifil)
    file0 = strtrim(file0, 2)		;MDM added 11-Mar-92
    len=strlen(file0)
    ;
    ;-- node name present    ;DMZ added Jan'93
    ;  (if so then strip it off now and then add it back later)
    dcolon=strpos(file0,'::')
    if dcolon gt -1 then begin
	node(ifil)=strmid(file0,0,dcolon+2)
	file0=strmid(file0,dcolon+2,1000)
    endif
    ;
    if (qvms) then begin
	p=strpos(file0,':')
	if (p ne 1) then disk_log(ifil)=strmid(file0,0,p+1)	;includes :
	len=len-p+1
	file0=strmid(file0, p+1, len)

;-- check for .][ in dir    ;-- DMZ added Nov'93

        if strpos(file0,'.][') ne -1 then file0=str_replace(file0,'.][','.')

        p=strpos(file0,']')
        if (p ne -1) then dir(ifil)=strmid(file0,0,p+1)         ;includes ]

;-- check for .000000 in dir  ;-- DMZ added Nov'93

        temp=dir(ifil)
        if strpos(temp,'.000000') ne -1 then dir(ifil)=str_replace(temp,'.000000','')
        len=len-p+1
        file0=strmid(file0, p+1, len)
;
;  William Thompson, added support for Microsoft Windows, 7 May 1993.
;
    end else if !version.os eq 'windows' then begin
	p = strpos(file0,':')
	if p ne -1 then begin
		disk_log(ifil) = strmid(file0,0,p+1)	;Includes :
		len = len - p + 1
		file0 = strmid(file0,p+1,len)
	endif
	p = -1
	while (strpos(file0,'\', p+1) ne -1) do p = strpos(file0,'\',p+1)	;find last \
	dir(ifil) = strmid(file0, 0, p+1)
	file0 = strmid(file0, p+1, len-(p+1))
    end else begin
	p = -1					;WTT changed 7-May-93
	while (strpos(file0,'/', p+1) ne -1) do p = strpos(file0,'/',p+1)	;find last /
	dir(ifil) = strmid(file0, 0, p+1)
	file0 = strmid(file0, p+1, len-(p+1))
    end

    p=strpos(file0,'.')
    if (p eq -1) then begin
	    filnam(ifil) = strmid(file0,0,len) 
	    p=len
    end else filnam(ifil) = strmid(file0,0,p)		 ;not include .
    len=len-p
    file0=strmid(file0, p, len)
    ;
    p=strpos(file0,';')
    if (p eq -1) then begin
	    ext(ifil) = strmid(file0,0,len) 
	    p=len
    end else ext(ifil) = strmid(file0,0,p)			;includes . but not ;
    len=len-p
    file0=strmid(file0, p, len)
    ;
    fversion(ifil) = ''
    if (len ne 0) then fversion(ifil) = file0

    ;-- now prefix disk name with node name
    if node(ifil) ne '' then disk_log(ifil)=node(ifil)+disk_log(ifil)
end
;
if (n eq 1) then begin		;turn output into scalars
    disk_log = disk_log(0)
    dir      = dir(0)
    filnam   = filnam(0)
    ext      = ext(0)
    fversion = fversion(0)
    node     = node(0)
end
;
end

