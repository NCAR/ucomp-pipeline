function ssw_time_compare, times, reference, files=files, $
     later=later, after=afer, earlier=earlier, before=before
;+
;   Name: ssw_time_compare
;
;   Purpose: boolean time or file-time compare (combine some SSW functions)
;
;   Input Parameters:
;      times - time vector, any SSW format. If /FILES set, times=filenames
;      reference - the reference time for boolean compare, any SSW
;  
;   Output:
;      function returns truth as implied by user keywords
;      Scalar if TIMES is scalar, Vector if TIMES is vector  
;     
;   Keyword Parameters:
;      reference - the reference time to compare, any SSW format
;      later    (switch) - if set, return true = TIMES newer than REFERENCE
;      after    (switch) - synonym for LATER
;      earlier  (switch) - if set, return true = TIMES older than REFERENCE
;      before   (switch) - synonym for EARLIER
;      files    (switch) - USE THIS IF 'times' are file names (assume inc UT) 
;
;   Calling Examples:
;      if ssw_time_compare(time,reftime,/earlier) then ...  
;      if ssw_time_compare(time,reftime,/later) then...
;      earlyss=where(ssw_time_compare(index,'1-feb-98',/earlier),earlycount)
;      newerfiless=where(ssw_time_compare,FILELIST,'1-feb-98',/files,/later)
;  
;   History:
;      3-December-1998 S.L.Freeland - convenient interface for standard call
;
;   Method:
;      call ssw_deltat - compare times to reference and return truth
;      
;   Calls:
;     ssw_deltat, file2time
;-  
if n_params() lt 2 then begin
    box_message,['Need time(s) and REFERENCE for comparison', $
      'IDL> truth=ssw_time_compare(times,reference [,/after] [,/before])']
endif

tref=reference
if n_elements(reference) gt 1 then begin
   box_message,'Scalar reference for now, using 1st reference element'
   tref=reference
endif

ctimes=times
if keyword_set(files) then ctimes=file2time(ctimes,/int) ; filelist input

dt=ssw_deltat(ctimes,reference=tref)

earlier=keyword_set(earlier) or keyword_set(before) ; synonyms
later  =keyword_set(later)   or keyword_set(after)

case 1 of
   earlier: retval=dt lt 0
   later:   retval=dt gt 0
   else:  begin
     box_message,'Need to supply either /EARLIER or /LATER'
     retval=-1
   endcase
endcase  

return, retval
end

