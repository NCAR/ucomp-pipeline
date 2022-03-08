function file_stat, files, exist=exist, size=size
;+
; Project     :	SOHO - CDS
;
; Name        :	FILE_STAT()
;
; Purpose     :	Vector version of FSTAT
;
; Category    :	Utility, Operating_system
;
; Explanation :	Vector version of FSTAT
;
; Syntax      :	Result = FILE_STAT( FILES )
;
; Examples    :	
;
; Inputs      :	FILES	= List of files to check.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	EXIST	= If set, then the returned values are whether the
;			  files exist or not.  This is the default behavior.
;		SIZE	= If set, then the returned values are the sizes of the
;			  files.
;
; Calls       :	DATA_CHK
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Prev. Hist. :	11-Mar-1994 (SLF) Wanted faster file_exist function
;
; History     :	Version 1, 11-Mar-1994, S. Freeland
;
; Contact     :	SFREELAND
;-
;
template=fstat(-1)
; initialize some parameters
template.name=''
template.size=-1

if data_chk(files,/string) then begin
   template=replicate(template,n_elements(files))
   for i=0,n_elements(files)-1 do begin
on_ioerror,err
      openr,lun,/get_lun,files(i)
      template(i)=fstat(lun)
      free_lun,lun
      goto,ok
err:       
   on_ioerror,null
ok:
   endfor
endif else begin
   message,/info,'Expect file or file array...'
   return,-1
endelse

case 1 of 
   keyword_set(exist): retval=template.name ne ''
   keyword_set(size):  retval=template.size
   else: retval=template.name ne ''		; default to /exist
endcase

return,retval

end
