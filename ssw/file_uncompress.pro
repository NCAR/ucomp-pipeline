pro file_uncompress, inname, outname, noreplace=noreplace , newname=newname, $
	verbose=verbose, compfact=compfact, debug=debug, outdir=outdir
;
;+
;   Name: file_uncompress
;
;   Purpose: provide IDL interface to standard unix uncompress utility
;
;   Input Paramters:
;      inname - file name or vector of file names to uncompress
;
;   Output Parameters:
;      outname - uncompressed file names (same dimension as inname)
;		 (usually, inname without .Z extension, null if problem)
;
;   Optional Keyword Parameters
;	noreplace - (input) - switch, if set, don't replace inname with outname 
;	newname   - (input)   NOT IMPLEMENTED specify outname
;       outdir    - (input)   specify output directory (only if /noreplace)
;
;   Calling Sequence:
;	file_compress, inname [, outname ,/noreplace , outdir=outdir ]
;
;   History:  1-Jul-93 (SLF)
;	      7-Oct-93 (SLF) Added OUTDIR keyword parameter
;	     14-Mar-94 (SLF) enclose file names in quotes (embedded meta-char)
;
;   Restrictions: UNIX only 
;-

if keyword_set(newname) then begin
   tbeep
   message,/info,'NEWNAME keyword not yet implemented
endif

iname=str_replace(inname,'.Z','') 		; uncompress expects no .Z

verbose=''
;
; check input file validity
chk_files=file_exist(iname + '.Z')
some=where(chk_files,scount)
none=where(1 - chk_files,ncount)
   
if scount eq 0 then begin
   message,/info,'No input files exist, returning...'
   return
endif else begin
   if ncount gt 0 then begin
      message,/info,'The following input files do not exist:'
      print,iname(none),format='(a)'
   endif
endelse
   
; assign output file names
outname=strarr(n_elements(iname))
outname(some)=str_replace(iname(some),'.Z')	; force normal convention

case 1 of
   keyword_set(noreplace): begin
;  noreplace keyword overrides default (preserve existing file)
;     if outdir is specified, place the uncompressed file there
      if keyword_set(outdir) then begin
         break_file,iname(some),ilog,idir,iiname,iext,ivers
         oname=iiname + iext + ivers
         outname(some) = concat_dir(outdir,oname)
      endif                   

      for i=0,n_elements(some)-1 do begin
         spawn,'uncompress -vcf ' + '"' + iname(some(i)) + '" > ' + outname(some(i)), status
         verbose=[verbose,status]
      endfor
      endcase
;  default action is to replace existing (inname) file
   else: begin
      for i=0,n_elements(some)-1 do begin
         spawn,'uncompress -vf ' + '"' + iname(some(i))+ '"', status
         verbose=[verbose,status]
      endfor
      endcase
endcase
verbose=verbose(1:*)

chk_comp=file_exist(outname(some))
compprob=where(1-chk_comp,ccount)

if ccount gt 0 then begin
   tbeep
   message,/info,'Problem uncompressing the following files:'
   print,iname(some(compprob))
   outname(some(compprob))=''		; make null
endif
if keyword_set(debug) then stop
return
end
