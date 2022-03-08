pro lprint, file, _extra=_extra
;
;+
;   Name: lprint (Obsolete - see sprint.pro)
;
;   Purpose: print a file; place holder reference for an old/obsolete routine
;
;   Input Parameters:
;      file - file to print
;
;   Keyword Parameters:
;      _extra - any keyword accepted by sprint.pro
;
;   History:
;      28-Oct-2001 - S.L.Freeland - restore existing 'lprint' references
;
;-

box_message,'LPRINT (Obsolete routine; suggest use of sprint.pro)'
sprint,file,_extra=_extra
return
end
