function rd_tfile, filename, ncols, skip, hskip=hskip,$
		 delim=delim, nocomment=nocomment, compress=compress, 	$
		 quiet=quiet, autocol=autocol, convert=convert, header=header, $
		 first_char_comm=first_char_comm
;+
;   Name: rd_tfile
;
;   Purpose: read/return contents of text file - optionally interpret
;	     and convert text table data
;		
;   Input Paramters:
;      filename - string variable containing file name to read
;      ncols - (optional) #colunms (output will be matrix, strarr(NCOLSxN)
;      skip  - (optional) #lines to skip (header) for readfile compatibile 
;	                  (if skip=-1, first non-numeric lines are skipped)
;
;   Output Parameters:
;      function returns file contents (string array(list) or matrix)
;		if convert is set, auto-convert to numeric data type
;      
;   Keyword Parameters:
;      delim     - table column delimiter (default is blank/tab)
;      nocomment - if=1 (switch) , remove lines with (unix:#, vms:!)
;		   if string (scaler), remove lines with specified character
;      compress  - eliminate leading/trailing blanks and excess whitespace
;		   (for table data (ncols gt 1), compress is assumed)
;      quiet     - if set, suppress warning messages
;      autocol   - if set, derive column count from first non-comment line
;      convert   - if set, convert to numeric data type
;      header    - output string(array) containing header lines
;      hskip	 - header skip (sets skip to -1)
;      first_char_comm - if set, only apply "nocomment" flag when the
;		   comment character is the first character
;   
;   Calling Sequence:
;						;      RETURNS
;      text=rd_tfile(filename)                  ; orig. file-> string array
;      text=rd_tfile(filename,/nocomment)       ; same less comment lines
;      text=rd_tfile(filename,/compress)        ; same less excess blanks
;      data=rd_tfile('text.dat',3)              ; strarr(3,N) (table data)
;      data=rd_tfile('fdata.dat',/auto,/convert); determine n columns and
;                                               ; data type automatically
;      data=rd_tfile(filename,/hskip,head=head) ; return file header in head
;
;
;   History:
;      slf,  4-Jan-1992 - for yohkoh configuration files 
;      slf,  6-Jan-1992 - remove partial comment lines 
;      slf, 11-feb-1993 - added autocol keyword and function
;			  added convert keyword and function
;      slf, 28-Oct-1993 - temp fix for VMS variable length files
;      slf, 26-jan-94 fixed bug if /auto and user supplied comment char
;      dmz, 3-Mar-94 - changed type to type/nopage (for vms), otherwise
;                      it is really slow
;      slf, 21-May-94 - fix bug in /convert auto skip function (allow '-' !!)
;      mdm, 15-Mar-95 - Modified to not crash on reading a null file.
;      mdm, 12-Oct-95 - Modification to allow tab character to be the delimiter.
;      slf, 27-mar-96 - Put MDM oct change online
;      ras, 19-jun-96 - Use rd_ascii in vms
;      slf, 29-may-97 - force FILENAME -> scalar  
;      slf, 16-sep-97 - allow ascii files with NO carraige returns
;      slf,  6-oct-97 - include last line which has NO carraige return
;      mdm, 25-Nov-97 - Made FOR loop long integer
;      mdm,  7-Apr-98 - Print the filename when NULL
;      slf, 19-aug-98 - per MDM report, free lun on read error
;      mdm, 11-Feb-99 - Added /first_char_comm
;
;   Category:
;      gen, setup, swmaint, file i/o, util
;
;   Method:
;      files are assumed to be ascii - file contents read into a variable
;      if ncols is greater than 1, then a table is assumed and a string
;      matrix is returned - table is null filled for non existant table 
;      entries (ncols gt 1 forces white space removal for proper alignment)
;
;-
; -----------  handle input parameter setup and assign defaults -------------
; set up defaults
if not keyword_set(delim) then delim=' '	; blank/tab is default
if not keyword_set(ncols) then ncols=1		; default is text list
if keyword_set(hskip) then skip=-1		; skip header
if n_elements(skip) eq 0 then skip=0
if (keyword_set(first_char_comm)) and (not keyword_set(nocomment)) then nocomment = first_char_comm
;
qtemp=!quiet					; avoid global effects
!quiet=keyword_set(quiet)
; 
; if table data (ncols gt 1) then override nocomp flag to force proper
; table alignment....
convert=keyword_set(convert)		; convert text to numeric
autocol=keyword_set(autocol)		; auto-determine number columns
numeric= (skip eq -1) or convert		; 
compress= ( (keyword_set(compress)) or (ncols ne 1) or autocol or numeric) and (delim ne string(9b))
;
; for table, force removal of comment lines (returning table)
if not keyword_set(nocomment) then $
   nocomment=ncols ne 1  or autocol or convert
;
; ----------------------------------------------------------------------------
;
data=''						; initialize return
; read file into text buffer
on_ioerror, openerror
filename=filename(0)                          ;  force scalar
if strupcase(!version.os) ne 'VMS' then begin
   openr,lun,/get_lun, filename
   on_ioerror, readerror
; ---------  slf, 5-Jan-1992 read into one byte buffer for speed -------
; 	     (replaced read line till eof which was too slow)
   fstatus=fstat(lun)				; determine file size
   if (fstatus.size ne 0) then begin
      btext=bytarr(fstatus.size)		; byte buffer for all
      readu,lun,btext				; read into byte buffer
      wlfs=where(btext eq 10b,lfcount)		; number of line feeds
      if lfcount eq 0 then begin
	 text=string(btext)                     ; NO Line feed case
      endif else begin
         btext=0				; release memory
         text=strarr(lfcount)			; now use string arrary
         point_lun,lun,0			; reset to beginning
         readf,lun,text				; read into string array
         fstatus=fstat(lun)			; re-check status
         remainder=fstatus.size - fstatus.cur_ptr
	 if remainder gt 0 then begin
             lastline=bytarr(remainder)
             readu,lun,lastline
	     text=[temporary(text),string(lastline)]
	 endif	   
      endelse
   end else begin
      text = ''
   end
   free_lun,lun
endif else begin
   ;message,/info,'VMS Temp Fix, may be slow...'
   ;spawn,'type/nopage ' + filename,text
   text=rd_ascii(filename)
endelse

; ------------------------------------------------------------------------
; ------------ optional non-numeric header skip function ----------------
; header has non-numeric (0,1,...9 or decimal point) first character
header=keyword_set(header) or (skip eq -1)
if numeric then begin			; auto-skip non-numerical header
   ttext=strmid(strtrim(text,1),0,1)	; first non-blank character
   firstbyte=byte(ttext)
;  slf 21-may-94 add negative (-) to valid numeric first character
   special=where(firstbyte eq 46b or firstbyte eq 45b,dcnt)
   if dcnt gt 0 then firstbyte(special)=48b ; force in range
   numerics=where(firstbyte ge 48b and firstbyte le 57b,ncnt)
   if ncnt eq 0 then skip=0 else  skip=numerics(0)
endif

header=''
if skip ge n_elements(text) then begin
   message,/info,'Skip lines greater than file lines!'
   header=text
   text=''
endif else begin
   if skip gt 0 then header = text(0:skip-1)
   text=text(skip:*)   
endelse
;

if numeric then if ncnt gt 0 then text=text(numerics-skip)

; ----------- optional compression and whitespace elimination -----------------
; eliminate excess whitespace, leading and trailing blanks, null lines
; unless otherwise indicated (ie, nocomp is set)
if compress then begin
   text=strtrim(strcompress(text),2)
   nonnulls = where(text ne '',nncount)
   if nncount eq 0 then begin
      message,/info,'Null file! (' + filename + ')'
      return,data
   endif else text=text(nonnulls)
endif
; ----------------------------------------------------------------------------
;
; -------------- optional comment elimination ---------------------------------
;
; ('wordy' to handle partial comment lines and retension of existing null lines)
;
gtext=text					; 'good' text
if keyword_set(nocomment) then begin		; remove comment lines
   scomment=size(nocomment)
   comtype=scomment(n_elements(scomment)-2)
;  allow user-supplied delimiter or use default if nocomment use as switch
   case comtype of
      7:    comchar=nocomment			; user supplied comment char
      else: case strupcase(!version.os) of 
	       'VMS': comchar='!'       	; assume VMS command file
	       else: comchar='#'		; assume unix script 
	    endcase
   endcase
   compos=strpos(gtext,comchar)
   if (keyword_set(first_char_comm)) then wherecom=where(compos eq 0, ccount) $
				else wherecom=where(compos + 1, ccount)
;   wherecom=where(compos + 1, ccount)
;  for each line containing a comment character
   for j=0L,ccount-1 do begin
         gtext(wherecom(j)) = $
	    strmid(gtext(wherecom(j)),0,compos(wherecom(j)))
   endfor
;  
;  dont delete 
   if ccount gt 0 then begin
      newnulls=where(gtext(wherecom) eq '',nncount)
      if nncount gt 0 then begin
         delpat='rd_tfile_delete'
         gtext(wherecom(newnulls)) = delpat		; mark for deletion
         keep = where(gtext ne delpat,kcount)
         if kcount gt 0 then gtext=gtext(keep) else begin
            message,/info,'Nothing left after removing comment lines!'
	    return,data
	 endelse
      endif
   endif
endif
; ----------------------------------------------------------------------------
;
; ------------- auto column determination function -------------------------
if autocol then begin			; determine number columns from 1st
   testcol=str2arr(gtext(0),delim)
   ncols=n_elements(testcol)
endif
; ---------------------------------------------------------------------------
; ------------- matrix formation (table data) -------------------------------
; fill in matrix if ncols gt 1
if ncols eq 1 then data=gtext else begin
   data=strarr(ncols,n_elements(gtext))
   for i=0L,n_elements(gtext)-1 do begin
      array = str2arr(gtext(i),delim)
      array = array(0:min([ncols-1,n_elements(array)-1]) )      
      data(0,i) = array
   endfor
endelse

!quiet=qtemp
;
if compress then data=strtrim(data,2)	; clean up substrings
; 
; ------------ optional numeric data type conversion -----------------------
; slf, 11-feb-1993
; add data type conversion code for convenience - assume user knows what 
; shes doing. Of course, user can do this outside of this routine:
; for example, data=fix(rd_tfile(file,/auto))

if convert then begin			; auto convert
   data=strupcase(data)
   bdata=byte(data)			; always ok
;  are these floating numbers?
   decimal=where(bdata eq 46b,dcnt)
   eexp=where(bdata eq 69b,ecnt)	
   on_ioerror,cnverror
   if (dcnt or ecnt) gt 0 then data=float(data) else begin
      data=long(data)
      case 1 of
;        max(data) lt 256:    data=byte(data)   ; do we want this?
         max(data) lt 32768l: data=fix(data)	; fix it
	 else:					; leave it long
      endcase
   endelse
endif
;
;-----------------------------------------------------------------------------
;
; normal completion, return the data
;
return, data
;
;
; i/o and type conversion errors
openerror:
message,/info,'No file: ' + filename
!quiet=qtemp
return,data
readerror:
free_lun,lun
message,/info,'Error reading file: ' + filename
!quiet=qtemp
return,data
cnverror:
free_lun,lun
message,/info,'Error converting text to numeric data in file: ' + filename
!quiet=qtemp
return,data
end


