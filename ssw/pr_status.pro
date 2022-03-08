pro pr_status, text , noprint=noprint, idlcomment=idlcomment, caller=caller, $
	header=header, idldoc=idldoc, print=print
;
;+
;   Name: pr_status
;
;   Purpose: print and/or return some status info
;            (userid, hostid, idl version, local and uttime)
;
;   Input Parameters:
;      NONE:
;   Output Parameters:
;      text - formatted status info
;
;   Keyword Parameters:
;      noprint -    if set dont print to terminal
;      idlcomment - if set, prepend comment chars ";" so text can be inserted in idljob
;      idldoc     - same as idlcomment, with doc delimters added (;+  ;-)
;      caller - string name of routine calling (adds a line to status info)
;      header - string or string array of user info to prepend to status info
;      
;   Calling Examples:
;     pr_status			   ; display to terminal
;     pr_status,text, /noprint     ; return via text paramter
;     pr_status,text, /idldoc	   ; prepend idl doc delimiters (;+...;...;-)
;     pr_status,text, /idldoc, caller="ROUTINE" ; adds a line to status info
;     pr_status,text, header=strarry ; user info to prepend
;     pr_status,text, /idlcomment  ; prepend ";" for insertion into idl jobfiles
;     (the above command returns the following...)
;  -------------------------------------------
; | User Name: freeland                       |
; | Host Name: isass2.solar.isas.ac.jp        |
; | Directory: /usr/people/freeland/dev/batch |
; |                                           |
; | IDL Version: 3.5.1                        |
; | Host OS    : ultrix                       |
; | Host ARCH  : mipsel                       |
; |                                           |
; | Local Time:  1-OCT-94  15:12:34           |
; | UT Time   :  1-OCT-94  06:12:34           |
;  -------------------------------------------
;
;   History:
;      1-Oct-1994 (SLF)
;-
print=keyword_set(print) or n_params() eq 0
noprint=keyword_set(noprint) or (n_params() eq 1 and (1-keyword_set(print)))
idldoc=keyword_set(idldoc)
idlcomment=keyword_set(idlcomment) or keyword_set(idldoc)

qtemp=!quiet
!quiet=1
user=["User Name: " + get_user()]
host=["Host Name: " + get_host()]
pwd =["Directory: " +  curdir()]
release =!version.release
hostarch=!version.arch
hostos  =!version.os
idl =["IDL Version: " + release, $
      "Host OS    : " + hostos,  $
      "Host ARCH  : " + hostarch]              
localt= ["Local Time: " +  fmt_tim(!stime)]
utt   = ["UT Time   : " + ut_time()]

text=[user,host, pwd,"",localt,utt,"",idl]
if data_chk(caller,/string)  then $
   text=["Status Called From Routine: " + caller,"",text]
if data_chk(header,/string) then $
   text=[header,"",text]

text=strjustify(text,/box)			; format and box-it

if idlcomment then text = "; " + text 		; to include in idl files

if idldoc then text = [";+",text,";-"]		; ditto and work w/doc_library 

if not noprint then more,text			; good grammer?

!quiet=qtemp
return
end
