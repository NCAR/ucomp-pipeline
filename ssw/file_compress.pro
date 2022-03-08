pro file_compress, inname, outname, noreplace=noreplace , newname=newname, $
	verbose=verbose, compfact=compfact, dirs=dirs
;
;+
;   Name: file_compress
;
;   Purpose: provide IDL interface to standard unix compress utility
;
;   Input Paramters:
;      inname - file name or vector of file names to compress
;
;   Output Parameters:
;      outname - compressed file names (same dimension as inname)
;		 (usually, = inname.Z ; null if problem w/input or compress)
;
;   Optional Keyword Parameters
;	noreplace - (input) - switch, if set, don't replace inname with outname 
;	newname   - (input)   NOT IMPLEMENTED specify outname
;
;   Calling Sequence:
;	file_compress, inname [, outname ,/noreplace]
;
;   History: 30-Jun-93 (SLF)
;	     11-Jul-93 (SLF) Added dirs keyword and function
;	     15-Mar-93 (SLF) enclose in quotes (embedded meta-characters)
;-

if keyword_set(newname) then begin
   tbeep
   message,/info,'NEWNAME keyword not yet implemented
endif

; compress all files in specified directories
if keyword_set(dirs) then begin
   if n_elements(inname) ne 0 then begin
      message,/info,"Can't specify files AND directories, returning...
      return
   endif else begin
      inname=''		; init array
      for i=0,n_elements(dirs)-1 do $
	 inname=[inname,concat_dir((dirs(i)),'*')]
      goodn=where(inname ne '', gcount)
      if gcount gt 0 then inname=inname(goodn) else begin
         message,/info,'No files found in specified directories, returning...'
         return
      endelse 
   endelse      
endif

verbose=''
;
; check input file validity
chk_files=file_exist(inname)
some=where(chk_files,scount)
none=where(1 - chk_files,ncount)
if ncount gt 0 and scount eq 0 then begin
   message,/info,'No input files exist, returning...'
   return
endif else begin
   if ncount gt 0 then begin
      message,/info,'The following input files do not exist:'
      print,inname(none),format='(a)'
   endif
endelse
   
; assign output file names
outname=strarr(n_elements(inname))
outname(some)=inname(some) + '.Z'	; force normal convention

case 1 of
   keyword_set(noreplace): begin
;  noreplace keyword overrides default (preserve existing file)
      for i=0,n_elements(some)-1 do begin
         spawn,'compress -vcf ' + '"' + inname(some(i)) + '" > ' + $
	   '"' + outname(some(i)) + '"', status
         verbose=[verbose,status]
      endfor
      endcase
;  default action is to replace existing (inname) file
   else: begin
      for i=0,n_elements(some)-1 do begin
         spawn,'compress -vf ' + '"' + inname(some(i)) + '"' , status
         verbose=[verbose,status]
      endfor
      endcase
endcase
verbose=verbose(1:*)

chk_comp=file_exist(outname(some))
compprob=where(1-chk_comp,ccount)
if ccount gt 0 then begin
   tbeep
   message,/info,'Problem compressing the following files:'
   print,inname(some(compprob))
   outname(some(compprob))=''		; make null
endif

return
end
