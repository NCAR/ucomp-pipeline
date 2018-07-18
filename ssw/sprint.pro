pro sprint, filename, pers=pers, font=font, site=site
;
;+
;   Name: sysprint 
;
;   Purpose: test use of ys system variables for printer control
;
;   Input Paramters:
;      filename - file to print (substitute for FILENAME in print command)
;
;   Keyword Parameters
;     pers - if set, personal print command is selected
;     site - if set, site specific print command is selected
;     font - if set, substitute for FONT in print command
;
;   History:
;      slf - 4-feb-1993
;  
;   Restrictions:
;      system varialbes must be defined first (via ys_defsysv.pro)
;
;-
;
if n_params() eq 0 then message,'no file name....'

if not keyword_set(font) then font=!ys_printcmd.font
case 1 of 
   keyword_set(pers): pcommand=!ys_printcmd.pers
   keyword_set(site): pcommand=!ys_printcmd.site
   else:	      pcommand=!ys_printcmd.default
endcase


if pcommand eq '' then begin
   message,/info,'Requested print command not defined'
endif else begin
   pcommand = str_replace(pcommand,'FILENAME',' ' + filename + ' ')
   pcommand = str_replace(pcommand,'FONT',' ' + font + ' ' )
   message,/info,'Print command: ' + pcommand
;   spawn,pcommand
endelse

return
end

