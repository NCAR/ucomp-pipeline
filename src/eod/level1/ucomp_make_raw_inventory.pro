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

  ; do the inventory
  run->make_raw_inventory

  ; write the inventory files
  process_dir = filepath(run.date, $
                         root=run->config('processing/basedir'))
  if (~file_test(process_dir, /directory)) then begin
    file_mkdir, process_dir
    ucomp_fix_permissions, process_dir, /directory, logger_name=run.logger_name
  endif

  run->getProperty, all_wave_types=all_wave_types
  for w = 0L, n_elements(all_wave_types) - 1L do begin
    run->getProperty, files=files, wave_type=all_wave_types[w], count=n_files

    basename = string(run.date, all_wave_types[w], format='(%"%d.ucomp.%s.files.txt")')
    filename = filepath(basename, root=process_dir)

    openw, lun, filename, /get_lun
    for f = 0L, n_files - 1L do begin
      printf, lun, $
              file_basename(files[f].raw_filename), $
              files[f].data_type, $
              files[f].n_extensions, $
              strjoin(string(files[f].wavelengths, format='(F0.2)'), ' '), $
              format='(%"%-30s %-3s %3d %s")'
    endfor
    free_lun, lun
  endfor

  data_types = ['cal', 'eng', 'unk']
  for t = 0L, n_elements(data_types) - 1L do begin
    run->getProperty, files=files, data_type=data_types[t], count=n_files

    basename = string(run.date, data_types[t], format='(%"%d.ucomp.%s.files.txt")')
    filename = filepath(basename, root=process_dir)

    openw, lun, filename, /get_lun
    for f = 0L, n_files - 1L do begin
      printf, lun, $
              file_basename(files[f].raw_filename), $
              files[f].data_type, $
              files[f].n_extensions, $
              strjoin(string(files[f].wavelengths, format='(F0.2)'), ' '), $
              format='(%"%-30s %-3s %3d %s")'
    endfor
    free_lun, lun
  endfor
end
