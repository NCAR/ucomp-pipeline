function get_nbytes, structure, strtot=strtot
;
;+
; NAME: NBYTES
; PURPOSE: Return the size in bytes of the input argument
; INPUT PARAMETERS:
;	Structure - any IDL data type (strings? - see strtot keyword)
; OUTPUT: Function return value is byte count
; Optional keyword Paramters:
;   strtot - switch - if set, add acutal string size information
;	     (not set, run the old way)
; Calling Sequence:  bytesize = GET_NBYTES(structure)
; Method: Recursive to handle nested structures
; Restrictions: strtot must be set to give actual string lengths
;	        (without keyword, strings return 0)
; Modification History: 
;	SLF, 20-June-1991
;	MDM, 30-Sep-91	- Did not work properly for structure of structures
;	slf,  6-apr-93  - allow string types and add strtot keyword
;
; -
;	
qdebug = 0
bytes_type = [0,1,2,4,4,8,8,0,0]		; byte sizes for types
;
stsize=size(structure)
case stsize(stsize(0)+1) of
   8: begin						; its a structure
        count = 0
        for i = 0, n_tags(structure) - 1 do begin
	   count = count + get_nbytes(structure.(i),strtot=strtot) ;recurse
	   if (qdebug) then begin
	      t_name = tag_names(structure)
	      print, t_name(i), count
	   end
         endfor
      endcase
    7:if keyword_set(strtot) then  			$
	 count = long(total(strlen(structure))) 	$
            else count=0 ; backward compatible 	
    else: count=stsize(stsize(0)+2) * bytes_type(stsize(stsize(0)+1) )   

end
;
return, count
end
