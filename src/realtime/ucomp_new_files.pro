; docformat = 'rst'

;+
; Given a directory where new .fts.gz files are appearing and the filename of a
; catalog of the already existing files, determine the new files since the
; catalog was created.
;
; :Returns:
;   `strarr` or `!null` if no new files
;
; :Params:
;   dir : in, required, type=string
;     directory to check
;   catalog_filename : in, required, type=string
;     filename of catalog file which lists the previously existing files, one
;     per line
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of files returned
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status, 0 indicates no error
;-
function ucomp_new_files, dir, catalog_filename, count=count, error=error
  compile_opt strictarr

  error = 0L
  count = 0L

  ; read catalog
  if (~file_test(catalog_filename)) then begin
    error = 1L
    n_existing_files = 0L
    existing_files = !null
  endif else begin
    n_existing_files = file_lines(catalog_filename)
    if (n_existing_files eq 0L) then begin
      existing_files = !null
    endif else begin
      existing_files = strarr(n_existing_files)
      openr, lun, catalog_filename, /get_lun
      readf, lun, existing_files
      for f = 0L, n_existing_files - 1L do begin
        existing_files[f] = (strsplit(existing_files[f], /extract))[0]
      endfor
      free_lun, lun
    endelse
  endelse

  ; search dir for matching files
  all_files = file_search(filepath('*.fts{,.gz}', root=dir), count=n_all_files)
  if (n_all_files eq 0L) then begin
    all_files = !null
  endif else begin
    all_files = file_basename(all_files)
    all_files = all_files[sort(all_files)]
  endelse

  ; normal case when starting the day until some files have been cataloged
  if (n_existing_files eq 0L) then begin
    count = n_all_files
    return, all_files
  endif

  ; this case should not happen unless something is taking files out of the raw
  ; directory
  if (n_all_files eq 0L) then begin
    ;error = 2L
    error = 0L
    return, !null
  endif

  ; normal no new files case
  if (existing_files[-1] eq all_files[-1]) then begin
    return, !null
  endif

  ; normal new files case
  if (existing_files[-1] lt all_files[-1]) then begin
    last_catalog = where(all_files eq existing_files[-1], n_last_catalog)
    count = n_all_files - last_catalog[0] - 1L
    return, all_files[last_catalog[0] + 1:*]
  endif

  ; this case should not happen unless something is taking files out of the raw
  ; directory
  if (existing_files[-1] gt all_files[-1]) then begin
    error = 3L
    return, !null
  endif

  ; should never get here
  error = 4L
  return, !null
end
