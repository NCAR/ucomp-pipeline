; docformat = 'rst'

;+
; Check whether any temperatures are outside the nominal range.
;
; :Returns:
;   1B if any temperature is outside the nominal range
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_check_nominal_temps, file, $
                                            primary_header, $
                                            ext_data, $
                                            ext_headers, $
                                            run=run
  compile_opt strictarr

  tolerance = 0.001

  min_temp = -20.0
  max_temp = 100.0

  result = 0B

  ; TODO: should I only check temperature if it present?

  both_temp_keywords = ['RACK', 'BASE', 'LCVR1', 'LCVR2', 'LCVR3', 'LCVR4', 'LCVR5']
  for t = 0L, n_elements(both_temp_keywords) - 1L do begin
    temp = ucomp_getpar(primary_header, 'T_' + both_temp_keywords[t], /float, found=found)
    result = result || (finite(temp) eq 0L) || (temp lt min_temp) || (temp gt max_temp)

    temp = ucomp_getpar(primary_header, 'TU_' + both_temp_keywords[t], /float, found=found)
    result = result || (finite(temp) eq 0L) || (temp lt min_temp) || (temp gt max_temp)
  endfor

  temp_keywords = ['TU_C0ARR', 'TU_C0PCB', 'TU_C1ARR', 'TU_C1PCB']
  for t = 0L, n_elements(temp_keywords) - 1L do begin
    temp = ucomp_getpar(primary_header, temp_keywords[t], /float, found=found)
    result = result || (finite(temp) eq 0L) || (temp lt min_temp) || (temp gt max_temp)
  endfor

  return, result
end
