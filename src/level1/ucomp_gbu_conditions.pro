; docformat = 'rst'

;+
; Return the GBU conditions to check available.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', descriptions: ''}
;-
function ucomp_gbu_conditions, wave_region, run=run
   compile_opt strictarr

  gbu_conditions = [{mask: 1UL, $
                     checker: 'ucomp_gbu_check_identical_temps', $
                     description: 'at least two identical T_LCVR{1,2,3,4,5} temperatures'}]
  return, gbu_conditions
end
