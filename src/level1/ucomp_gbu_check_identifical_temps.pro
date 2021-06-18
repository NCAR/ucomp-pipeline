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
;-
function ucomp_gbu_check_identical_temps, file
  compile_opt strictarr

  tolerance = 0.001

  return, (abs(file.t_lcvr1 - file.t_lcvr2) lt tolerance) $
            || (abs(file.t_lcvr1 eq file.t_lcvr3) lt tolerance) $
            || (abs(file.t_lcvr1 eq file.t_lcvr4) lt tolerance) $
            || (abs(file.t_lcvr1 eq file.t_lcvr5) lt tolerance) $
            || (abs(file.t_lcvr2 eq file.t_lcvr3) lt tolerance) $
            || (abs(file.t_lcvr2 eq file.t_lcvr4) lt tolerance) $
            || (abs(file.t_lcvr2 eq file.t_lcvr5) lt tolerance) $
            || (abs(file.t_lcvr3 eq file.t_lcvr4) lt tolerance) $
            || (abs(file.t_lcvr3 eq file.t_lcvr5) lt tolerance) $
            || (abs(file.t_lcvr4 eq file.t_lcvr5) lt tolerance)
end
