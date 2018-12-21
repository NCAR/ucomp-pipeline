; docformat = 'rst'

;+
; Add files to catalog file. Creates catalog file (and containing directories)
; if needed.
;
; :Params:
;   new_files : in, required, type=strarr or !null
;     files to add to catalog file
;   catalog_filename : in, required, type=string
;     filename of catalog file
;-
pro ucomp_update_catalog, new_files, catalog_filename
  compile_opt strictarr

  if (n_elements(new_files) eq 0L) then return

  if (~file_test(catalog_filename, /regular)) then begin
    dir = file_dirname(catalog_filename)
    if (~file_test(dir, /directory)) then file_mkdir, dir
    openw, lun, catalog_filename, /get_lun
  endif else begin
    openu, lun, catalog_filename, /get_lun, /append
  endelse

  printf, lun, transpose([file_basename(new_files)])

  free_lun, lun
end
