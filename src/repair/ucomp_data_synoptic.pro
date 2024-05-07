; docformat = 'rst'

;+
; Change the cookbook, OBS_PLAN, to a synoptic program name.
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_synoptic, primary_header, ext_data, ext_headers
  compile_opt strictarr

  ucomp_addpar, primary_header, 'OBS_PLAN', 'oldLineFineScan.cbk'
  date = ucomp_getpar(primary_header, 'DATE-OBS')
  mg_log, 'changing OBS_PLAN for %s', date, name='ucomp/eod', /debug
end
