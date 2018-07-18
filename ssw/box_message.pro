pro box_message, message_array, _extra=_extra, btext=btext, quiet=quiet, $
	  nbox=nbox
;+
;   Name: box_message
;
;   Purpose: message to user, highlight with box around text
;
;   Input Parameter:
;      message_array - string or string array to print
;  
;   Keyword Paramters:
;      _extra - keywords accepted by 'strjustify.pro' (/left,/right,/center)
;     btext (output) - generated boxed text  (see strjustify,/box)
;     nbox - number of boxes (frivilous) default=1
;            number of boxes to nest message (via recursion)
;   Calling Sequence:
;
;   IDL> box_message,message_array        ; (usually called from program)
;   IDL> box_message                      ; default message (call pr_status)
;
;   Calling Examples:
;   IDL> box_message,str2arr('WARNING,Important Message...,Your Message,HERE')
;      ----------------------
;     | WARNING              |
;     | Important Message... |
;     | Your Message         |
;     | HERE                 |
;      ----------------------
;   
;   IDL> box_message
;   -----------------------------------------
;  | User Name: freeland                     |
;  | Host Name: sxt1.space.lockheed.com      |
;  | Directory: /sxt1data1/ssw/site/idl/http |
;  |                                         |
;  | Local Time:  7-NOV-97  14:34:51         |
;  | UT Time   :  7-NOV-97  22:34:51         |
;  |                                         |
;  | IDL Version: 4.0.1                      |
;  | Host OS    : OSF                        |
;  | Host ARCH  : alpha                      |
;   -----------------------------------------
;   
;   Method: Just call "prstr,strjustify(message_array,/box)),/nomore"
;            (nomore switch used to allow background/cron processing)
;           or "pr_status" if no message supplied (system info message)
;  
;   History:
;      7-november-1997 - S.L.Freeland - finally tired of typing this
;                        common 2-routine call combination.  
;            
if n_elements(nbox) eq 0 then nbox=1 
case 1 of
   data_chk(message_array,/string): $
      btext=strjustify(message_array,/box,_extra=_extra)
   else: pr_status,btext
endcase

; if more than 1 box, recurse on boxed output till done
if nbox gt 1 then box_message, btext, nbox=nbox-1,/quiet, btext=btext

; silence output on request
if not keyword_set(quiet) then prstr,btext,/nomore

return
end
