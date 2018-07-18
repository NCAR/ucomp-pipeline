;+
; Project     : SOHO - CDS
;
; Name        : TEST_OPEN2
;
; Purpose     : Test open a file to determine existence and/or write access
;
; Explanation :
;       Uses OPENR or OPENW (if /WRITE is set) to return status of
;       input file. If input file is not given, then TEST_OPEN will
;       test if the current directory is writeable.
; Use         : 
;	OK=TEST_OPEN(FILE)             ;test for existence
;	OK=TEST_OPEN(FILE,/WRITE)      ;test for write access
; Inputs      : 
;	FILE  = file to test
; Opt. Inputs : 
;	None.
; Outputs     : 
;	OK   = logical 1 for existence and readable
;                   or 0 for nonexistent and/or not writeable (if /WRITE)
; Opt. Outputs: 
;	None.
; Keywords    : 
;       WRITE = If set, then test for write access.
;       QUIET = set to keep quiet
;       NODIR   = do not test if input is a directory (for speed)
;       ERR     = error string
; Category    : 
;	Utilities, Operating_system.
; Written     : 
;	Dominic Zarro, GSFC, 1993.
; Version     : 
;	Version 1, 1 August 1993.
;       Version 2, 15 March 1995, modified, Zarro 
;        --  added check for directory input
;       Version 3, 3 September 1996, Zarro
;        -- added VMS check for non-existent file input
;       Version 4, 2-Feb-1999, Zarro (SM&A) - check for scalar input
;       Version 5, 7-Oct-1999, Zarro (SM&A) - vectorized
;       Version 6, 17-Nov-1999, Zarro (SM&A) - added CATCH, and 
;                  randomized temporary files.
;       Version 7, 18-Dec-2000, Zarro (EIT/GSFC) - allowed checking
;                  current directory write access when input is undefined.
;       Modified: 30-Sept-2005, Zarro (L-3Com/GSFC) 
;                  - removed datatype calls
;       Modified, 14-Nov-2006, Zarro (ADNET/GFSC) 
;                  - renamed to TEST_OPEN2 and called from TEST_OPEN
;-

function test_open2,file,write=write,quiet=quiet,nodir=nodir,err=err,$
                    _extra=exta

err=''

ok=0b 
np=n_elements(file)

if np gt 1 then begin
 ok=bytarr(np)
 for i=0,np-1 do begin
  ok(i)=test_open2(file(i),write=write,quiet=quiet,nodir=nodir,err=terr)
  err=trim(err+' '+terr)
 endfor
 return,ok
endif

if (n_params() eq 0) and (1-keyword_set(write)) then begin
 err='Undefined input'
 message,err,/cont
 return,0b
endif

if is_blank(file) then is_direc=1 else begin
 if not keyword_set(nodir) then is_direc=is_dir2(file,out=out) else is_direc=0
endelse

if is_direc then begin
 del=1b & app=0b & temp=''
 if keyword_set(write) then temp='test_open.'+get_rid() 
 if is_string(out) then temp=concat_dir(out,temp)
endif else begin
 del=0b & app=1b & temp=file 
 if keyword_set(write) then begin
  if not test_open2(temp) then del=1b
 endif
endelse

;-- set some traps. First check for I/O errors, then anything else.

error=0
on_ioerror,trap

if error ne 0 then begin
 trap:
 on_ioerror,null
 ok=0b
 goto,cleanup
endif

;-- use Catch for IDL versions >= 4

if idl_release(lower=4,/inc) then begin
 catch,error
 if error ne 0 then begin
  catch,/cancel
  ok=0b
  goto,cleanup
 endif  
endif

if keyword_set(write) then $
 openw,lun,temp,/get_lun,delete=del,append=app else $
  openr,lun,temp,/get_lun

ok=1b
cleanup:

if ok and exist(lun) then begin 
 handle=fstat(lun)
 if not is_direc then ofile=handle.name
endif

if exist(lun) then begin
 free_lun,lun & close,lun 
endif

quiet=keyword_set(quiet)
if (not ok) and keyword_set(write) then begin
 err='Write access denied'
 if is_string(file) then err=err+': '+file
 if not quiet then  message,err,/contin
endif

return,ok & end


