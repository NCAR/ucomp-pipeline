; docformat = 'rst'

;+
; Copy the observer log to the top-level of the process directory.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_get_observerlog, run=run
  compile_opt strictarr

  olog_basedir = run->config('observerlogs/basedir')
  if (n_elements(olog_basedir) eq 0L) then begin
    mg_log, 'no observer log basedir set, skipping', name=run.logger_name, /info
    goto, done
  endif

  d = long(ucomp_decompose_date(run.date))
  year = d[0]
  doy = mg_ymd2doy(d[0], d[1], d[2])

  olog_filename = filepath(string(year, doy, format='(%"mlso.%04dd%03d.olog")'), $
                           subdir=strtrim(year, 2), $
                           root=olog_basedir)

  if (file_test(olog_filename, /regular)) then begin
    process_dir = filepath('', $
                           subdir=run.date, $
                           root=run->config('processing/basedir'))
    file_copy, olog_filename, process_dir, /overwrite
  endif else begin
    mg_log, 'observer log not present', name=run.logger_name, /warn
  endelse

  done:
end
