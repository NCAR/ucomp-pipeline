; docformat = 'rst'

;+
; Check whether any two of T_LCVR{1,2,3,4,5} are equal.
;
; :Returns:
;   1B if any two of T_LCVR{1,2,3,4,5} are equal for the file
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;-
function ucomp_gbu_check_identical_temps, file
  compile_opt strictarr

  tolerance = 0.001

  return, (abs(file.tu_lcvr1 - file.tu_lcvr2) lt tolerance) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr3) lt tolerance) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr4) lt tolerance) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr5) lt tolerance) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr3) lt tolerance) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr4) lt tolerance) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr5) lt tolerance) $
            || (abs(file.tu_lcvr3 - file.tu_lcvr4) lt tolerance) $
            || (abs(file.tu_lcvr3 - file.tu_lcvr5) lt tolerance) $
            || (abs(file.tu_lcvr4 - file.tu_lcvr5) lt tolerance)
end


; main-level example program

;date = '20210620'
date = '20210614'
;raw_basename = '20210620.202929.96.ucomp.1074.l0.fts'
raw_basename = '20210615.011912.16.ucomp.1074.l0.fts'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())

print, config_filename
run = ucomp_run(date, 'test', config_filename)

raw_filename = filepath(raw_basename, subdir=date, root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)

is_bad = ucomp_gbu_check_identical_temps(file)
help, is_bad

obj_destroy, run

end
