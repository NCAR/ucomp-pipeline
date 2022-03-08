pro prstr, strarr, lun, file=file, hc=hc, nodelete=nodelete, print=print, $
	close=close, compress=compress, nomore=nomore
;+
;   Name: prstr
;
;   Pupose: print input string array as using format='(a)' to force one 
;	    entry per line (other types use idl standard print defaults)
;
;   Input Parameters:
;      strarr - array to print (will be converted to string)
;      lun    - (optional - in/out) open unit for file 
;
;   Keyword Parameters:
;      file  - file name for output (default is via scratch.pro)
;	       (if not defined, it is output from scratch)
;      print - if set, print out the text 
;      hc    - if set, print out the text (hc=hardcopy=synonym for print)
;      file  - string file name for write (default is via scratch.pro)
;      compress - if set, compress and remove nulls (useful for FITS header)
;      nomore - if set, inhibit 'more-like' behavior (print everything)
;      
;   Calling Sequence:
;      prstr,strarry [,/nomore]		; print string array to terminal
;      prstr,strarry,/print		; scratch file->lpr, delete scratch
;      prstr,strarry,lun		; print strarray to scratch file
;					; (open file if lun is undefined)
;      prstr,strarry,lun,file=fname	; user supplies file 
;      prstr,strarry,lun,/print		; same, close, print, delete
;      prstr,strarry,lun,/print,/nodel  ; dont delete scrat
;
;   History: 
;      slf, circa June 1992
;      slf, 18-jan-1993 - added file and hc keywords
;      slf,  5-mar-1993 - use scratch.pro for temp files
;      slf,  2-jun-1993 - add close keyword
;      mdm,  3-Jun-1993 - Closed the file when LUN is not used in the call
;      slf, 29-jul-1993 - added compress keyword and function
;      slf, 12-aug-1993 - added 'more' logic to terminal print, input chk
;			  added nomore keyord
;      slf, 18-apr-1994 - call more.pro for tty output
;-
nlines=n_elements(strarr)
sizearr=size(strarr)

if nlines eq 0 then begin
   message,/info,'No input, returning...
   return
endif

prarr = strarr


; handle parameter/keyword combinations
printnow=keyword_set(print) or keyword_set(hc)   ; print on exit
; if lun was passed in defined, see if it is a unit open for write
lundef=0
if n_elements(lun) eq 1 then begin
   fstatus=fstat(lun)
   lundef=(lundef or fstatus.write) 
endif   

; do we delete file on exit?
nodelete=keyword_set(nodelete) or (lundef and 1-printnow) 

; decide when to open file (I know this looks convoluted (it is), but this 
; allows appending to open or closed files)
opennow=printnow and (1-lundef) or (keyword_set(file) and 1-lundef) or $
	(n_params() eq 2 and 1-lundef)

new=keyword_set(file) or n_elements(lun) eq 0 
; now open scratch file if appropriate
if opennow then scratch, lun, /open, file=file, names=names

if n_elements(lun) eq 0 then lun=-1		; default to terminal

if keyword_set(compress) then begin
   prarr=strtrim(strcompress(prarr),2)
   nonnull=where(prarr ne '', nncount)
   if nncount gt 0 then prarr=prarr(nonnull)
endif

nlines=n_elements(prarr)				; redefine
pagesize=24						; lines/page

more = 1-keyword_set(nomore) and getenv('ys_nomore') eq '' 
case sizearr(n_elements(sizearr) -2) of
   7: begin
      if lun ne -1 or (1-more) then $
         printf,lun,prarr,format='(a)' else more,prarr
   endcase
   else: printf,lun,prarr		; pass non strings to printf
endcase

;close=keyword_set(close)
close=keyword_set(close) or (n_params() eq 1)	;MDM added 3-Jun-93
case 1 of 
   printnow: scratch, lun, /print, nodelete=nodelete, file=file, names=names
   close and lun ne -1: free_lun,lun 
   else:
endcase
if n_elements(file) eq 0 and n_elements(names) ne 0 then file=names	; output

return
end
