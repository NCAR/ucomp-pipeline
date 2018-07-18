;+
; Project     : HESSI
;                  
; Name        : GET_RID
;               
; Purpose     : return a random ID 
;                             
; Category    : system utility
;               
; Explanation : uses combination of current time and random function
;               
; Syntax      : IDL> id=get_rid()
;    
; Inputs      : None
;               
; Outputs     : ID = random id
;               
; Keywords    : /TIME = include a time part
;               /ULONG = convert to Unsigned long
;             
; History     : 29-Nov-1999, Zarro (SM&A/GSFC), written
;
; Contact     : dzarro@solar.stanford.edu
;-    

function get_rid,time=time,ulong=ulong

common get_rid_random,seed
temp=''
if keyword_set(time) then begin
 temp=strtrim(string(systime(/sec),format='(i10)'),2)
endif

tseed=strtrim(nint(randomu(seed)*10000.),2)
rid=temp+tseed

if keyword_set(ulong) then return,ulong(rid) else return,rid

end

