; docformat = 'rst'

;+
; Check the various conditions for the GBU.
;
; After UCOMP_L1_CHECK_GBU, the `gbu` field of the file should be set to the
; correct GBU status for the file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_check_gbu, file, $
                        primary_header, $
                        ext_data, ext_headers, $
                        backgrounds, background_headers, $
                        run=run, status=status
  compile_opt strictarr

  status = 0L

  mask = ucomp_gbu_mask(run->config('gbu/mask'), file.wave_region, run=run) $
           and ucomp_gbu_mask(run->epoch('gbu_mask'), file.wave_region, run=run)

  gbu_conditions = ucomp_gbu_conditions(wave_region, run=run)
  for g = 0L, n_elements(gbu_conditions) - 1L do begin
    run.datetime = string(file.ut_date, file.ut_time, format='%s.%s')
    if (mask[g]) then begin
      gbu = call_function(gbu_conditions[g].checker, $
                          file, $
                          primary_header, $
                          ext_data, $
                          ext_headers, $
                          backgrounds, $
                          background_headers, $
                          run=run)
      mg_log, '%s GBU condition: %d', gbu_conditions[g].checker, gbu, $
              name=run.logger_name, /debug
    endif else gbu = 0UL
    file.gbu = gbu_conditions[g].mask * gbu
  endfor

  if (file.gbu ne 0) then begin
    bad_conditions = ucomp_list_conditions(file.gbu, gbu_conditions)
    mg_log, 'failed %s', bad_conditions, name=run.logger_name, /warn
  endif

  done:
end
