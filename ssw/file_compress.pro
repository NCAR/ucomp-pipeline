pro file_compress, inname, outname, noreplace=noreplace , newname=newname, $
	verbose=verbose, compfact=compfact, dirs=dirs, loud=loud, type_comp=type_comp
;
;+
;   Name: file_compress
;
;   Purpose: provide IDL interface to gzip and Unix compress utility
;
;   Input Paramters:
;      inname - file name or vector of file names to compress
;
;   Output Parameters:
;      outname - compressed file names (same dimension as inname)
;		 (usually, = inname.Z, if type_comp=2 is set, then = inname.gz
;                 null if problem w/input or compress)
;
;
;   Optional Keyword Parameters
;	noreplace - (input) - switch, if set, don't replace inname with outname 
;	newname   - (input)   NOT IMPLEMENTED specify outname
;       type_comp - (input) - values: none, 1: use Unix compress; 2: use gzip 
;
;   Calling Sequence:
;	file_compress, inname [, outname ,/noreplace]
;
;   History: 30-Jun-93 (SLF)
;	     11-Jul-93 (SLF) Added dirs keyword and function
;	     15-Mar-93 (SLF) enclose in quotes (embedded meta-characters)
;            11-apr-95 (SLF) made the default quiet - use /loud to override
;            09-Dec-97 (PGS) Added type_comp = 2 cause compression with gzip
;-
loud=keyword_set(loud)
vswitch=(['','v'])(loud)
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
;
if ncount gt 0 and scount eq 0 then begin
   message,/info,'No input files exist, returning...'
   return
endif else begin
   if ncount gt 0 then begin
      message,/info,'The following input files do not exist:'
      print,inname(none),format='(a)'
   endif
endelse
;   
; assign output file names
outname=strarr(n_elements(inname))
;
IF (1 - keyword_set(type_comp)) THEN type_comp = 1
IF ((type_comp gt 2) OR (type_comp lt 0)) THEN type_comp = 1
; 
tsuffix = ['','.Z','.gz']  ; tsuffix(0) should never happen (see next line)
      outname(some)=inname(some) + tsuffix(type_comp); force normal convention
      case 1 of
         keyword_set(noreplace): begin
         ;  noreplace keyword overrides default (preserve existing file)
         for i=0,n_elements(some)-1 do begin
            CASE 1 OF
            (type_comp ne 2):  BEGIN   ;changed equal to NE dec-17-97: default -> .Z
               spawn,'compress -' + vswitch + 'cf ' + '"'+inname(some(i))+'" > ' + $
	       '"' + outname(some(i)) + '"', status
                           END
             ELSE: BEGIN
               spawn,'gzip -' + vswitch + '9cf ' + '"'+inname(some(i))+'" > ' + $
               '"' + outname(some(i)) + '"', status
                   END
              ENDCASE  
;
         verbose=[verbose,status]
      endfor
   endcase
   ;  default action is to replace existing (inname) file
   else: begin
      for i=0,n_elements(some)-1 do begin
         CASE 1 OF
         (type_comp NE 2): spawn,'compress -' + vswitch + 'f ' + '"' + inname(some(i)) + '"' , status
         ELSE:   spawn,'gzip -' + vswitch + '9f ' + '"' + inname(some(i)) + '"' , status
         ENDCASE
         verbose=[verbose,status]
      endfor
   endcase
endcase
;
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
