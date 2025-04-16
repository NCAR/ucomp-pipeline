; docformat = 'rst'

;+
; Check whether any temperatures are outside the nominal range for that specific
; temperature.
;
; :Returns:
;   1B if any temperature is outside the nominal range
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
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_check_nominal_temps, file, $
                                            primary_header, $
                                            ext_data, $
                                            ext_headers, $
                                            run=run
  compile_opt strictarr

  tolerance = 0.001

  ; This should be changed to 0C to 50C for all temperatures with the exception
  ; of TU_C0PCB and TU_C1PCB which are unreliable. For now we will ignore these
  ; values.

  std_min_temp = 0.0
  std_max_temp = 50.0

  locations = ['BASE', 'LNB1', 'LNB2', 'RACK']
  std_keywords = ['T_' + locations, $
                  'TU_' + locations, $
                  'TU_C' + ['0', '1'] + 'ARR']

  ; A subset of temperatures requires a more stringent validity range. Use the
  ; following:
  ;
  ; - TU_LCVR{1,2,3,4,5}/T_LCRV{1,2,3,4,5} between 30C and 39C
  ; - TU_MOD/T_MOD between 25C and 36C

  lcvr_min_temp = 30.0
  lcvr_max_temp = 39.0

  lcvr_keywords = 'LCVR' + ['1', '2', '3', '4', '5']
  lcvr_keywords = ['T_' + lcvr_keywords, 'TU_' + lcvr_keywords]

  mod_min_temp = 25.0
  mod_max_temp = 36.0

  mod_keywords = ['T_', 'TU_'] + 'MOD'

  result = 0B

  ; TODO: what about NaNs?

  for t = 0L, n_elements(std_keywords) - 1L do begin
    temp = ucomp_getpar(primary_header, std_keywords[t], /float, found=found)
    result = result || (temp lt std_min_temp) || (temp gt std_max_temp)
  endfor

  for t = 0L, n_elements(lcvr_keywords) - 1L do begin
    temp = ucomp_getpar(primary_header, lcvr_keywords[t], /float, found=found)
    result = result || (temp lt lcvr_min_temp) || (temp gt lcvr_max_temp)
  endfor

  for t = 0L, n_elements(mod_keywords) - 1L do begin
    temp = ucomp_getpar(primary_header, mod_keywords[t], /float, found=found)
    result = result || (temp lt mod_min_temp) || (temp gt mod_max_temp)
  endfor

  return, result
end
