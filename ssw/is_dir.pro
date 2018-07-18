;+
; Project     : HINODE/EIS
;
; Name        : IS_DIR
;
; Purpose     : Test if input is a valid directory
;
; Inputs      : DIR  = directory name to test
;
; Outputs     : None
;
; Keywords    : See IS_DIR2
;
; Version     : Written 12-Nov-2006, Zarro (ADNET/GSFC)
;                  - uses better FILE_TEST
;               Modified 5-Jan-2009, Zarro (ADNET/GSFC)
;                  - return boolean instead of long
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_dir,dir,out=out,count=count,err=err,_extra=extra

forward_function file_test

err=''
derr='Invalid input directory'
count=0
if is_blank(dir) then begin
 err=derr
 return,0b
endif

if since_version('5.4') then begin
 out=chklog(dir,/pre)
 chk=file_test(out,/dir)
 ok=where(chk,count)
 if count eq 0 then err=derr
 return,byte(chk)
endif

return,is_dir2(dir,out=out,err=err,count=count,_extra=extra)

end
