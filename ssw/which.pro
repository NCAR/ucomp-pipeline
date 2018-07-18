pro which,file,path,findall=findall,dironly=dironly,verbose=verbose,$
	all=all,outfile=outfile,search=search,quiet=quiet, _extra=e
;+
;procedure	which
;	apes the csh command `which` in the IDL environment, and
;	finds the path to the specified file by looking through
;	all the directories specified in the !PATH variable.
;
;	NOTE: it is possible to use ROUTINE_INFO to get the path to a
;	compiled subroutine directly:
;	  help,routine_info(routine,/source,/function),/structure
;	but clearly you need to know the exact name of the routine
;	(can't use wildcards) as well as whether what you need is
;	a procedure or a function beforehand.  also, they have to
;	be compiled procedures, not, for example, command files or
;	scripts or datafiles lurking under the horizon.  and what
;	if there are duplicates in different directories?
;	btw, FILEPATH is completely uselss for this purpose.
;
;syntax
;	which,file,path,/findall,/dironly,verbose=verbose,$
;	/all,outfile=outfile,search=search,quiet=quiet
;
;parameters
;	file	[INPUT; required] name(s) of file to search for
;		* may include shell wildcards, regexps, etc.
;		  (but remember to prepend the escape character "\")
;		* may also be an array.
;	path	[OUTPUT] full path to the requested file(s)
;		* there is no reason to expect that the array sizes of
;		  FILE and PATH will match.
;
;keywords
;	findall	[INPUT] if set, continues to search even if
;		the file has been found
;		* if not set, and FILE is scalar, stops searching
;		  as soon as at least one copy of file has been found
;		* set automatically if FILE is an array or contains
;		  special characters '*', '?', '[', ']', '\'
;		- in this case, set explicitly to 0 to quit at first
;		  match.
;	dironly	[INPUT] if set, returns only the name(s) of the
;		directory(ies) containing the specified file(s)
;	verbose	[INPUT] if set, spits out informational messages
;	all	[INPUT] added for compatibility with SSW version,
;		same as FINDALL
;	outfile	[OUTPUT] added for compatibility with SSW version,
;		same as PATH
;	search	[INPUT] added for compatibility with SSW version,
;		automatically sets FINDALL and tacks on '*'s to FILE
;	quiet	[INPUT] added for compatibility with SSW version,
;		same as setting VERBOSE=0
;	_extra	[JUNK] here only to prevent crashing the program
;
;restrictions
;	FOR UNIX ONLY (spawns find)
;
;history
;	vinay kashyap (FebMM)
;	quits if not UNIX (VK; FebMMI)
;	added keywords ALL, OUTFILE, and SEARCH for SSW-IDL compatibility
;	  (VK; May03)
;-

;	usage
ok='ok' & np=n_params() & nf=n_elements(file) & path=''
szf=size(file) & nszf=n_elements(szf)
if np eq 0 then ok='Missing filename' else $
 if nf eq 0 then ok='Input filename undefined' else $
  if szf(nszf-2) ne 7 then ok='Filename not character string' else $
   if !version.OS_FAMILY ne 'unix' then ok='spawns find; UNIX only'
if ok ne 'ok' then begin
  print,'Usage: which,file,path,/findall,/dironly,verbose=verbose,$'
  print,'       /all,outfile=outfile,search=search'
  print,'  search through !PATH to find file'
  if np ne 0 then message,ok,/info
  return
endif

;	recast inputs
ff=[file(*)]
if keyword_set(all) then findall=1
if keyword_set(search) and n_elements(findall) eq 0 then begin
  findall=1 & ff='*'+ff+'*'
endif
v=0 & if keyword_set(verbose) then v=fix(verbose(0)) > 1
if keyword_set(quiet) then v=0	;OVERRIDE
if n_elements(findall) eq 0 then begin		;(FINDALL is not specified
  getall=0	;skip out after first match
  if nf gt 1 then getall=1 else begin
    ok='ok'
    if strpos(ff(0),'*',0) ge 0 then ok='*'
    if strpos(ff(0),'?',0) ge 0 then ok='?'
    if strpos(ff(0),'[',0) ge 0 then ok='['
    if strpos(ff(0),']',0) ge 0 then ok=']'
    if strpos(ff(0),'(',0) ge 0 then ok='('
    if strpos(ff(0),')',0) ge 0 then ok=')'
    if strpos(ff(0),'\',0) ge 0 then ok='\'
    if ok ne 'ok' then getall=1		;regex wild-cards in filename
  endelse
endif else begin				;)(is set
  getall=1
  if findall(0) eq 0 then getall=0	;explicitly set to 0
endelse						;FINDALL?)
if v ge 10 then message,'FINDALL='+strtrim(getall,2),/info

;	define the output
path=''

;	expand !path
dirs=expand_path(!path,/array) & ndirs=n_elements(dirs)

for i=0L,nf-1L do begin		;{for each file
  if v ge 1 then kilroy,dot=strtrim(ff(i),2)+': '
  go_on=1 & k=0L
  while go_on do begin		;{search through all directories
    if v ge 5 then kilroy,dot=dirs(k) & if v ge 1 then kilroy
    cmd='find '+dirs(k)+' -name '+strtrim(ff(i),2)
    if keyword_set(dironly) then cmd=cmd+' -exec dirname {} \;' else $
	cmd=cmd+' -print'
    spawn,cmd,cc
    if keyword_set(cc) then begin
      if keyword_set(path) then path=[path,cc] else path=cc
      if v ge 2 then print,cc
    endif
    ;	stopping rules
    k=k+1L
    if k eq ndirs then begin
      if v gt 2 then message,'done looking through !PATH',/info
      go_on=0
    endif
    if getall eq 0 then begin
      if keyword_set(path) then go_on=0
    endif
  endwhile			;GO_ON}
endfor				;I=0,NF-1}

if np eq 1 then begin
  if keyword_set(path) then print,path else print,file+': Not found'
endif
if keyword_set(path) then outfile=path else outfile=''

return
end
