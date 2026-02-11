; docformat = 'rst'

;+
; Determine the valid quality checks after excluding the named checkers.
;
; :Params:
;   `bytarr(n_checkers)`
;
; :Params:
;   exclude_expression : in, required, type=string
;     expression specifying checkers to not use, i.e., `datatype|all_zero`
;     specifies to not use `ucomp_quality_datatype` or the
;     `ucomp_quality_all_zero` checkers
;   wave_region : in, required, type=string
;     wave region for the checks, i.e., '1074'
;
; :Keywords:
;   calibration : in, optional, type=boolean
;     set to use calibration quality checks instead of the science quality
;     checks
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_quality_mask, exclude_expression, wave_region, $
                             calibration=calibration, run=run
  compile_opt strictarr
  on_error, 2

  if (keyword_set(calibration)) then begin
    conditions = ucomp_cal_quality_conditions(wave_region, run=run)
  endif else begin
    conditions = ucomp_quality_conditions(wave_region, run=run)
  endelse
  mask = bytarr(n_elements(conditions)) + 1B

  tokens = strsplit(exclude_expression, '|', /extract, count=n_tokens)

  for t = 0L, n_tokens - 1L do begin
    condition_indices = where('ucomp_quality_' + tokens[t] eq conditions.checker, $
                              n_conditions)
    if (n_conditions eq 0L) then begin
      message, string(tokens[t], format='ucomp_quality_%s condition not found')
    endif else begin
      mask[condition_indices] = 0B
    endelse
  endfor

  return, mask
end


; main-level example program

date = '20221101'
wave_region = '1074'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

mask = ucomp_quality_mask(run->config('quality/mask'), wave_region, run=run) $
         and ucomp_quality_mask(run->epoch('quality_mask'), wave_region, run=run)

print, strmid((ucomp_quality_conditions(wave_region, run=run)).checker, 14)
print, ucomp_quality_mask('datatype|all_zero', wave_region, run=run)
print, ucomp_quality_mask('', wave_region, run=run)

obj_destroy, run

end
