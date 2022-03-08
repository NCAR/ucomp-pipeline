pro scratch, u0, u1, u2, u3, u4 ,u5, u6, u7, u8, u9, 			$
	 	open=open, close=close , print=print, file=file,	$
		nodelete=nodelete, names=names, cleanup=cleanup
;
;+
;   Name: scratch
;
;   Purpose: manage scratch files (names, auto-delete, units,...)
;	     (compatible with VMS/Unix)
;
;   Input Parameters:
;      u0, u1, ... u9 	 ;if defined on input, log units to close and delete
;   
;   Output Parameters:
;      u0, u1, ... u9    ;if undefined, logical units assigned during open
;
;   Keyword Parameters:
;      nodelete - (input) dont delete on close (default is to delete)
;      cleanup  - (input) deletes all scratch generated files (even old stuff)
;      open     - (input) force open mode (default if u0 present and undefined)
;      close    - (input) force close mode (default if u0 present and defined)
;      names    - (output) scratch file names acted upon (open/close/delete)
;      file     - (input)  use this name, not system derived
;
;   Calling Sequence:
;      scratch,u1,u2,u3 ; if parameters undefined, open 3 scratch files
;			 ; if parameters defined,   close/delete files
;
;   Calling Examples:
;      scratch, u1, u2, u3, /open ; open 3 files, return luns in u1, u2, u3
;      scratch, u1, u2, /close    ; close and delete files open w/luns u1/u2
;      scratch, u2, /print 	   ; same, but print before deleting
;      scratch, u1, /nodelete	   ; close, dont delete
;      scratch, u1, u2 	   	   ; if u1 is undfined: open 2 files
;				     (same as scratch, u1, u2 ,/open)
;				     if u1 is defined, close/delete 2 files
;				     (same as scratch, u1, u2, /close)
;      scratch, u1, name=name	   ; return system derived file name used
;      scratch			   ; close/delete all open scratch files
;      scratch,/cleanup	   	   ; same plus any old scratch files from
;      scratch,/clean,/nodel,name=name ; new and old scratch file names
;      scratch,u1,file='fname',/open   ; opens fname 
;
;   Restrictions:
;      uses execute statement, so no recursion allowed
;      if user supplies file names (with file= keyword), then some 
;      auto-mangagement functions are lost (ex: /cleanup function)
;
;   History: slf, 3-March-1993
;	     slf, 1-jun-93		; dont force file in home directory
;	     slf, 3-jun-93		; openw not openu
;-
; allow silent pass through  of terminal lun
if n_elements(u0) eq 1 then if u0 eq -1 then return

; get scratch file name
open=keyword_set(open) or (n_elements(u0) eq 0 and n_params() gt 0)
home=getenv('HOME')			; works on VMS/Unxi
delete=1 - keyword_set(nodelete)
names=''
if keyword_set(open) then begin

;  protect against replicate w/0 (not to mention, bad routine usage)
   if n_params() eq 0 then begin
      message,/info,'need at least 1 parameter for lun output'
      return
   endif

   if keyword_set(file) then begin         		;user supplied names
      if n_elements(file) ne n_params() then begin
         message,/info,'parameter / filename mismatch
         return
      endif else begin
;         break_file,file,log,path,sname,ver,ext
;         sname=sname+ver+ext
	  sname=file		; slf, 1-jun
      endelse
   endif else begin					; system supplied
      root=string(long(10e6*randomu(x,n_params())),format='(i7.7)') + '.DAT'
      sname=strcompress('SCRATCH_' + root,/remove)
   endelse
;  names defined, now open the files
   for i=0, n_params()-1 do begin   
      name=sname(i)
      if not keyword_set(file) then name=concat_dir(home,sname(i)) ; ~
      names=[names,name]			; update output array
      openw,unit,/get_lun,name  		; open the file
      param=strcompress('u' + string(i),/remove); which output paramter
      exestat=execute(param + '=unit')		; assign lun to output
   endfor
endif else begin					; close unit
   if n_elements(u0) eq 0 then begin
;     free all open scratch units
      scrstat=fstat(100)
      for i=101,128 do scrstat=[scrstat,fstat(i)]	; get open files
      openscr=where(strpos(scrstat.name,'SCRATCH_') $
		 ne -1,scount)
      for i=0,scount-1 do begin
         free_lun,scrstat(openscr(i)).unit
	 fname=scrstat(openscr(i)).name 
         if keyword_set(print) then lprint,fname
	 names=[names,fname]
         if strlowcase(!version.os eq 'vms') then fname=fname+'1'
         if delete then file_delete,fname ,/quiet
      endfor
      if keyword_set(cleanup) then begin		; cleanup old files
         scrfiles=findfile(concat_dir(home,'SCRATCH_*.*'))
         if scrfiles(0) ne '' then begin
            names=[names,scrfiles]
            if delete then for i = 0, n_elements(scrfiles)-1 do $
	    file_delete, scrfiles , /quiet
	 endif
      endif
   endif else begin
      for i=0,n_params()-1 do begin
         param=strcompress('u' + string(i),/remove)
         exestat=execute('unit=' + param)		; assign to output
         filestat=fstat(unit)				; filename
         free_lun,unit					; close it
         fname=filestat.name
         if strlowcase(!version.os eq 'vms') then fname=fname+'1'
         if keyword_set(print) then dprint,filestat.name
         if delete then file_delete,filestat.name , /quiet
         names=[names,filestat.name]
      endfor
   endelse
endelse

case n_elements(names) of
   1:				; null
   2: names=names(1)		; scaler
   else:  names=names(1:*)	; vector
endcase

return
end
