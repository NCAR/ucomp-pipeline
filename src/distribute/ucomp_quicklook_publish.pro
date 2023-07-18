; docformat = 'rst'

;+
; Package and distribute quicklook images and movies to the appropriate
; locations.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_quicklook_publish, run=run
  compile_opt strictarr

  fullres_basedir = run->config('results/fullres_basedir')
  if (n_elements(fullres_basedir) eq 0L) then begin
    mg_log, 'skipping quicklook distribution', name=run.logger_name, /info
    goto, cleanup
  endif

  fullres_dir = filepath('', $
                         subdir=ucomp_decompose_date(run.date), $
                         root=fullres_basedir)
  ucomp_mkdir, fullres_dir, logger_name=run.logger_name

  processing_dir = filepath(run.date, root=run->config('processing/basedir'))

  ; make list of files to distribute
  quicklook_files_list = list()

  l1_dir = filepath('', subdir='level1', root=processing_dir)
  l2_dir = filepath('', subdir='level2', root=processing_dir)

  ; The four types of level 1 image files:
  ;   YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.enhanced_intensity.gif (dynamics)
  ;   YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.intensity.gif (dynamics)
  ;   YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.iquv.all.png (polarization)
  ;   YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.iquv.png (polarization)
  ; and two types of movie files:
  ;   YYYYMMDD.ucomp.WWWW.l1.N.enhanced_intensity.mp4 (dynamics)
  ;   YYYYMMDD.ucomp.WWWW.l1.N.intensity.mp4 (dynamics)
  ;   YYYYMMDD.ucomp.WWWW.l1.N.iquv.mp4 (polarization)

  ; populate quicklook_files_list
  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    publish_l1 = run->config(wave_regions[w] + '/publish_l1')
    publish_type = run->config(wave_regions[w] + '/publish_type')
    mg_log, 'publishing %s nm data: %s (%s)', $
            wave_regions[w], publish_l1 ? 'L1 and L2' : 'L2', publish_type, $
            name=run.logger_name, /info
    switch strlowcase(publish_type) of
      'all': begin
          ; add polarization files
          if (publish_l1) then begin
            l1_polarization_types = ['*.iquv.all.png', $
                                     '*.iquv.png', $
                                     'iquv.mp4']
            for p = 0L, n_elements(l1_polarization_types) - 1L do begin
              glob = string(wave_regions[w], l1_polarization_types[p], $
                            format='*.ucomp.%s.l1.%s')
              files = file_search(filepath(glob, root=l1_dir), count=n_files)
              if (n_files gt 0L) then begin
                mg_log, 'publishing %d %s nm %s files', $
                        n_files, wave_regions[w], l1_polarization_types[p], $
                        name=run.logger_name, /info
                quicklook_files_list->add, files, /extract
              endif
            endfor
          endif else begin
            mg_log, 'skipping publishing %s nm level 1 polarization files', $
                    wave_regions[w], $
                    name=run.logger_name, /info
          endelse

          l2_polarization_types = ['linear_polarization.png', $
                                   'linear_polarization.mp4', $
                                   'polarization.png', $
                                   '*.quick_invert.png', $
                                   '*.quick_invert.stokesq.png', $
                                   '*.quick_invert.stokesu.png', $
                                   '*.quick_invert.linear_polarization.png', $
                                   '*.quick_invert.azimuth.png', $
                                   '*.quick_invert.radial_azimuth.png', $
                                   'radial_azimuth.png', $
                                   'radial_azimuth.mp4']
          for p = 0L, n_elements(l2_polarization_types) - 1L do begin
            glob = string(wave_regions[w], l2_polarization_types[p], $
                          format='*.ucomp.%s.l2.%s')
            files = file_search(filepath(glob, root=l2_dir), count=n_files)
            if (n_files gt 0L) then begin
              mg_log, 'publishing %d %s nm %s files', $
                      n_files, wave_regions[w], l2_polarization_types[p], $
                      name=run.logger_name, /info
              quicklook_files_list->add, files, /extract
            endif
          endfor
        end
      'dynamics': begin
          ; add dynamics files
          if (publish_l1) then begin
            l1_dynamics_types = ['*.enhanced_intensity.gif', $
                                 'enhanced_intensity.mp4', $
                                 '*.intensity.gif', $
                                 'intensity.mp4']
            for d = 0L, n_elements(l1_dynamics_types) - 1L do begin
              glob = string(wave_regions[w], l1_dynamics_types[d], $
                            format='*.ucomp.%s.l1.%s')
              files = file_search(filepath(glob, root=l1_dir), count=n_files)
              if (n_files gt 0L) then begin
                mg_log, 'publishing %d %s nm %s files', $
                        n_files, wave_regions[w], l1_dynamics_types[d], $
                        name=run.logger_name, /info
                quicklook_files_list->add, files, /extract
              endif
            endfor
          endif else begin
            mg_log, 'skipping publishing %s nm level 1 dynamics files', $
                    wave_regions[w], $
                    name=run.logger_name, /info
          endelse

          l2_dynamics_types = ['dynamics.png', $
                               'line_width.png', $
                               'line_width.mp4', $
                               '*.quick_invert.intensity.png', $
                               '*.quick_invert.line_width.png', $
                               '*.quick_invert.velocity.png', $
                               'velocity.png', $
                               'velocity.mp4']
          for d = 0L, n_elements(l2_dynamics_types) - 1L do begin
            glob = string(wave_regions[w], l2_dynamics_types[d], $
                          format='*.ucomp.%s.l2.%s')
            files = file_search(filepath(glob, root=l2_dir), count=n_files)
            if (n_files gt 0L) then begin
              mg_log, 'publishing %d %s nm %s files', $
                      n_files, wave_regions[w], l2_dynamics_types[d], $
                      name=run.logger_name, /info
              quicklook_files_list->add, files, /extract
            endif
          endfor
        end
      else:
    endswitch
  endfor

  ; publish temperature map images

  rgb = ['red', 'green', 'blue']
  all_temperature_maps = run->all_temperature_maps(count=n_temperature_maps)
  wave_regions = strarr(3)
  n_published_temperature_maps = 0L
  for m = 0L, n_temperature_maps - 1L do begin
    publish = run->temperature_map_option(all_temperature_maps[m], 'publish')
    if (publish) then begin
      for w = 0L, n_elements(wave_regions) - 1L do begin
        wave_regions[w] = run->temperature_map_option(all_temperature_maps[m], rgb[w])
      endfor
      map_basename = string(run.date, wave_regions, $
                            format='%s.ucomp.%s-%s-%s.daily_temperature.png')
      map_filename = filepath(output_basename, $
                              subdir=[run.date, 'level2'], $
                              root=run->config('processing/basedir'))
      quicklook_files_list->add, map_filename
      n_published_temperature_maps += 1L
    endif
  endfor
  if (n_published_temperature_maps gt 0L) then begin
    mg_log, 'publishing %d temperature maps', n_published_temperature_maps, $
            name=run.logger_name, /info
  endif

  n_quicklook_files = quicklook_files_list->count()
  quicklook_files = quicklook_files_list->toArray()
  obj_destroy, quicklook_files_list

  if (n_quicklook_files eq 0L) then begin
    mg_log, 'no quicklook files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  ; copy individual files to fullres directory
  file_copy, quicklook_files, fullres_dir, /overwrite

  ; create gzip file
  gzip_basename = string(run.date, format='%s.ucomp.quicklooks.zip')
  gzip_filename = filepath(gzip_basename, $
                           root=processing_dir)
  mg_log, '%d files in %s', $
          n_quicklook_files, gzip_basename, $
          name=run.logger_name, /info
  file_zip, quicklook_files, gzip_filename

  ; copy gzip file to fullres directory
  file_copy, gzip_filename, fullres_dir, /overwrite

  cleanup:
end


; main-level example program

date = '20220901'
config_basename = 'ucomp.publish.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

processing_basedir = run->config('processing/basedir')
print, processing_basedir
;ucomp_quicklook_publish, run=run

obj_destroy, run

end
