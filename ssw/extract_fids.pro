function upat2pattern, upat
;
;   --------------------------------------------------------------
;   Name: upat2pattern
;
;   Purpose: convert user pattern -> pattern used by extract_fids
;
;   Example - yymmdd.hhmm maps to -> ddddddsdddd
;   --------------------------------------------------------------

bupat=byte(upat)
specss=strspecial(upat) & sss=where(specss,scnt)
bupat(*)=byte('d')                         
if scnt gt 0 then bupat(sss) =byte('s')
pattern=string(bupat)
return, string(bupat)
end

function extract_fids, filenames, fidfound=fidfound, fidsfound=fidsfound, $
         breakfiles=breakfiles, pattern=pattern, lastpos=lastpos
;+
;   Name: extract_fids
;
;   Purpose: find & extract embedded FIDS in file names 
;
;   Input Parameters:
;      filenames - string array of filenames with embedded FIDs
;                  fmt=[...xxxYYMMDD.HHMM[SS]... ...xxxYYMMDD_HHMM[SS]...]
;
;   Output Paramters:
;      function returns fids (date strings like YYYYMMDD?HHMMSS )
;
;   Keyword Parameters:
;      breakfiles (switch)- if set, break_files first (only required if
;                           file PATH might contain a FID
;      pattern (input)   -  if set, pattern to use (dont cycle through defaults)
;                           Form = string like 'ddddddsdddd'
;                           where d->digit and s-> special character  
;                        OR something like 'yymmdd.hhmmss'
;                           (maps internally to 'ddddddsdddddd')
;      fidfound (output) -  boolean flag = true if valid FID from ALL files
;      fidsfound (output) - boolean flag (individual files)
;  
;   History:
;     25-Nov-1997 - S.L.Freeland - extract/optimize code from extract_fid.pro
;                                  Remove restriction on fixed file length
;                                  for a given call.  
;      3-dec-1997 - S.L.Freeland - fix pattern typo (embedded   blank)
;     28-jul-2006 - S.L.Freeland - add explict pattern inc. milliseconds
;                                  (sxi for example: yyyymmddDhhmmssmss
;
;   Method:
;      Use pattern mask, byte operations, strmids.pro and strpos for
;      faster execution and permit mixed file names
;-
; ------------ break files (ignore pathnames) -------------
if keyword_set(breakfiles) then begin
   break_file, filenames, flog, fpath, fname, fext, fver
   if fext(0) eq '' then fext=strarr(n_elements(fext))+'.'
   full_files=fname + fext + fver
endif else full_files=filenames
; ----------------------------------------------------------

; ------- set up byte/string mask --------------------------
maskb=byte(full_files)                      ; byte array for masks
lowb=byte(strlowcase(full_files))           ; for alpha check
hib =byte(strupcase(full_files))            ; for alpha check 
alphas=where(lowb ne hib, acnt)             ; set all alphas-> ' '
if acnt gt 0 then maskb(alphas) = 32b

specss=where(lowb eq temporary(hib) and $   ; special, non-blanks
	     maskb ne 32b, sscnt)
if sscnt gt 0 then maskb(specss)=115b       ; set special -> 's'

digits=lowb ge 48b and lowb le 57b          ; digits
digss=where(digits,digcnt)
if digcnt gt 0 then maskb(digss)=100b       ; set digits -> 'd'

delvarx,lowb
; ----------------------------------------------------------

; define pattern masks, most->least "refined" 
;                                                          ; most probable
patterns=['ddddddddsddddddddd', $			   ;yyyynndd?hhmmssmss
          'ddddddddsdddddd',    $                          ;yyyymmdd?hhmmss
          'ddddddddsdddd',       $                         ;yyyymmdd?hhmm
          'ddddddsdddddd',       $                         ;yymmdd?hhmmss
          'ddddddsdddd',         $                         ;yymmdd?hhmm
          'dddddddd',            $                         ;yyyymmdd
	  'dddddd']                                        ;yymmdd

if data_chk(pattern,/string) then $
    patterns=upat2pattern(pattern)                         ; user supplied
npats=n_elements(patterns)                                 ; max pats to check
patarr=string(temporary(maskb))                            ; mask -> string

nf=n_elements(patarr)                                      
fidsfound=bytarr(nf)                                       ; boolean found?
fids=strarr(nf)

fidfound=0
patss=0
posproc=(['strpos','str_lastpos'])(keyword_set(lastpos)) ; select function

; ---- test patterns until resolution or all patterns checked ------------
repeat begin
   chkpat=call_function(posproc,patarr,patterns(patss))  ; strpos OR strlastpos
   wherepat=where(chkpat ne -1 and (1-fidsfound), pss)   ; pattern found?
   if pss gt 0 then fids(wherepat)=$                     ; yes, extract
      strmids(full_files(wherepat),chkpat(wherepat),$    ; extract fids via
	      strlen(patterns(patss)))                   ;  <strmids.pro>
   fidsfound=fidsfound or chkpat ne -1                   ; update all flags
   fidfound=total(fidsfound) eq nf                       ; summary flag
   patss=patss+1                                         ; next pattern
endrep until fidfound or patss gt (npats-1)
; --------------------------------------------------------

return,fids
end     
