; docformat = 'rst'

;+
; Return the quality conditions to check for cal files of any kind, darks,
; flats, or other cal files.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', description: ''}
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_cal_quality_conditions, wave_region, run=run
   compile_opt strictarr

  ; don't set mask initially, set after creating so that conditions can be
  ; reordered easily

  quality_conditions = [ $
    {mask: 0UL, $
     checker: 'ucomp_quality_occulterin_flats', $
     name: 'occulterin_flats', $
     description: 'make sure occulter is not in for flats'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_datatype', $
     name: 'datatype', $
     description: 'check for multiple datatypes (except flat/cal) in a file'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_dark_values', $
     name: 'dark_values', $
     description: 'check median dark value in nominal range'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_all_zero', $
     name: 'all_zero', $
     description: 'check if any extension is identically zero'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_inout', $
     name: 'inout', $
     description: 'check for in/out values that are neither in or out'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_missing_state', $
     name: 'missing_state', $
     description: 'check if missing a state after removing bad frames and averaging'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_contin', $
     name: 'contin', $
     description: 'check CONTIN is the same for every extension'}, $
    {mask: 0UL, $
     checker: 'ucomp_quality_nuc', $
     name: 'nuc', $
     description: 'check RCAMNUC and TCAMNUC are standard and consistent'}]

  quality_conditions.mask = 2UL ^ (ulindgen(n_elements(quality_conditions)))

  return, quality_conditions
end
