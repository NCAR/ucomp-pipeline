; docformat = 'rst'

;+
; Check whether any sequential extensions of the file are taken too far apart.
;
; :Returns:
;   1B if any sequential extensions of the file are acquired more than
;   "max_ext_interval" epoch value seconds apart
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
function ucomp_quality_check_time_interval, file, $
                                            primary_header, $
                                            ext_data, $
                                            ext_headers, $
                                            run=run
  compile_opt strictarr

  if (file.n_extensions lt 2L) then return, 0L

  run = file.run
  times = dblarr(file.n_extensions)

  for e = 0L, file.n_extensions - 1L do begin
    date_begin = ucomp_getpar(ext_headers[e], 'DATE-BEG')
    times[e] = ucomp_dateobs2julday(date_begin)
  endfor

  times -= times[0]                ; convert absolute to offset
  times *= 24.0D * 60.0D * 60.0D   ; days to seconds

  diffs = times[1:*] - times[0:-2]

  max_ext_time = run->epoch('max_ext_time')
  !null = where(diffs gt max_ext_time, n_bad)
  return, n_bad gt 0L
end
