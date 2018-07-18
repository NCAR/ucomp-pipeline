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
;                20-aug-97, SLF - extend to vms (per D.Zarro, get_user_id)
;                22-Jun-00, RDB - if none set, make user "windows" under windows
;-
result=get_logenv('USER')
case strlowcase(os_family()) of

   'vms': begin
      spawn, 'write sys$output f$getjpi(f$pid(pid), "username")',result
      result=strtrim(result,2)
   endcase

   'unix': begin
      spawn,'whoami',result,/noshell
      if result(n_elements(result)-1) eq '' then spawn,"printenv USER",result
      result=result(n_elements(result)-1)
   endcase

   'windows': begin
      if result eq '' then result='windows'
   endcase

   else: begin
   endcase
endcase

return,result				; Return as a scalar string
end
