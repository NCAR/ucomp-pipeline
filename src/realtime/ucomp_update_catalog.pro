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
;   n_extensions : in, required, type=lonarr
;     number of extensions of `new_files`
;   data_types : in, required, type=strarr
;     data types of `new_files`
;   exposure : in, required, type=fltarr
;     exposure time [ms]
;   wave_regions : in, required, type=strarr
;     wave regions of `new_files`
;   n_points : in, required, type=lonarr
;     number of unique wavelengths
;-
pro ucomp_update_catalog, catalog_filename, $
                          new_files, $
                          n_extensions, $
                          data_types, $
                          exposures, $
                          wave_regions, $
                          n_points


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
            n_extensions[f], $
            data_types[f], $
            exposures[f], $
            wave_regions[f], $
            n_points[f], $
            format='(%"%-40s %7d exts %7s %7.2f ms %7s nm %7d pts")'
  endfor

  free_lun, lun
end
