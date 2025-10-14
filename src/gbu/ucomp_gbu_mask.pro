; docformat = 'rst'

;+
; Determine the valid GBU checks after excluding the named checkers.
;
; :Params:
;   `bytarr(n_checkers)`
;
; :Params:
;   exclude_expression : in, required, type=string
;     expression specifying checkers to not use, i.e., `vcrosstalk|median_diff`
;     specifies to not use `ucomp_gbu_vcrosstalk` or the `ucomp_gbu_median_diff`
;     checkers
;   wave_region : in, required, type=string
;     wave region for the checks, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_gbu_mask, exclude_expression, wave_region, run=run
  compile_opt strictarr

  conditions = ucomp_gbu_conditions(wave_region, run=run)
  mask = bytarr(n_elements(conditions)) + 1B

  tokens = strsplit(exclude_expression, '|', /extract, count=n_tokens)

  for t = 0L, n_tokens - 1L do begin
    indices = where('ucomp_gbu_' + tokens[t] eq conditions.checker, /null)
    ; TODO: throw error if checker not found
    mask[indices] = 0B
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

print, strmid((ucomp_gbu_conditions(wave_region, run=run)).checker, 10)
print, ucomp_gbu_mask('vcrosstalk|median_diff', wave_region, run=run)

obj_destroy, run

end
