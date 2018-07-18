;+
; Project     : HESSI
;                  
; Name        : IS_DIR2
;               
; Purpose     : platform/OS independent check if input name is a 
;               valid directory.
;                             
; Category    : system utility
;               
; Explanation : uses 'cd' and 'catch'
;               
; Syntax      : IDL> a=is_dir(name)
;
; Inputs      : NAME = directory name to check
;               
; Outputs     : 1/0 if success/failure
;               
; Keywords    : OUT = full name of directory
;             : COUNT = # of valid directories
;             : EXPAND = expand input using chklog
;             
; Restrictions: Needs IDL version .ge. 4. Probably works in Windows
;               
; Side effects: None
;               
; History     : Written, 6-June-1999, Zarro (SM&A/GSFC)
;               Modified, 2-Dec-1999, Zarro - add check for NFS /tmp_mnt
;               Modified, 3-Jan-2002, Zarro - added check for input
;                directory as environment variable
;               Modified, 26-May-2002, Zarro - extended check for input
;                directory as environment variable
;               Modified, 20-Jan-2003, Zarro - removed check for input
;                directory as environment variable for Unix
;               Modified, 7-Sep-2005, Zarro (L-3Com/GSFC) - made /expand
;                the default
;               Modified, 15-Nov-2006, Zarro (ADNET/GSFC) - renamed to IS_DIR2
;
; Contact     : dzarro@solar.stanford.edu
;-    

;-- utility for removing /tmp from NFS mount point names 

pro rem_tmp,name,tname

if (exist(name)) then tname=name

sz=size(name)
if sz[n_elements(sz)-2] ne 7 then return
if os_family(/lower) ne 'unix' then return
                                             
item='/tmp_mnt/'
tmp=strpos(name,item)
if tmp eq 0 then begin
 tname=strmid(name,strlen(item)-1,strlen(name))
endif

return & end

;-----------------------------------------------------------------------------

pro fix_drive,name,tname

if (exist(name)) then tname=name
sz=size(name)
if sz[n_elements(sz)-2] ne 7 then return

if os_family(/lower) ne 'windows' then return
len=strlen(tname)
cpos=strpos(tname,':')
if (cpos+1) eq len then tname=tname+'\'
return
end

;-----------------------------------------------------------------------------

function is_dir2,name,out=out,count=count,err=err,expand=expand

if is_number(expand) then expand= 0b > expand < 1b else expand=1b

err=''
count=0
if exist(name) then out=name

sz=size(name)
if sz[n_elements(sz)-2] ne 7 then begin
 err='Missing or non-string directory name'
 out=''
 return,0b
endif

np=n_elements(name)

;-- use recursion for vector inputs

if np gt 1 then begin
 bool=bytarr(np)
 out=strarr(np)
 for i=0,np-1 do begin
  bool[i]=is_dir2(name[i],out=tout,err=err,expand=expand)
  out[i]=tout
 endfor
 if np eq 1 then bool=bool[0]
 chk=where(bool,count)
 return,bool
endif

;-- only expand environment if there is a preceding $ or /expand 

out=''
if keyword_set(expand) then cname=chklog(name,/pre) else begin
 cname=strtrim(name[0],2)
 have_dollar=strpos(strtrim(cname,2),'$') eq 0
 if have_dollar then cname=chklog(name,/pre)
endelse

if cname eq '' then begin
 err='Blank directory name'
 return,0b
endif

;-- save current directory

cd,curr=curr

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 cd,curr
 out=''
 err='Non-existent or unreadable directory => '+cname
 return,0b
endif

;-- patch for UNIX NFS mounts with /tmp_mnt

rem_tmp,cname,tname

;-- patch for Windows drive letter entered without a \, e.g. c:

fix_drive,cname,tname

;-- try to 'cd' to 'name' and catch error 

cd,tname
cd,curr,curr=tout
rem_tmp,tout,out

;-- 'cd' succeeded so 'name' is a valid directory

count=1
return,1b

end
