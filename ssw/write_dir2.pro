;+
; Project     : HESSI
;                  
; Name        : WRITE_DIR2
;               
; Purpose     : platform/OS independent check if directory as write permission
;                             
; Category    : system utility
;               
; Explanation : uses 'openw'
;               
; Syntax      : IDL> a=write_dir(name)
;    
; Inputs      : NAME = directory name to check
;               
; Outputs     : 1/0 if success/failure
;
; Keywords    : OUT = translated name of input directory
;               VALID_DIR = 1/0 if NAME is valid/invalid directort
;             
; Restrictions: Probably works in Windows
;               
; History     : Written,  6-June-1999, Zarro (SM&A/GSFC)
;               Modified, 29-Nov-1999, Zarro - added call to TEST_OPEN
;               Modified, 13-Mar-2000, Zarro - vectorized
;               Modified, 17-Sep-2005, Zarro (L-3Com/GSFC) - added VALID_DIR
;               Modified, 15-Nov-2006, Zarro (ADNET/GSFC) - renamed to WRITE_DIR2
;
; Contact     : dzarro@solar.stanford.edu
;-    

function write_dir2,name,out=out,valid_dir=valid_dir,_ref_extra=extra

np=n_elements(name)

if np eq 0 then begin
 out=''
 valid_dir=0b
 return,0b
endif

out=strarr(np)
access=bytarr(np)
valid_dir=bytarr(np)
for i=0,np-1 do begin
 valid_dir[i]=is_dir2(name[i],out=tout,_extra=extra)
 if valid_dir[i] then begin
  access[i]=test_open2(tout,/write,_extra=extra)
  out[i]=tout
 endif
endfor

if np eq 1 then begin
 access=access[0]
 out=out[0]
 valid_dir=valid_dir[0]
endif

return,access

end
