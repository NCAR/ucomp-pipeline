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
;-
function ucomp_gbu_check_time_interval, file
  compile_opt strictarr

  run = file.run
  times = dblarr(file.n_extensions)

  run.datetime = string(file.hst_date, file.hst_time, format='(%"%s.%s")')
  ucomp_read_raw_data, file.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine')

  for e = 0L, file.n_extensions - 1L do begin
    date_begin = ucomp_getpar(headers[e], 'DATE-BEG')
    times[e] = ucomp_dateobs2julday(date_begin)
  endfor

  times -= times[0]                ; convert absolute to offset
  times *= 24.0D * 60.0D * 60.0D   ; days to seconds

  diffs = times[1:*] - times[0:-2]

  max_ext_time = run->epoch('max_ext_time')
  !null = where(diffs gt max_ext_time, n_bad)

  return, n_bad gt 0L
end
