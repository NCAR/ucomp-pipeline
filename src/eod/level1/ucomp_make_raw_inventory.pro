; docformat = 'rst'

;+
; Create an inventory of the raw files for a run.
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_make_raw_inventory, run=run
  compile_opt strictarr

  process_dir = filepath(run.date, $
                         root=run->config('processing/basedir'))
  if (~file_test(process_dir, /directory)) then begin
    file_mkdir, process_dir
    ucomp_fix_permissions, process_dir, /directory, logger_name=run.logger_name
  endif

  ; do the inventory
  run->make_raw_inventory, n_extensions=n_extensions, $
                           data_types=data_types, $
                           exposures=exposures, $
                           gain_modes=gain_modes, $
                           wave_regions=wave_regions, $
                           n_points=n_points

  ; make a new catalog file
  catalog_filename = filepath(string(run.date, format='(%"%s.ucomp.catalog.txt")'), $
                              root=process_dir)

  l0_dir = filepath(run.date, root=run->config('raw/basedir'))
  new_filenames = ucomp_new_files(l0_dir, catalog_filename, $
                                  count=n_new_files, error=error)

  ucomp_update_catalog, catalog_filename, $
                        new_filenames, $
                        n_extensions, $
                        data_types, $
                        exposures, $
                        gain_modes, $
                        wave_regions, $
                        n_points

  ; write the inventory files
  run->getProperty, all_wave_regions=all_wave_regions
  for w = 0L, n_elements(all_wave_regions) - 1L do begin
    files = run->get_files(data_type='sci', wave_region=all_wave_regions[w], $
                           count=n_files)

    basename = string(run.date, all_wave_regions[w], format='(%"%d.ucomp.%s.files.txt")')
    filename = filepath(basename, root=process_dir)

    if (n_files eq 0L) then continue

    openw, lun, filename, /get_lun
    for f = 0L, n_files - 1L do begin
      printf, lun, $
              file_basename(files[f].raw_filename), $
              files[f].n_extensions, $
              files[f].data_type, $
              strjoin(string(files[f].unique_wavelengths, format='(F0.2)'), ', '), $
              format='(%"%-40s %4d exts %6s  %s")'
    endfor
    free_lun, lun
  endfor

  data_types = ['cal', 'flat', 'dark', 'eng', 'unk']
  for t = 0L, n_elements(data_types) - 1L do begin
    files = run->get_files(data_type=data_types[t], count=n_files)

    basename = string(run.date, data_types[t], format='(%"%d.ucomp.%s.files.txt")')
    filename = filepath(basename, root=process_dir)

    if (n_files eq 0L) then continue

    openw, lun, filename, /get_lun
    for f = 0L, n_files - 1L do begin
      printf, lun, $
              file_basename(files[f].raw_filename), $
              files[f].n_extensions, $
              files[f].data_type, $
              strjoin(string(files[f].unique_wavelengths, format='(F0.2)'), ', '), $
              format='(%"%-40s %4d exts %6s  %s")'
    endfor
    free_lun, lun
  endfor
end
