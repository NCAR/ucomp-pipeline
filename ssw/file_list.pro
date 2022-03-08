function file_list, dirs, str, interactive=interactive, files=file, fdir=fdir, cd=cd, bydate=bydate
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
;-
;
if (!version.os eq 'IRIX') then cd = 1		;MDM added 22-Dec-93
if (keyword_set(bydate)) then cd = 1		;MDM added 3-Apr-95
;
cd, cur=start_dir	;read the current directory location
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
    dir = dirs(i)
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
    print, 'FILE_LIST: No files found'
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
return, ff  
end

