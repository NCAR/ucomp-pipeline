function weekid, fileid, all=all,				$ 
   		 xbd=xbd, xad=xad, pnt=pnt, fem=fem, obs=obs,	$
		 ver=ver, gt_pre=gt_pre, indir=indir, 		$
		 gt_distpre=gt_distpre, prefix=prefix, vnum=vnum
;+
;   Name: weekid
;
;   Purpose: return expanded file ids for weekly files in common area 
;	     (provide single point maint for weekly prefix definitions)
;
;   Input Parameters:
;	fileid = xxxyy_wwn (string) - standard weekly file name
; 		 if xxx is included, only that prefix is checked
;   Output:
;	function returns string scaler or array
;	default is latest version only (scaler)
;	
;   Optional Keyword Parameters:
;	all - if set, all prefixes are checked
;	xbd,xad,pnt,fem,obs - prefixes to check (mutally exclusive)
;	indir	- if set, look at that directory instead of the
;		  "standard" directory.
;	gt_pre - if set, returns weekid prefixes only
;	gt_distpre - if set, returns weekid prefixes for distributed
;		     (tar sets) only
;       vnum - version number (limit search to only these versions)
;
;   Output Parameters:
;	ver - highest existing version (integer) - 00 if no such file
;
;   Modification History:
;	Written: slf, 19-feb-92
;		 slf,  8-mar-92 	added gt_pre for single pt maint
;		 mdm, 20-May-92		Added "indir" option
;		 mdm,  9-Jun-92		Removed unix specific "/" code 
;					Used wildcard "*.*" instead of "*"
;	         slf, 22-Jun-92		Added nar,evn,gev 
;		 slf, 20-Oct-92		Added gxt
;		 slf, 24-Nov-92		Added ssl, sot
;		 slf,  6-apr-93		Added prefix and vnum keywords
;                slf, 19-aug-93         replaced recursive segment
;-	
;
; handle vnum (input version number)
svnum=size(vnum)
case 1 of 
   svnum(svnum(0)+1) eq 0: sver='*'			; all versions
   svnum(svnum(0)+1) eq 7: sver=vnum			; string, use as is
   else: sver=string(fix(vnum),format='(i2.2)')		; number passed
endcase

if n_elements(fileid) eq 0 then fileid='*'	;default wild card
; set up filenames
distpre= $		; distributed (as tar sets)
   ['xbd','xad','fem','nar','evn','gev','gxt','sot','ssl']	
preweek=[distpre, 'obs', 'pnt']

if keyword_set(gt_pre) then return, preweek	; just prefixes
if keyword_set(gt_distpre) then return, distpre

if keyword_set(prefix) then preweek=prefix else begin
   fidchk=where(strmid(fileid,0,3) eq preweek)
   if fidchk(0) gt 0 then begin
      prefix=preweek(fidchk)			; full filename
      fileid=strmid(fileid,3,1000)		; use same logic
   endif
endelse
;
						; allow prefix passed in

comdir = '$DIR_GEN_' + strupcase(preweek)	; commond directories
if (keyword_set(indir)) then comdir = indir	; MDM added 20-May-92

; slf, 6-apr - allow version searches
weekfiles=preweek + fileid + '*.' + sver	; add wild card for search

genfiles= concat_dir(comdir, weekfiles)		; path + file
;
; check keywords

; slf, 19-aug - removed recursive segment since calling recursivly.
;for i=0,n_elements(preweek)-1 do begin
;   exestr="if keyword_set(" + preweek(i) +") then prefix=" + $;
;	"'" + preweek(i) + "'"
;   exestat=execute(exestr)
;endfor

if not keyword_set(prefix) then begin
   case 1 of
      keyword_set(xad): prefix='xad'
      keyword_set(xbd): prefix='xbd'
      keyword_set(fem): prefix='fem'
      keyword_set(nar): prefix='nar'
      keyword_set(evn): prefix='evn'
      keyword_set(gev): prefix='gev'
      keyword_set(gxt): prefix='gxt'
      keyword_set(sot): prefix='sot'
      keyword_set(ssl): prefix='ssl'	
      keyword_set(obs): prefix='obs'
      keyword_set(pnt): prefix='pnt'
      else: begin
         message,/info,'no prefix defined, returning...'
         return,''
      endcase
   endcase
endif
;
index=where(prefix(0) eq preweek)		; which file 
gen=findfile(genfiles(index(0)))		; search
latest=gen(n_elements(gen)-1)			; take latest 
break_file,latest,log,path,file,ext,version	;
ver=fix(str_replace(ext,'.'))			; version as integer
;
retval = latest					; default is latest
if keyword_set(all) then retval=gen		; all
return, retval
end
