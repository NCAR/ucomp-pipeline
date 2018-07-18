function tag_index, str, tag
;
;+
;   Name: tag_index
;
;   Purpsose: return tag position (index) of 'tag' within 'str'
;
;   Input Parameters: 
;	str - structure
;	tag - tag name (string scaler or vector )
;
;   Output:
;       function returns indices of tag within str (-1 if not found)
;	longword scaler returned if tag is scaler, else longword vector 
;
;   History: slf 
;   	     modified, 21-feb-92 for to allow tag vector
;-
on_error,2 
if n_tags(str) eq 0 then message,"Structure required"     
;
tagnames=strupcase(tag_names(str))
;
positions=[0]					;initiailze array
for i=0, n_elements(tag)-1 do $ 
   positions=[positions, where(strupcase(tag(i)) eq tagnames)]
;
positions=positions(1:*)				; elim. 1st
if n_elements(tag) eq 1 then positions=positions(0)	;make scaler
;
return,positions					
end
;
;
 

