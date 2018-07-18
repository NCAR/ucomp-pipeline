pro file_uncompress, inname, outname, noreplace=noreplace , newname=newname, $
	verbose=verbose, compfact=compfact, debug=debug, outdir=outdir, loud=loud
;
;+
;   Name: file_uncompress
;
;   Purpose: provide IDL interface to standard unix uncompress & gzip utility
;
;   Input Paramaters:
;      inname - file name or vector of file names to gunzip or uncompress
;
;   Output Parameters:
;      outname - uncompressed file names (same dimension as inname)
;		 (usually, inname without .gz or .Z extension, null if problem)
;
;   Optional Keyword Parameters
;	noreplace - (input) - switch, if set, don't replace inname with outname 
;	newname   - (input)   NOT IMPLEMENTED specify outname
;       outdir    - (input)   specify output directory (only if /noreplace)
;       loud      - (input)   if set, include Verbose switch on unix call
;
;   Calling Sequence:
;	file_compress, inname [, outname ,/noreplace , outdir=outdir ]
;
;   History:  1-Jul-93 (SLF)
;	      7-Oct-93 (SLF) Added OUTDIR keyword parameter
;	     14-Mar-94 (SLF) enclose file names in quotes (embedded meta-char)
;            11-apr-95 (SLF) make quiet the default, use /loud to override
;            09-Dec-97 (PGS) added test for .gz extensions and gunzip call
;            29-Dec-01 (TAK) can now uncompress a combination of .gz and .Z files
;
;   Restrictions: UNIX only 
;-
loud=keyword_set(loud)
vswitch=(['','v'])(loud)

if keyword_set(newname) then begin
   tbeep
   message,/info,'NEWNAME keyword not yet implemented
endif

iname = inname ; for the null case
outname=strarr(n_elements(iname))

posdotZ = strposarr(inname, '.Z', /lastpos)      ;find location of files ending in .Z
tempindZ = where((posdotZ ne -1) AND ((strlen(inname) - posdotZ) EQ 2) , numtempZ)
IF (numtempZ gt 0) THEN iname = strmids(inname(tempindZ),0,posdotZ(tempindZ))

posdotgz = strposarr(inname, '.gz', /lastpos)    ;find location of files ending in .gz
tempindgz = where((posdotgz ne -1) AND ((strlen(inname) - posdotgz) EQ 3), numtempgz )
IF (numtempgz GT 0) THEN begin
   IF  numtempz EQ 0 THEN iname = strmids(inname(tempindgz),0,(posdotgz(tempindgz)) ) $
   ELSE iname = [iname,strmids(inname(tempindgz),0,(posdotgz(tempindgz)) )]
ENDIF
verbose=''
outname = iname
;
; check input file validity
chk_filesgz=file_exist(iname + '.gz')           ;PGS: build array once for each suffix
somegz=where(chk_filesgz,scountgz)
nonegz=where(1 - chk_filesgz,ncountgz)
;
; check input file validity
chk_filesZ=file_exist(iname + '.Z')             ;PGS: build array once for each suffix
someZ=where(chk_filesZ,scountZ)
noneZ=where(1 - chk_filesZ,ncountZ)
;
if ((scountZ EQ 0) and (scountgz EQ 0)) then begin
   message,/info,'No input files exist, returning...'
   return
endif else begin
some = WHERE((chk_filesgz + chk_filesZ) EQ 1)  ;should be no overlap: i.e., none = 2
ncounttotal = where(((chk_filesgz + chk_filesZ) EQ 0), ncountt)
   if (ncountt GT 0) then begin
      message,/info,'The following input files do not exist:'
      print, iname(ncounttotal), format='(a)'
   endif
endelse
   
; assign output file names
;
case 1 of
   keyword_set(noreplace): begin
;  noreplace keyword overrides default (preserve existing file)
;     if outdir is specified, place the uncompressed file there
      if keyword_set(outdir) then begin
         break_file,iname(some),ilog,idir,iiname,iext,ivers
         oname=iiname + iext + ivers
         outname(some) = concat_dir(outdir,oname)
      endif                   
; at the moment, two if blocks look redundant (both call gunzip), but format modifiable to other schemes.
      IF (scountgz gt 0) THEN BEGIN 
      for i=0,(n_elements(somegz)-1) do begin
         spawn,'gunzip -' + vswitch + 'nqcf'+ '"' + iname(somegz(i)) + '" > ' + outname(somegz(i)), status ;PGS
         verbose=[verbose,status]
      endfor
      ENDIF
;
      IF (scountZ gt 0) THEN BEGIN 
         for j=0,(n_elements(someZ)-1) do begin ;PGS: format allows multiple uncompress algorithms,
            spawn,'uncompress -' + vswitch + 'cf ' + '"' + iname(someZ(j)) + '" > '+outname(someZ(j)), status ;PGS
            verbose=[verbose,status]
         endfor
      ENDIF
                           endcase
;  default action is to replace existing (inname) file
   else: begin
      IF (scountgz GT 0) THEN BEGIN 
         for i2=0,(scountgz-1) do begin
            spawn,'gunzip -' + vswitch + 'nqf '+ '"' + iname(somegz(i2)) + '"', status 
            verbose=[verbose,status]
         endfor
      ENDIF
;
      IF (scountZ gt 0) THEN BEGIN 
         for j2=0,(n_elements(someZ)-1) do begin
            spawn,'uncompress -' + vswitch + 'f ' + '"'+iname(someZ(j2))+ '"', status  ;PGS: could be uncompress
            verbose=[verbose,status]
         endfor
      ENDIF
      endcase
endcase
verbose=verbose(1:*); pgs

ccount = 0

chk_comp=file_exist(outname(some)) 
compprob=where((1-chk_comp),ccount)
if ccount gt 0 then begin
   tbeep
   message,/info,'Problem uncompressing the following files:'
   print,iname(some(compprob))
   outname(some(compprob))=''		; make null
endif
return
end
