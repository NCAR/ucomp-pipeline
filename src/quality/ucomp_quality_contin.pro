; docformat = 'rst'

;+
; Check whether all extensions have the same CONTIN value.
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
function ucomp_quality_contin, file, $
                               primary_header, $
                               ext_data, $
                               ext_headers, $
                               run=run
  compile_opt strictarr

  contin = ''
  for e = 0L, n_elements(ext_headers) - 1L do begin
    new_contin = sxpar(ext_headers[e], 'CONTIN')
    if (contin eq '') then contin = new_contin else begin
      if (contin ne new_contin) then begin
        mg_log, 'ext %d: %s != %s', e + 1, contin, new_contin, $
                name=run.logger_name, /warn
        return, 1UL
      endif
    endelse
  endfor

  return, 0UL
end


; main-level example program

date = '20210715'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

;raw_basename = '20210715.190726.38.ucomp.1074.l0.fts'
raw_basename = '20210715.190248.46.ucomp.789.l0.fts'
raw_basedir = run->config('raw/basedir')
raw_filename = filepath(raw_basename, subdir=date, root=raw_basedir)

ucomp_read_raw_data, raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     n_extensions=n_extensions, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     badframes=run.badframes, $
                     metadata_fixes=run.metadata_fixes, $
                     use_occulter_id=run->epoch('use_occulter_id'), $
                     occulter_id=run->epoch('occulter_id'), $
                     all_zero=all_zero


file = ucomp_file(raw_filename, run=run)
run.datetime = strmid(file_basename(raw_filename), 0, 15)

quality = ucomp_quality_contin(file, $
                               primary_header, $
                               ext_data, $
                               ext_headers, $
                               run=run)

obj_destroy, [file, run]

end
