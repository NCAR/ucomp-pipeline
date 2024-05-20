; docformat = 'rst'

;+
; Check whether any two of T_LCVR{1,2,3,4,5} are equal.
;
; :Returns:
;   1B if any two of T_LCVR{1,2,3,4,5} are equal for the file
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
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_check_identical_temps, file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              backgrounds, $
                                              run=run
  compile_opt strictarr

  tolerance = 0.0001

  return, (~finite(file.tu_lcvr1 - file.tu_lcvr2)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr2) lt tolerance) $
            || (~finite(file.tu_lcvr1 - file.tu_lcvr3)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr3) lt tolerance) $
            || (~finite(file.tu_lcvr1 - file.tu_lcvr4)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr4) lt tolerance) $
            || (~finite(file.tu_lcvr1 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr5) lt tolerance) $
            || (~finite(file.tu_lcvr2 - file.tu_lcvr3)) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr3) lt tolerance) $
            || (~finite(file.tu_lcvr2 - file.tu_lcvr4)) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr4) lt tolerance) $
            || (~finite(file.tu_lcvr2 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr5) lt tolerance) $
            || (~finite(file.tu_lcvr3 - file.tu_lcvr4)) $
            || (abs(file.tu_lcvr3 - file.tu_lcvr4) lt tolerance) $
            || (~finite(file.tu_lcvr3 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr3 - file.tu_lcvr5) lt tolerance) $
            || (~finite(file.tu_lcvr4 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr4 - file.tu_lcvr5) lt tolerance)
end
