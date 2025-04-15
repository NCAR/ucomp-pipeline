; docformat = 'rst'

;+
; Check whether there are too many repeated temperatures:.
;
; - If all temperatures are the same, the file is labelled bad.
; - If the 5 `TU_LCVR{1,2,3,4,5}` or the 5 `T_LCVR{1,2,3,4,5}` are the same,
;   the file is labelled bad.
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

  ; TODO: what about NaN temperatures?

  lcvr_keywords = 'LCVR' + ['1', '2', '3', '4', '5']

  good_t_lcvr_temps = 0B
  t_lcvr1 = ucomp_getpar(primary_header, 'T_' + lcvr_keywords[0])

  good_tu_lcvr_temps = 0B
  tu_lcvr1 = ucomp_getpar(primary_header, 'TU_' + lcvr_keywords[0])

  for i = 2L, n_elements(lcvr_keywords) - 1L do begin
    t_keyword = 'T_' + lcvr_keywords[i]
    if (abs(t_lcvr1 - ucomp_getpar(primary_header, t_keyword)) gt tolerance) then begin
      good_t_lcvr_temps = 1B
    endif
    tu_keyword = 'TU_' + lcvr_keywords[i]
    if (abs(tu_lcvr1 - ucomp_getpar(primary_header, tu_keyword)) gt tolerance) then begin
      good_tu_lcvr_temps = 1B
    endif
  endfor

  locations = ['BASE', 'LNB1', 'MOD', 'LNB2', 'RACK']
  all_temp_keywords = ['T_' + locations, $
                       'TU_' + locations, $
                       'T_' + lcvr_keywords, $
                       'TU_' + lcvr_keywords, $
                       'TU_C0' + ['ARR', 'PCB'], $
                       'TU_C1' + ['ARR', 'PCB']]

  good_temps = 0B
  t_base = ucomp_getpar(primary_header, 'T_BASE')

  for i = 2L, n_elements(all_temp_keywords) - 1L do begin
    keyword = all_temp_keywords[i]
    if (abs(t_base - ucomp_getpar(primary_header, keyword)) gt tolerance) then begin
      good_temps = 1B
    endif
  endfor

  return, ~good_temps || ~good_t_lcvr_temps || ~good_tu_lcvr_temps
end
