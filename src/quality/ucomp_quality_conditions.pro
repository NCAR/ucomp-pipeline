; docformat = 'rst'

;+
; Return the quality conditions to check.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', descriptions: ''}
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, i..e, "1074"
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_quality_conditions, wave_region, run=run
   compile_opt strictarr

  ; don't set mask initially, set after creating so that conditions can be
  ; reordered easily
  quality_conditions = [ $
    {mask: 0UL, $
     checker: 'ucomp_quality_inout', $
     description: 'check for in/out values that are neither in or out'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_time_interval', $
     description: string(run->epoch('max_ext_time'), $
                         format='(%"check for sequential extensions acquired more than %0.1f secs apart")')}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_datatype', $
     description: 'check for multiple datatypes in a file'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_all_zero', $
     description: 'check if any extension is identically zero'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_identical_temps', $
     description: 'check if any reported temperatures are identical'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_nominal_temps', $
     description: 'check if all temperatures are in nominal range'}]

  quality_conditions.mask = 2UL ^ (ulindgen(n_elements(quality_conditions)))

  return, quality_conditions
end
