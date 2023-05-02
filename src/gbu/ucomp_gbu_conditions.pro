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
                     checker: 'ucomp_gbu_sgsloop', $
                     description: 'spar guide control loop is not locked'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_sgsdims', $
                     description: 'spar guider intensity below threshold'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_max_background', $
                     description: 'median background is above threshold'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_min_background', $
                     description: 'median background is below threshold'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_vcrosstalk', $
                     description: 'spurious Stokes V signal is above threshold'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_fit_chisq', $
                     description: 'the chi-squared of the occulter fit is above threshold'}, $
                    {mask: 0UL, $
                     checker: 'ucomp_gbu_median_diff', $
                     description: 'the difference of the image with the median is above threshold'}]
  gbu_conditions.mask = 2UL ^ (ulindgen(n_elements(gbu_conditions)))

  return, gbu_conditions
end
