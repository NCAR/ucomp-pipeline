pro kilroy,here,ndot=ndot,dot=dot,say=say, _extra=e
;+
;procedure	kilroy
;	"kilroy was here"
;	writes a little something to the screen every time it is called
;
;syntax
;	kilroy,here,ndot=ndot,dot=dot,say=say
;
;parameters
;	here	[I/O; optional] if given, is included in the output and
;		is increased by 1 upon output.
;		* cannot be a string
;			
;keywords
;	ndot	[INPUT] number of dots to write out (default is 1)
;	dot	[INPUT] symbol to use (default is ".")
;	say	[INPUT] an extra word or whatever to print out
;	_extra	[JUNK] here only to avoid crashing the program
;
;history
;	vinay kashyap (Aug 1996)
;-

sim='.' & if keyword_set(dot) then sim=string(dot)
nsym=1 & if keyword_set(ndot) then nsym=fix(ndot)>0

sym='' & for i=0,nsym-1 do sym=sym+sim
if keyword_set(say) then sym='('+string(say,2)+')'+sym
if keyword_set(here) then begin
  sym=sym+strtrim(here(0),2)
  here=here+1
endif else here=1

lsym=strlen(sym) & form="($,a"+strtrim(lsym,2)+")"
print,form=form,sym

return
end
