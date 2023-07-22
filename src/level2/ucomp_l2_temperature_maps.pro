; docformat = 'rst'

;+
; Create the temperature maps.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_temperature_maps, run=run
  compile_opt strictarr

  method = 'median'

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))

  all_temperature_maps = run->all_temperature_maps(count=n_temperature_maps)
  wave_regions = strarr(3)
  rgb = ['red', 'green', 'blue']
  mean_filenames = strarr(3)
  for m = 0L, n_temperature_maps - 1L do begin
    for w = 0L, n_elements(rgb) - 1L do begin
      wave_regions[w] = run->temperature_map_option(all_temperature_maps[m], rgb[w])
    endfor

    mg_log, 'creating %s nm-%s nm-%s nm temperature map...', wave_regions, $
            name=run.logger_name, /info

    valid_map = 1B
    for w = 0L, n_elements(rgb) - 1L do begin
      program_names = run->get_programs(wave_regions[w], count=n_programs)
      if (n_programs eq 0L) then begin
        mg_log, 'no programs for %s nm, skipping this temperature map', wave_regions[w], $
                name=run.logger_name, /warn
        valid_map = 0B
        break
      endif

      p = 0L
      program_filename = run->convert_program_name(program_names[p])

      mean_basename = string(run.date, wave_regions[w], program_filename, method, $
                             format='(%"%s.ucomp.%s.l2.%s.%s.fts")')
      mean_filename = filepath(mean_basename, root=l2_dir)
      mean_filenames[w] = mean_filename
      mg_log, '%s [%s]: %s', rgb[w], wave_regions[w], file_basename(mean_filename), $
              name=run.logger_name, /debug
    endfor

    if (~valid_map) then continue

    ucomp_write_composite_image, mean_filenames, run=run
  endfor
end
