function file_list, dirs, str, interactive=interactive, files=file, fdir=fdir, $
                       nocd=nocd, cd=cd, bydate=bydate,quiet=quiet
;
;+
;NAME:
;	file_list
;PURPOSE:
;	Given a set of directories (and optionally a partial
;	filename with a wildcard), generage a list of file
;	names/directories
;CALLING SEQUENCE:
;	infil = file_list(data_paths())
;	infil = file_list(data_paths(), 'spr*')
;	infil = file_list(data_paths(), 'spr*', /cd)
;	infil = file_list(data_paths(), /interactive)
;INPUTS:
;	dirs	- The directories to search
;		  If not present, it uses the default directory
;	str	- The wildcard partial filename to search for.  Be careful
;		  when using wildcards when searching a directory which has
;		  subdirectories, because it will not work properly.  For
;		  example:  file_list('~', '*') will not give the proper
;		  answer, but it will if the /CD option is used.  This
;		  is an artifact of how the IDL routine FINDFILE works.
;OPTIONAL KEYWORD INPUT:
;	interactive - If set, ask the user to type in the partial
;		  filename to search for
;	cd	- If set, then set default to the directory first
;		  and then do the listing.  This technique is
;		  needed because of "argument overflow" errors duing
;		  "ls" type commands when there are too many files in
;		  a directory.  This happens on the SGI much sooner
;		  than Suns or DECs.
;       nocd    - if set, override /CD default for UNIX 
;	bydate	- If set, then list the files by date, with the oldest
;		  file in the beginning of the array, and the newest file
;		  as the last element in the array.  ONLY WORKS ON UNIX.
;OUTPUTS:
;	RETURNS: The file list (including the path).
;OPTIONAL KEYWORD OUTPUT:
;	files	- Just the file names of the filenames
;	fdirs	- Just the directory portion of the filenames
;HISTORY:
;	Written 11-Dec-91 by M.Morrison
;	 8-Mar-93 (MDM) - Modified to optioncally set default to the directory
;			  and then to do the listing
;			- Modified to accept an array of input file names
;	16-Mar-93 (MDM) - Modified to set default back to the starting directory
;			  and not leave you in the last directory when using
;			  the /CD option.
;	12-Aug-93 (MDM) - Changed how the /CD option works (doesn't actually
;			  do a cd now)
;			- Added translation of ~ if passed in
;       27-Oct-93 (AKT) - If wildcard search spec doesn't include .something
;			  then append .*.  In VMS, findfile needs the .*.
;	 7-Dec-93 (MDM) - Removed the 27-Oct-93 patch unless the system is
;			  VMS.  It causes problems in Unix (show hidden
;			  . (dot) files)
;	22-Dec-93 (MDM) - Made /CD the default when running on SGI
;	 3-Apr-95 (MDM) - Added /BYDATE
;	28-Feb-96 (MDM) - Added defining output variable FILES
;			- Also changed the keyword from FILE to FILES
;	 4-Feb-97 (MDM) - Made the FOR loop a long interger
;       18-Feb-97 (SLF) - Merged SLF change 7-Nov-96 to protect ultrix/IDL 4.01
;	30-May-99 (RDB) - Prohibit use of /cd with WINDOWS - doesn't work...
;        3-Jun-99 (SLF) - make /CD default for UNIX family, add /NOCD override
;                         made 'cd' logic -> case instead of bunch of 'ifs'
;       10-Aug-00 (DMZ) - added /QUIET and call to chklog(dir)
;       11-Aug-16 (Zarro) - added check for blank file names
;-
;

case 1 of 
   os_family(/lower) eq 'windows': cd=0         ; per RDB, 30-May-1999
   keyword_set(bydate):      cd=1               ; per mdm,  2-apr-1995
   keyword_set(nocd):        cd=0               ; override UNIX default
   os_family() eq 'unix':    cd=1               ; unix default, slf, 3-jun-99
   else: cd = keyword_set(cd)                   ; else, per keyword
endcase    

;
;
start_dir=(curdir())(0)                         ;SLF 7-Nov-96
;                                               ;(hide problems with CD)
;
if (keyword_set(interactive)) then begin
    str = ''
    read, 'Enter file to search for - use wildcards (ie: sfr*) ', str
end else begin
    if (n_elements(str) eq 0) then str = '*'
end
;
ff = ''
if (n_elements(dirs) eq 0) then dirs = ''		;use default dir
for i=0,n_elements(dirs)-1 do begin
    dir = chklog(dirs(i),/pre)
    if (strpos(dir, '~') ne -1) then dir = str_replace(dir, '~', getenv('HOME'))
    ;
    for j=0,n_elements(str)-1 do begin
        dot = strpos (str(j), '.')
        if ((dot eq -1) and (!version.os eq 'vms')) then str(j) = str(j) + '.*'
	if (not keyword_set(cd)) then begin
	    ff0 = findfile( concat_dir(dir, str(j)) )	;original technique - works well if the directory might not exist
	end else begin
	    if (keyword_set(bydate)) then spawn, ['ls', '-tr', dir], all_files, /noshell	$
				else all_files = findfile(dir)			;get all files in that directory
	    ss = wc_where(all_files, str(j))
	    if (ss(0) eq -1) then ff0 = '' else ff0 = concat_dir(dir, all_files(ss))
            ;;if (dirs(i) eq '') then cd, start_dir else cd, dirs(i)
            ;;ff0 = findfile(str(j))                              ;do not include directory in the listing
            ;;if (ff0(0) ne '') then ff0 = concat_dir(dirs(i), ff0)
	end
	if (ff0(0) ne '') then ff = [ff, ff0]
    end
end
cd, start_dir		;fixed 16-Mar-93
;
file = ''		;MDM added 28-Feb-96
if (n_elements(ff) eq 1) then begin
    if (1-keyword_set(quiet)) then print, 'FILE_LIST: No files found'
end else begin
    ff = ff(1:*)	;strip off first element
    ;
    n = n_elements(ff)
    file = strarr(n)
    fdir = strarr(n)
    for i=0L,n-1 do begin
	break_file, ff(i), dsk_log, dir, filnam, ext
	file(i) = filnam + ext
	fdir(i) = dsk_log + dir
	;TODO - optionally return items like the size of the file
    end
end
;
;-- filter out blank file names

chk=where(strtrim(file,2) ne '',count)
if count eq 0 then begin
 file='' & fdir='' & ff='' 
 return,ff
endif

if (count ne n) then begin
 file=file[chk]
 fdir=fdir[chk]
 ff=ff[chk]
endif

if count eq 1 then begin
 file=file[0]
 fdir=fdir[0]
 ff=ff[0]
endif

return, ff
end

