; docformat = 'rst'

;+
; Return the quality conditions to check for cal files of any kind, darks,
; flats, or other cal files.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', description: ''}
;-
function ucomp_cal_quality_conditions, wave_region, run=run
   compile_opt strictarr

  ; don't set mask initially, set after creating so that conditions can be
  ; reordered easily
  quality_conditions = [{mask: 0UL, $
                         checker: 'ucomp_quality_occulterin_flats', $
                         description: 'make sure occulter is not in for flats'}, $
                        {mask: 0UL, $
                         checker: 'ucomp_quality_datatype', $
                         description: 'multiple datatypes in a file'}]

  quality_conditions.mask = 2UL ^ (ulindgen(n_elements(quality_conditions)))

  return, quality_conditions
end
