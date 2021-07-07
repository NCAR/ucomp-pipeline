; docformat = 'rst'

;+
; Validate the DATATYPE FITS keyword vs. the OCCLTR, CALOPTIC, COVER, DIFFUSR,
; and DARKSHUT keywords.
;
; :Returns:
;   1 if DATATYPE is consistent with OCCLTR, CALOPTIC, COVER, DIFFUSR, and
;   DARKSHUT; 0 otherwise
;
; :Params:
;   header : in, required, type=strarr
;     level 0 extension FITS header
;-
function ucomp_validate_datatype, header
  compile_opt strictarr

  datatype = ucomp_getpar(header, 'DATATYPE')

  cover = ucomp_getpar(header, 'COVER')
  darkshutter = ucomp_getpar(header, 'DARKSHUT')
  if (cover eq 'in' || darkshutter eq 'in') then begin
    return, datatype eq 'dark'
  endif else begin
    caloptic = ucomp_getpar(header, 'CALOPTIC')
    if (caloptic eq 'in') then begin
      return, datatype eq 'cal'
    endif else begin
      diffuser = ucomp_getpar(header, 'DIFFUSR')
      if (diffuser eq 'in') then begin
        return, datatype eq 'flat'
      endif else begin
        return, datatype eq 'sci'
      endelse
    endelse
  endelse

  return, 0B
end
