; docformat = 'rst'

;+
; In the primary header, change::
;
;   T_C0ARR =   4.992 / [C] Camera 0 Sensor array temp
;   T_C0PCB =  34.000 / [C] Camera 0 PCB board temp
;   T_C1ARR =   5.025 / [C] Camera 1 Sensor array temp
;   T_C1PCB =  33.500 / [C] Camera 1 PCB board temp
;
; to::
;
;   TU_C0ARR =  4.992 / [C] Camera 0 Sensor array temp Unfiltered
;   TU_C0PCB = 34.000 / [C] Camera 0 PCB board temp Unfiltered
;   TU_C1ARR =  5.025 / [C] Camera 1 Sensor array temp Unfiltered
;   TU_C1PCB = 33.500 / [C] Camera 1 PCB board temp Unfiltered
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_t2tu, primary_header, ext_data, ext_headers
  compile_opt strictarr

  names = ['C0ARR', 'C0PCB', 'C1ARR', 'C1PCB']
  for n = 0L, n_elements(names) - 1L do begin
    value = ucomp_getpar(primary_header, 'T_' + names[n], $
                         comment=comment, $
                         found=found)
    if (found) then begin
        ucomp_addpar, primary_header, 'TU_' + names[n], value, $
                      comment=string(comment, format='%s Unfiltered'), $
                      format='(F0.3)', $
                      after='T_' + names[n]
        sxdelpar, primary_header, 'T_' + names[n]
    endif
  endfor
end
