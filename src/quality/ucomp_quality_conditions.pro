; docformat = 'rst'

;+
; Return the quality conditions to check.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', descriptions: ''}
;-
function ucomp_quality_conditions, wave_region, run=run
   compile_opt strictarr

  ; don't set mask initially, set after creating so that conditions can be
  ; reordered easily
  quality_conditions = [{mask: 0UL, $
                         checker: 'ucomp_quality_inout', $
                         description: 'in/out values that are neither in or out'}, $
                        {mask: 0UL, $
                         checker: 'ucomp_quality_sgsloop', $
                         description: 'SGSLOOP not high enough'}, $
                        {mask: 0UL, $
                         checker: 'ucomp_quality_check_time_interval', $
                         description: string(run->epoch('max_ext_time'), $
                                             format='(%"sequential extensions acquired more than %0.1f secs apart")')}, $
                        {mask: 0UL, $
                         checker: 'ucomp_quality_datatype', $
                         description: 'multiple datatypes in a file'}, $
                        {mask: 0UL, $
                         checker: 'ucomp_quality_all_zero', $
                         description: 'check if any extension is identically zero'}]

  quality_conditions.mask = 2UL ^ (ulindgen(n_elements(quality_conditions)))

  return, quality_conditions
end
