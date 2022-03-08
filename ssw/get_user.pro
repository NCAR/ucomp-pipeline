function get_user,dummy
;+
;  NAME:
;      get_user
;
;  PURPOSE:
;      Find out the name of the user as defined by the environment
;      variable USER
;
;  INPUT PARAMETERS:
;	None.
;
;  OUTPUT PARAMETERS:
;	Returned value is the interpretted USER value.
;
;  PROCEEDURE:
;	Spawn a child process and pipe the result back.
;
;  HISTORY:
;	Written, 14-jan-92, JRL
;                 4-oct-94, SLF - spawn 'whoami' first, then try the old
;				  printenv if USER not defined
;                                 (protect against loud .cshrc files)
;-
spawn,'whoami',result,/noshell

if result(n_elements(result)-1) eq '' then spawn,"printenv USER",result

result=result(n_elements(result)-1)

return,result				; Return as a scalar string
end
