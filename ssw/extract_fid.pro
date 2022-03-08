function extract_fid, filenames, times=times, fidfound=fidfound, $
		      notime=notime, pattern=pattern, quiet=quiet
;+
;   Name: extract_fid 
;
;   Purpose: extract embedded FIDS from file names, return fids and times
;
;   NOTE: ** broke out and optimized logic into EXTRACT_FIDS.PRO **
;            
;   Input Paramters:
;      filenames - string array of filenames with embedded FID
;                  fmt=[...xxxYYMMDD.HHMM[SS]... ...xxxYYMMDD_HHMM[SS]...]
;
;   Output Paramters:
;      function returns fids
;   
;   Keyword Parameters:
;      times (output) -    string formatted times (fid conversion)
;      fidfound (output) - boolean flag = true if valid FIDs extracted
;      notime (input) - switch used by FILE2TIME to bypass time conversion
;      pattern (input) - passed to EXTRACT_FIDS
;                        date string template
;                        EX: 'yymmdd.hhmmss', 'yyyymmdd', 'yyyymmdd_hhmm'
;      quiet           - if set, be quiet  
;  
;   History:
;      16-nov-1995 (S.L.Freeland)
;      28-mar-1997 (SLF) - extend to 4 digit years, time via 'file2time.pro'
;                          add NOTIME switch and function
;      24-nov-1997 (SLF) - optimize logic in extract_fids.pro (with an 's')
;                          ** Just made this a front end to extract_fids.pro **
;                          Removes restriction on using a fixed length for
;                          a given call  
;      21-apr-1998 (RAS) - vectorize selection of null extensions
;      04-Jun-2020 (Kim Tolbert) - Added quiet keyword
;-

quiet = keyword_set(quiet)

break_file, filenames, flog, fpath, fname, fext, fver
wnull = where( fext eq '', nnull)
if nnull ge 1 then fext(wnull) = strarr(nnull) + '.'
;if fext(0) eq '' then fext=strarr(n_elements(fext))+'.'
full_files=fname + fext + fver

fids=extract_fids(full_files, fidfound=fidfound, pattern=pattern)   ; call optimized routine

if fidfound then begin
   if not keyword_set(notime) then times=file2time(fids,out_style='yohkoh')
endif else begin
   if ~quiet then box_message,'Could not find FIDs in all files'
   fids=full_files
endelse
if n_elements(fids) eq 1 then fids=fids(0)
return,fids
end     
