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
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_check_identical_temps, file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              backgrounds, $
                                              run=run
  compile_opt strictarr

  tolerance = 0.0001

  return, (~finite(file.tu_lcvr1 - file.tu_lcvr2)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr2) lt tolerance) $
            || (~finite(file.tu_lcvr1 - file.tu_lcvr3)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr3) lt tolerance) $
            || (~finite(file.tu_lcvr1 - file.tu_lcvr4)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr4) lt tolerance) $
            || (~finite(file.tu_lcvr1 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr1 - file.tu_lcvr5) lt tolerance) $
            || (~finite(file.tu_lcvr2 - file.tu_lcvr3)) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr3) lt tolerance) $
            || (~finite(file.tu_lcvr2 - file.tu_lcvr4)) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr4) lt tolerance) $
            || (~finite(file.tu_lcvr2 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr2 - file.tu_lcvr5) lt tolerance) $
            || (~finite(file.tu_lcvr3 - file.tu_lcvr4)) $
            || (abs(file.tu_lcvr3 - file.tu_lcvr4) lt tolerance) $
            || (~finite(file.tu_lcvr3 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr3 - file.tu_lcvr5) lt tolerance) $
            || (~finite(file.tu_lcvr4 - file.tu_lcvr5)) $
            || (abs(file.tu_lcvr4 - file.tu_lcvr5) lt tolerance)
end


; main-level example program

;date = '20210620'
;date = '20210614'
date = '20211107'
;raw_basename = '20210620.202929.96.ucomp.1074.l0.fts'
;raw_basename = '20210615.011912.16.ucomp.1074.l0.fts'
raw_basename = '20211107.192028.35.ucomp.1074.l0.fts'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())

print, config_filename
run = ucomp_run(date, 'test', config_filename)

raw_filename = filepath(raw_basename, subdir=date, root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)

file.quality = ucomp_quality_check_identical_temps(file)
print, file.gbu, format='(%"Quality: %d")'

obj_destroy, run

end
