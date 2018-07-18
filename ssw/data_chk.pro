function data_chk, p1, 				$	
   type=type, nimages=nimages, ndimen=ndimen,	$	; IDL size results 
   xsize=xsize, ysize=ysize, nx=nx, ny=ny,      $       ; Ditto (axis sizes)
   orr=orr,					$	; boolean control(*)
   string=string, struct=struct, 		$	;   types
   undefined=undefined, defined=defined,	$	;   defined
   scalar=scalar, scaler=scaler, vector=vector, debug=debug		;   dimensions
;
;+  Name: data_chk
;
;   Purpose: checks input data for type, ndimension, etc
;	     (uses IDL size function results)
;
;   Keyword Parameters:
;      type -   if set, return idl data type  from size function
;		type		data type
;		  0		 ???
;		  1		 byte
;		  2		 integer
;		  3		 longword
;		  4		 floating point
;		  5		 double precision
;		  6		 ???
;		  7		 string
;		  8		 structure
;      ndimen - if set, return number dimensions (size(0))
;      nimages - if set, return #images (1->2D, NI->3D, else 0)
;      xsize - if set, return X size (size(data))(1)
;      nx    - synonym for xsize
;      ysize - if set, return Y size (size(data))(2)
;      ny    - synonym for ysize
;      string/struct/undefined - if set, return true if type matches 
;      scalar, vector - if set, true if data of specified variety
;            
;   Calling Examples:
;      if (data_chk(p1,/type) eq data_chk(p2,/type)) then...
;      case data_chk(data,/type) of...
;      if data_chk(data,/string,/scalar) then ...
;      if data_chk(data,/string,/struct,/undef,/orr)
;      case data_chk(maybe_cube,/nimages) of...
;
;   History:
;      27-Apr-1993 (SLF)
;      21-Mar-1994 (SLF) documentation header
;      10-oct-1996 (SLF) add SCALAR (synonym for the historical mispell SCALER)
;       2-oct-1997 (SLF) add NIMAGES
;      15-nov-1997 (SLF) add XSIZE and YSIZE keyword and function
;      20-oct-2002 (LWA) added list of data types to header
;       2-jan-2007 (SLF) removed vestigal references to ORR (not supported)
;
;   Restrictions:
;      some keywords are mutually exclusive - for self-documenting code 
;      and reduction of code duplicataion 
;      ORR not supported (place holder never realized - you'll have to
;      do your own 'ands' and 'ors' external (could write data_chks.pro
;      driver with keyword inherit via _extra to This routine...)
;-  
if keyword_set(orr) then box_message,$
   'Warning: unsupported keyword /ORR ignored' 
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
   keyword_set(nimages):retval=([0,1,sp1(idldimen),0])(idldimen-1>0<3)
   keyword_set(xsize) or keyword_set(nx):  retval=([0,sp1(1)])(idldimen ge 1)
   keyword_set(ysize) or keyword_set(ny):  retval=([0,sp1(2)])(idldimen ge 2)
;  else - Handle booleans
   else: begin   
      dimenval=0			; default to false
      dimenchk=-1
      if keyword_set(scaler) or keyword_set(scalar) then dimenchk= $
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
