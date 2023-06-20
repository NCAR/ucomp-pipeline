; docformat = 'rst'

;+
; Wrapper routine to log, time, etc. each step of the L1 processing of a file.
;
; :Params:
;   routine_name : in, required, type=string
;     L1 step to apply
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, out, required, type="fltarr(nx, nx, nexts)"
;     extension data
;   headers : in, out, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : in, out, optional, type="fltarr(nx, ny, nexts)"
;     background data
;   background_headers : in, out, required, type=list
;     extension headers for background as list of `strarr`
;
; :Keywords:
;   step_number : in, required, type=long
;     set number in the level 1 processing for a file
;   skip : in, optional, type=boolean
;     set to skip routine
;   run : in, required, type=object
;     UCoMP run object
;   _extra : in, optional, type=keywords
;     keywords to pass along to `routine_name`
;-
pro ucomp_l1_step, routine_name, file, $
                   primary_header, $
                   data, headers, $
                   backgrounds, background_headers, $
                   step_number=step_number, skip=skip, run=run, _extra=e
  compile_opt strictarr
  on_error, 2

  if (keyword_set(skip)) then begin
    mg_log, 'skipping', from=routine_name, name=run.logger_name, /debug
  endif else begin
    mg_log, 'starting...', from=routine_name, name=run.logger_name, /debug

    clock_id = run->start(routine_name)
    call_procedure, routine_name, file, $
                    primary_header, $
                    data, headers, $
                    backgrounds, background_headers, $
                    run=run, status=status, _extra=e
    time = run->stop(clock_id)
    run->log_memory, routine_name

    ucomp_assert, n_elements(headers) eq file.n_extensions, $
                  'number of extensions inconsistent with headers: %d != %d', $
                  n_elements(headers), file.n_extensions, $
                  from=routine_name
    ucomp_assert, n_elements(file.wavelengths) eq file.n_extensions, $
                  'number of extensions inconsistent with wavelengths: %d != %d', $
                  n_elements(file.wavelengths), file.n_extensions, $
                  from=routine_name

    mg_log, /check_math, from=routine_name, name=run.logger_name, /debug

    if (status eq 0L) then begin
      name = strmid(routine_name, 9)
      ucomp_write_intermediate_file, name, file, primary_header, $
                                     data, headers, backgrounds, background_headers, $
                                     step_number=step_number, run=run
      ucomp_write_intermediate_image, name, file, primary_header, $
                                      data, headers, $
                                      step_number=step_number, run=run
    endif else begin
      message, string(routine_name, status, format='(%"%s failed with status %d")')
    endelse

    mg_log, 'done (%s)', ucomp_sec2str(time), $
            from=routine_name, name=run.logger_name, /debug
  endelse

  if (n_elements(step_number) gt 0L) then step_number += 1L
end
