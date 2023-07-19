; docformat = 'rst'

;+
; Check whether any extensions have a datatype that does not match the others.
;
; :Returns:
;   1B if any extensions don't have a matching datatype
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
function ucomp_quality_all_zero, file, $
                                 primary_header, $
                                 ext_data, $
                                 ext_headers, $
                                 run=run
  compile_opt strictarr

  return, ulong(file.all_zero)
end


; main-level example

date = '20210810'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

raw_basename = '20210810.181351.97.ucomp.656.l0.fts'
raw_filename = filepath(raw_basename, $
                        subdir=[date], $
                        root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)

ucomp_read_raw_data, file.raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     repair_routine=run->epoch('raw_data_repair_routine')

success = ucomp_quality_datatype(file, $
                                 primary_header, $
                                 ext_data, $
                                 ext_headers, $
                                 run=run)
help, success

obj_destroy, file
obj_destroy, run

end
