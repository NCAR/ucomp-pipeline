;+
; Project     :	SOHO - CDS
;
; Name        :	CLEAR_STRUCT
;
; Purpose     :	clear all field values in a structure
;
; Explanation :	initializes field values by setting to 0 or blank
;               strings as appropriate.
;
; Use         : NEW_STRUCT=CLEAR_STRUCT(STRUCT)
;
; Inputs      :	STRUCT = input structure
;
; Opt. Inputs :	None.
;
; Outputs     :	NEW_STRUCT = initialized original structure
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	NEW_STRUCT (recursively for nested structures)
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Structure handling
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC)
;
; Version     :	Version 1.0, 22 September 1994
;-


function clear_struct,struct      ;-- clear a structure

on_error,1

if datatype(struct) ne 'STC' then message,'invalid input structure'

new_struct=0
nstruct=n_elements(struct)
name=tag_names(struct,/struct)
if name ne '' then begin
 s=execute('new_struct={'+name+'}')
endif else begin
 new_struct=struct(0)
 for i=0,n_elements(tag_names(new_struct))-1 do begin
  item=struct.(i)
  if datatype(item) eq 'STC' then new_struct.(i)=clear_struct(item) else begin
   if datatype(item) eq 'STR' then new_struct.(i)='' else new_struct.(i)=0
  endelse
 endfor
endelse

if nstruct gt 1 then new_struct=replicate(new_struct,nstruct)
return,new_struct & end


