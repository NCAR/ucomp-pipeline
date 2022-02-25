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
                         checker: 'ucomp_quality_sgsloop', $
                         description: 'SGSLOOP not high enough'}]

  quality_conditions.mask = 2UL ^ (ulindgen(n_elements(quality_conditions)))

  return, quality_conditions
end
