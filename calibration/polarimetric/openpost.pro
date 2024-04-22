pro openpost,answer,default=default,file=file,no_ask=no_ask

answer=' '
if n_elements(default) gt 0 then def=default else def='p'

;    if no_ask keyword is present, use default as response

;    if filename is given, assume ps output

if keyword_set(no_ask) then begin
    answer=def
endif else begin
    print,format='("output to screen, postscript, or null (spn, cr=",a1,")",$)',def
    read,answer
    if answer eq '' then answer=def
endelse

if answer eq 'n' then set_plot,'null'
if answer eq 'p' then begin
    set_plot,'ps'
    if n_elements(file) gt 0 then name=file
    device,filename=name,xsize=7.5,ysize=10,/inches,xoff=0.5,yoff=0.5,/portrait
    device,/color
    thick,3
endif

end
