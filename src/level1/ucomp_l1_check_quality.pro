; docformat = 'rst'

;+
; Check quality (process or not) for each file.
;
; After `UCOMP_L1_CHECK_QUALITY`, the `ok` and `quality_bitmask` fields of the
; `file` will be set correctly.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : type=undefined
;     not used in this step
;   background_headers : in, required, type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_check_quality, file, $
                            primary_header, $
                            ext_data, ext_headers, $
                            backgrounds, background_headers, $
                            run=run, status=status
  compile_opt strictarr

  status = 0L

  quality_conditions = ucomp_quality_conditions(file.wave_region, run=run)
  for q = 0L, n_elements(quality_conditions) - 1L do begin
    if (((2UL^q and run->config('quality/mask')) ne 0) $
          && ((2UL^q and run->epoch('quality_mask')) ne 0)) then begin
      run.datetime = string(file.ut_date, file.ut_time, format='%s.%s')
      quality = call_function(quality_conditions[q].checker, $
                              file, $
                              primary_header, $
                              ext_data, $
                              ext_headers, $
                              run=run)
    endif else quality = 0UL
    file.quality_bitmask = quality_conditions[q].mask * quality
  endfor

  done:
end
