function data_chk, p1, 				$	
   type=type, ndimen=ndimen, 			$	; IDL size results 
   orr=orr,					$	; boolean control
   string=string, struct=struct, 		$	;   types
   undefined=undefined, defined=defined,	$	;   defined
   scaler=scaler, vector=vector, debug=debug		;   dimensions
;
;+  Name: data_chk
;
;   Purpose: checks input data for type, ndimension, etc
;	     (uses IDL size function results)
;
;   Keyword Parameters:
;      type -   if set, return idl data type (0,1,2..8) from size function
;      ndimen - if set, return number dimensions (size(0))
;      orr    - if set, return value is OR of all boolean flags (def=AND)
;      string/struct/undefined - if set, return true if type matches 
;            
;   Calling Examples:
;      if (data_chk(p1,/type) eq data_chk(p2,/type)) then...
;      case data_chk(data,/type) of...
;      if data_chk(data,/string,/scaler) then ...
;      if data_chk(data,/string,/struct,/undef,/orr)
;
;   History:
;      27-Apr-1993 (SLF)
;      21-Mar-1994 (SLF) documentation header
;
;   Restrictions:
;      some keywords are mutually exclusive - for self-documenting code 
;      and reduction of code duplicataion (not terribly speed efficient)
;-   
debug=keyword_set(debug)
sp1=size(p1)
; process SIZE keyword

idltype=sp1(sp1(0)+1)		
idldimen=sp1(0)
defed=idltype ne 0		; 'defined'   logical
undefed=idltype eq 0 		; 'undefined' logical

case 1 of 
   keyword_set(type):   retval=idltype
   keyword_set(ndimen): retval=idldimen
;  else - Handle booleans
   else: begin   
      dimenval=0			; default to false
      dimenchk=-1
      if keyword_set(scaler) then dimenchk= $
         [ dimenchk,defed and (idldimen eq 0) ]

      if keyword_set(vector) then dimenchk = $
         [ dimenchk,defed and (idldimen eq 1) ]

      if keyword_set(defined) then dimenchk= $
	 [ dimenchk,defed ]

      typeval=0       
      typechk=-1
      if keyword_set(struct) then typechk= $
	 [typechk, idltype eq 8]
if debug then stop 
      if keyword_set(string) then typechk=$
         [typechk, idltype eq 7]

      if keyword_set(defined) then typechk=$
         [typechk, defed]

      if keyword_set(undefined) then typechk=$
         [typechk, undefed]

      typed=n_elements(typechk) gt 1
      dimened=n_elements(dimenchk) gt 1

      for i=1,n_elements(dimenchk)-1 do begin
         dimenval=dimenval or dimenchk(i)
      endfor

      for i=1,n_elements(typechk)-1 do begin
         typeval=typeval or typechk(i)
      endfor

      case 1 of
         typed and dimened: retval=dimenval and typeval
	 typed: retval=typeval
	 dimened: retval=dimenval
         else: begin
            message,/info,'No keywords set...'
            retval=-1
         endcase
      endcase         
   endcase
endcase

return,retval

end
