; docformat = 'rst'

;+
; Return the GBU conditions to check.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', descriptions: ''}
;-
function ucomp_gbu_conditions, wave_region, run=run
   compile_opt strictarr

  ; don't set mask initially, set after creating so that conditions can be
  ; reordered easily
  gbu_conditions = [{mask: 0UL, $
                     checker: 'ucomp_gbu_check_identical_temps', $
                     description: 'at least two identical TU_LCVR{1,2,3,4,5} temperatures'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_check_nominal_temps', $
                     description: 'a temperature outside the nominal range'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_check_time_interval', $
                     description: string(run->epoch('max_ext_time'), $
                                         format='(%"sequential extensions acquired more than %0.2f secs apart")')}]

  gbu_conditions.mask = 2UL ^ (ulindgen(n_elements(gbu_conditions)) + 1UL)

  return, gbu_conditions
end
