; docformat = 'rst'

;+
; Add files to catalog file. Creates catalog file (and containing directories)
; if needed.
;
; :Params:
;   catalog_filename : in, required, type=string
;     filename of catalog file
;   new_files : in, required, type=strarr or !null
;     files to add to catalog file
;   data_types : in, required, type=strarr
;     data types of `new_files`
;   wave_regions : in, required, type=strarr
;     wave regions of `new_files`
;   n_extensions : in, required, type=lonarr
;     number of extensions of `new_files`
;   exposure : in, required, type=fltarr
;     exposure time [ms]
;-
pro ucomp_update_catalog, catalog_filename, $
                          new_files, $
                          data_types, $
                          wave_regions, $
                          n_extensions, $
                          exposures
  compile_opt strictarr

  if (n_elements(new_files) eq 0L) then return

  if (~file_test(catalog_filename, /regular)) then begin
    dir = file_dirname(catalog_filename)
    if (~file_test(dir, /directory)) then file_mkdir, dir
    openw, lun, catalog_filename, /get_lun
  endif else begin
    openu, lun, catalog_filename, /get_lun, /append
  endelse

  for f = 0L, n_elements(new_files) - 1L do begin
    printf, lun, $
            file_basename(new_files[f]), $
            data_types[f], wave_regions[f], exposures[f], n_extensions[f], $
            format='(%"%-40s %7s %7s nm %7.2f ms %7d exts")'
  endfor

  free_lun, lun
end
