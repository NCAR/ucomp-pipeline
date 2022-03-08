function get_host, dummy, short=short
;+
;  NAME:
;      get_host
;
;  PURPOSE:
;      Find out the name of the ultrix system as defined in the system
;      variable "hostname"
;
;  INPUT PARAMETERS:
;	short	- If set, then only return the node name, not the full
;		  address (ie sxt2 instead of sxt2.space.lockheed.com)
;
;  OUTPUT PARAMETERS:
;	Returned value is the interpretted `hostname` value.
;
;  PROCEEDURE:
;	Spawn a child process and pipe the result back.
;
;  HISTORY:
;	Written, 30-sep-91, JRL
;	12-Mar-92 (MDM) - Changed to work for VMS as well as  Unix.
;	24-mar-92 (JRL) - Updated for IRIX operating system
;	26-mar-92 (SLF) - Got it working for SUNs (again)
;	30-mar-92 (SLF) - Put vms in the case where it belongs 
;	26-Jul-94 (MDM) - Added /SHORT keyword
;        4-oct-94 (SLF) - spawn 'hostname' (avoid shell), protect agains .cshrc
;                         minor change in 'short' generation
;                         Noted that there are more modifications to this
;			  program then lines of code...
;	28-Mar-95 (MDM) - Modified 'irix' to use /usr/bsd/hostname with /noshell
;			  to make it much faster
;-
;
case strlowcase ( !version.os ) of 
   'vms'   : spawn, 'write sys$output f$getsyi("nodename")', result
   'irix'  : begin
		;;spawn,"hostname" ,result,/noshell
		;;if (result(0) eq '') then spawn, "/usr/bsd/hostname", result, /noshell
		spawn, "/usr/bsd/hostname", result, /noshell
		if (result(0) eq '') then spawn,"printenv HOST" ,result
	     end
   else:spawn,"hostname" ,result,/noshell   ;slf handles ultrix/SUNOS
endcase
;
out=result(n_elements(result)-1)	; protect agains .cshrc output
;
if (keyword_set(short)) then out=(str2arr(out,'.'))(0)
;
return,out
end
