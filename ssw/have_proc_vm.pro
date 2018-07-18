;+
; Project     : HINODE/EIS
;
; Name        : HAVE_PROC_VM
;
; Purpose     : Check if a program is compiled in Virtual Machine
;
; Category    : utility
;
; Explanation : Calls routine_info() to check compiled
;               procedures/functions. This program is useful 
;               in the VM environment when there is no clear !path to search.
;
; Syntax      : IDL> have=have_proc_vm(name)
;
; Inputs      : NAME = program name
;
; Outputs     : HAVE = 1/0 for have/have not
;
; Keywords    : OUTFILE = full name of found file
;               DIR     = path to file
;               SYSTEM  = 1 if built-in system file
;
; History     : Written, 26-Feb-2007, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function have_proc_vm,name,outfile=outfile,dir=dir,_extra=extra,system=system

system=0b
outfile=''
dir=''
if is_blank(name) then return,0b
proc=strupcase(file_break(strtrim(name,2),/no_ext))

;-- check compiled procedures

names=routine_info()
chk=where(proc eq names,count)
if count gt 0 then begin
 stc=routine_info(proc,/source)
 outfile=stc.path
 dir=file_break(outfile,/path)
 return,1b
endif

;-- check compiled functions

names=routine_info(/functions)
chk=where(proc eq names,count)
if count gt 0 then begin
 stc=routine_info(proc,/source,/functions)
 outfile=stc.path
 dir=file_break(outfile,/path)
 return,1b
endif

;-- check system routines

names=routine_info(/system)
chk=where(proc eq names,count)
if count gt 0 then begin
 system=1b
 return,1b
endif

names=routine_info(/system,/functions)
chk=where(proc eq names,count)
if count gt 0 then begin
 system=1b
 return,1b
endif

return,0b
end








