; docformat = 'rst'

;+
; Return the GBU conditions to check.
;
; :Returns:
;   array of structures defined::
;
;     {mask: 0UL, checker: '', description: '', values: ''}
;
;   where mask is a bitmask set to a power of two which can be OR-ed with other
;   masks, checker is the  name of the condition's checking routine, description
;   is a text description of the condition, and values is a string of the
;   variable to insert into the description (prefixed by either E, for epoch
;   file, or W, for wave region, on where to lookup the value). This is used in
;   `UCOMP_GBU_WRITE` to print the condition along with its threshold on the
;   given day.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to retrieve the GBU conditions for
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_gbu_conditions, wave_region, run=run
   compile_opt strictarr

  ; don't set mask initially, set after creating so that conditions can be
  ; reordered easily
  gbu_conditions = [{mask: 0UL, $
                     checker: 'ucomp_gbu_sgsloop', $
                     description: 'spar guide control loop is below threshold (%(sgsloop_min)0.2f)', $
                     values: 'Esgsloop_min'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_sgsdimv', $
                     description: 'spar guider intensity below threshold (0.9 * %(i0)0.3f * exp(-0.05 * secz))', $
                     values: 'Ei0'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_max_background', $
                     description: 'median background is above threshold (%(gbu_max_background)0.1f)', $
                     values: 'Wgbu_max_background'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_min_background', $
                     description: 'median background is below threshold (%(gbu_min_background)0.1f)', $
                     values: 'Wgbu_min_background'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_vcrosstalk', $
                     description: 'spurious Stokes V signal is above threshold (%(gbu_max_v_metric)0.1f)', $
                     values: 'Wgbu_max_v_metric'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_fit_chisq', $
                     description: 'the chi-squared of the occulter fit is above threshold (%(gbu_max_fit_chisq)0.1f)', $
                     values: 'Wgbu_max_fit_chisq'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_median_diff', $
                     description: 'the difference of the image with the median is above threshold (%(gbu_max_stddev)0.1f)', $
                     values: 'Wgbu_max_stddev'}]
  gbu_conditions.mask = 2UL ^ (ulindgen(n_elements(gbu_conditions)))

  return, gbu_conditions
end
