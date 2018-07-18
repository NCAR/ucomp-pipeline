;+
; Project     : HESSI
;
; Name        : GET_TEMP_DIR
;
; Purpose     : return system dependent temporary directory
;
; Category    : system utility
;
; Syntax      : IDL> temp=get_temp_dir()
;
; Outputs     : TEMP = temporary directory pertinent to OS
;
; Keywords    : RESET = do not use last save directory
;              
;
; History     : 25-May-1999,  D.M. Zarro (SM&A/GSFC) - written
;               17 April 2000, Zarro (SM&A/GSFC) - added alternative WINXX
;               temporary directory choices
;               23 October 2013, Zarro (ADNET) - added IDL_TMPDIR
;               12-Apr-2017, William Thompson, added USER_TMPDIR to override
;                      other possible results
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function get_temp_dir,dummy,reset=reset

common get_temp_dir,temp_dir

if keyword_set(reset) then delvarx,temp_dir
if exist(temp_dir) then return,temp_dir

;-- search logical places for temp directory
       
win_choices=['c:\tmp','c:\temp','c:\windows\tmp','c:\windows\temp',$
             'c:\winnt\tmp','c:\winnt\temp']

u_win_choices=strupcase(win_choices)

env_choices=trim2(chklog(['USER_TMPDIR','IDL_TMPDIR','$user_temp','tmp','temp','SYS$SCRATCH']))

home_choices=['$HOME','~']

search_choices=[env_choices,u_win_choices,win_choices,'/tmp',home_choices,curdir()]

for i=0,n_elements(search_choices)-1 do begin
 chk=write_dir(search_choices[i],out=tdir,/quiet)
 if chk then begin
  temp_dir=tdir & return,temp_dir
 endif
endfor

return,temp_dir


end
 
