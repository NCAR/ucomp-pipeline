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
;   exptimes : in, required, type=fltarr
;     exposure time [ms]
;   gain_modes : in, required, type=strarr
;     gain modes, e.g., "high" or "low"
;   wave_regions : in, required, type=strarr
;     wave regions of `new_files`
;   n_points : in, required, type=lonarr
;     number of unique wavelengths
;   numsum : in, required, type=lonarr
;     `NUMSUM` value for each file
;-
pro ucomp_update_catalog, catalog_filename, $
                          new_files, $
                          n_extensions, $
                          data_types, $
                          exptimes, $
                          gain_modes, $
                          wave_regions, $
                          n_points, $
                          numsum
  compile_opt strictarr

  if (n_elements(new_files) eq 0L) then return

  if (~file_test(catalog_filename, /regular)) then begin
    dir = file_dirname(catalog_filename)
    ucomp_mkdir, dir, logger_name=logger_name
    openw, lun, catalog_filename, /get_lun
  endif else begin
    openu, lun, catalog_filename, /get_lun, /append
  endelse

  wave_regions += ' nm'
  dark_indices = where(data_types eq 'dark', n_darks, /null)
  wave_regions[dark_indices] = '--'

  for f = 0L, n_elements(new_files) - 1L do begin
    printf, lun, $
            file_basename(new_files[f]), $
            n_extensions[f], $
            numsum[f], $
            data_types[f], $
            exptimes[f], $
            gain_modes[f], $
            wave_regions[f], $
            n_points[f], $
            format='(%"%-38s %4d exts %3d %-5s %6.2f ms %4s %8s %2d pts")'
  endfor

  free_lun, lun
end
