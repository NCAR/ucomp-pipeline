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
     description: 'in/out values that are neither in or out'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_time_interval', $
     description: string(run->epoch('max_ext_time'), $
                         format='(%"check for sequential extensions acquired more than %0.1f secs apart")')}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_datatype', $
     description: 'multiple datatypes in a file'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_all_zero', $
     description: 'an extension is identically zero'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_identical_temps', $
     description: 'any reported temperatures are identical'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_nominal_temps', $
     description: 'a temperature is not in the nominal range'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_check_o1focus', $
     description: 'multiple O1FOCUS values in a file'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_saturated', $
     description: 'checked for saturated and non-linear pixels in a file'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_wave_region', $
     description: 'ensure all wavelengths match wave region'}]

  quality_conditions.mask = 2UL ^ (ulindgen(n_elements(quality_conditions)))

  return, quality_conditions
end


; main-level example

quality_bitmask = '10101'b
wave_region = '1074'
date = '20221101'
mode = 'test'
config_basename = 'ucomp.latest.cfg'

config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, mode, config_filename)
conditions = ucomp_quality_conditions(wave_region, run=run)
bad_condition_indices = where(quality_bitmask and conditions.mask, /null)
bad_conditions = strjoin(strmid(conditions[bad_condition_indices].checker, 14), '|')
print, bad_conditions, format='bad conditions: %s'
obj_destroy, run

end
