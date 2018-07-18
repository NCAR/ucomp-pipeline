;+
; Project     : SOHO - CDS     
;                   
; Name        : HAVE_PROC
;               
; Purpose     : Check if a program exists in !path
;               
; Category    : utility
;               
; Explanation : calls 'which' and saves result in common block
;               
; Syntax      : IDL> have=have_proc(name)
;    
; Inputs      : NAME = program name
;               
; Outputs     : HAVE = 1/0 for have/have not
;
; Keywords    : OUTFILE = full name of found file
;
; Restrictions: Only checks routine name (ignores extensions such as .pro)
;               
; History     : Version 1,  10-Jul-1998, Zarro (SAC/GSFC)
;               Modified, Zarro (SM&A/GSFC), 8 Oct 1999
;                -- added OUTFILE keyword
;               Modified, Zarro (EIT/GSFC), 8 Aug 2000
;                -- added check for  blank outfile
;               Modified, Zarro (EER/GSFC), 3 Feb 2003
;                -- added /INIT
;               Modified, Zarro (ADNET), 26 Feb 2007
;                -- added call to have_proc_vm for Virtual Machine
;               Modified, Zarro (ADNET), 16 Jan 2014
;                -- removed extension from input proc name to avoid
;                   duplicate names.
;               3-Jan-2015, Zarro (ADNET)
;                -- added LMGR(/VM) check
;               13-March-2017, Zarro (ADNET)
;                -- added check for input without .pro extension.
;
; Contact     : dzarro@solar.stanford.edu
;-            

function have_proc,name,outfile=outfile,dir=dir,init=init,_ref_extra=extra


common have_proc,last_names

if keyword_set(init) then delvarx,last_names
status=0b
outfile=''
dir=dir
if is_blank(name) then return,status

ext=file_break(name,/ext)
if is_string(ext) && ext ne '.pro' then return,status

;-- check if running in VM mode

if ~keyword_set(init) && lmgr(/vm) then begin
 chk = have_proc_vm(name,outfile=outfile,dir=dir,_extra=extra) 
 if is_string(outfile) then return,1b
endif

;-- check if initializing

tname=file_break(name,/no_ext)

;-- check first if routine name has been searched. If so, and !path hasn't
;   changed, then we are done

in_common=0
if is_struct(last_names) then begin 
 chk=where(tname eq last_names.name,count)
 in_common=(count gt 0)
 if in_common then begin
  same_path=last_names[chk].path eq !path
  if same_path then begin
   if last_names[chk].in_path then begin
    outfile=last_names[chk].fname
    dir=file_break(outfile,/path)
    return,1b
   endif
  endif
 endif
endif

;-- search !path here

dprint,'% HAVE_PROC: searching...'
which,tname,out=out,/quiet
outfile=trim(out[0])
in_path=outfile ne ''
if in_common then begin
 last_names[chk].in_path=in_path 
 last_names[chk].path=!path
 last_names[chk].fname=outfile
endif else begin
 temp={name:tname,path:!path,in_path:in_path,fname:outfile}
 last_names=merge_struct(last_names,temp,/no_copy)
endelse


dir=file_break(outfile,/path)
return,in_path & end

