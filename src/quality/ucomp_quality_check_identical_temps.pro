; docformat = 'rst'

;+
; Check whether there are too many repeated temperatures. See #321 for a
; discussion about what is too many repeated temperatures.
;
; :Returns:
;   1B if there are too many repeated temperatures
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_check_identical_temps, file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              backgrounds, $
                                              run=run
  compile_opt strictarr

  tolerance = 0.0001

  ; Main question for this test is what to do about NaN temperatures? My
  ; tentative answer is to ignore NaN temperatures and try to do the tests
  ; without them. For example:
  ;  - Is it OK if T_LCVR{1,2,3,4,5} are all NaN?
  ;    - I am saying this is OK. The temperatures might be bad, but there is no
  ;      positive evidence they are.
  ;  - Is it OK if T_LCVR{1,2,3,4} are identical and T_LCVR5 is NaN?
  ;    - I am saying this is bad: the only temperatures we know about are
  ;      identical.

  lcvr_keywords = 'LCVR' + ['1', '2', '3', '4', '5']

  t_lcvr_temps  = fltarr(n_elements(lcvr_keywords))
  tu_lcvr_temps = fltarr(n_elements(lcvr_keywords))
  for k = 0L, n_elements(lcvr_keywords) - 1L do begin
    t_lcvr_temps[k]  = ucomp_getpar(primary_header, 'T_' + lcvr_keywords[k], /float)
    tu_lcvr_temps[k] = ucomp_getpar(primary_header, 'TU_' + lcvr_keywords[k], /float)
  endfor

  finite_t_lcvr_temps_indices = where(finite(t_lcvr_temps), n_finite_t_lcvr_temps)
  if (n_finite_t_lcvr_temps eq 0L) then begin
    good_t_lcvr_temps = 1B
  endif else begin
    t = t_lcvr_temps[finite_t_lcvr_temps_indices]
    n = n_finite_t_lcvr_temps
    diffs = abs(rebin(reform(t, 1, n), n, n) - rebin(reform(t, n, 1), n, n))
    good_t_lcvr_temps = max(diffs) lt tolerance ?  0B : 1B
  endelse

  finite_tu_lcvr_temps_indices = where(finite(tu_lcvr_temps), n_finite_tu_lcvr_temps)
  if (n_finite_tu_lcvr_temps eq 0L) then begin
    good_tu_lcvr_temps = 1B
  endif else begin
    t = tu_lcvr_temps[finite_tu_lcvr_temps_indices]
    n = n_finite_tu_lcvr_temps
    diffs = abs(rebin(reform(t, 1, n), n, n) - rebin(reform(t, n, 1), n, n))
    good_tu_lcvr_temps = max(diffs) lt tolerance ?  0B : 1B
  endelse

  ; good_t_lcvr_temps/good_tu_lcvr_temps will true if there is at least one
  ; temperature in T_LCVRX/TU_LCVRX that is different from the others (not
  ; including NaNs).

  locations = ['BASE', 'LNB1', 'MOD', 'LNB2', 'RACK']
  all_temp_keywords = ['T_' + locations, $
                       'TU_' + locations, $
                       'T_' + lcvr_keywords, $
                       'TU_' + lcvr_keywords, $
                       'TU_C0' + ['ARR', 'PCB'], $
                       'TU_C1' + ['ARR', 'PCB']]

  all_temps  = fltarr(n_elements(all_temp_keywords))
  for k = 0L, n_elements(all_temp_keywords) - 1L do begin
    all_temps[k]  = ucomp_getpar(primary_header, all_temp_keywords[k], /float)
  endfor

  finite_all_temps_indices = where(finite(all_temps), n_finite_all_temps)
  if (n_finite_all_temps eq 0L) then begin
    good_all_temps = 1B
  endif else begin
    t = all_temps[finite_all_temps_indices]
    n = n_finite_all_temps
    diffs = abs(rebin(reform(t, 1, n), n, n) - rebin(reform(t, n, 1), n, n))
    good_all_temps = max(diffs) lt tolerance ?  0B : 1B
  endelse

  return, ~good_all_temps || ~good_t_lcvr_temps || ~good_tu_lcvr_temps
end
