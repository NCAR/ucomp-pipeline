function strstat,strname, quiet=quiet 
;
;+
;   Name: strstat
;
;   Purpose: check to see if the input structure name exists
;
;   Input Parameters:
;	strname = string containing structure name to check
;
;   Optional Keyword Parameters:
;	quiet - if keyword set then quietinformational messages are
;		inhibited 
;
;   Output:
;	function returns 1 if structure exists
;		 returns 0 if structure does not exist
;
;   Side Effects:
;       prints informational message if info is set
;   
;   History: SLF, 10/23/91 to allow make_str to avoid previously
;	     allocated names as occured when idl restore was used
;
;-
;
; store !quiet in temporary (no global side effects)
quiet_temp=!quiet
!quiet= keyword_set(quiet)
;
;try to form a structure using input name
;
test='test={' + strname + '}'
test=execute(test)
;
; execute statement status is 0 if error (structure did not exist)
; since an error is 'good' from the standpoint of make_str, print
; a message which indicates success to negate error message
if not test then $ 
   message,/inform, 'structure name: ' + strname + ' ok to use' else $
   message,/inform, 'structure name: ' + strname + ' already allocated'
;
;
!quiet=quiet_temp		; restore system variable

return,test
end
