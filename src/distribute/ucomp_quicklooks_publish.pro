; docformat = 'rst'

;+
; Package and distribute quicklook images and movies to the appropriate
; locations.
;
; Note: all level 2 files are good to publish because they are only created from
; good level 1 files. Level 1 files must be checked individually to see if they
; passed GBU because we create level 1 files and then check them for GBU.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_quicklooks_publish, run=run
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
  ; and three types of movie files:
  ;   YYYYMMDD.ucomp.WWWW.l1.enhanced_intensity.mp4 (dynamics)
  ;   YYYYMMDD.ucomp.WWWW.l1.intensity.mp4 (dynamics)
  ;   YYYYMMDD.ucomp.WWWW.l1.iquv.mp4 (polarization)

  ; populate quicklook_files_list
  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    publish_l1 = run->config(wave_regions[w] + '/publish_l1')
    publish_type = run->config(wave_regions[w] + '/publish_type')
    mg_log, 'publishing %s nm data: %s (%s)', $
            wave_regions[w], publish_l1 ? 'L1 and L2' : 'L2', publish_type, $
            name=run.logger_name, /info

    wave_region_files = run->get_files(wave_region=wave_regions[w], $
                                       data_type='sci', $
                                       count=n_wave_region_files)

    switch strlowcase(publish_type) of
      'all': begin
          ; add polarization files
          if (publish_l1) then begin
            n_polarization_files = 0L
            l1_polarization_types = ['iquv.all.png', $
                                     'iquv.png']
            for f = 0L, n_wave_region_files - 1L do begin
              if (~wave_region_files[f].good) then continue
              basename = file_basename(wave_region_files[f].l1_basename, '.fts')
              for p = 0L, n_elements(l1_polarization_types) - 1L do begin
                png_filename = filepath(string(basename, l1_polarization_types[p], $
                                               format='%s.%s'), $
                                        root=l1_dir)
                if (file_test(png_filename, /regular)) then begin
                  quicklook_files_list->add, png_filename
                  n_polarization_files += 1L
                endif
              endfor
            endfor
            movie_filename = filepath(string(run.date, wave_regions[w], $
                                             format='%s.ucomp.%s.l1.iquv.mp4'), $
                                      root=l1_dir)
            if (file_test(movie_filename, /regular)) then begin
              quicklook_files_list->add, movie_filename
              n_polarization_files += 1L
            endif
            mg_log, 'publishing %d %s nm level 1 polarization quicklook files', $
                    n_polarization_files, wave_regions[w], $
                    name=run.logger_name, /info
          endif else begin
            mg_log, 'skipping publishing %s nm level 1 polarization files', $
                    wave_regions[w], $
                    name=run.logger_name, /info
          endelse

          l2_polarization_types = ['weighted_average_linear_polarization.png', $
                                   'weighted_average_linear_polarization.mp4', $
                                   'weighted_average_q.png', $
                                   'weighted_average_q.mp4', $
                                   'weighted_average_u.png', $
                                   'weighted_average_u.mp4']
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

            glob = string(wave_regions[w], l2_polarization_types[p], $
                          format='*.ucomp.%s.l2.{synoptic,waves}.{mean,median}.%s')
            files = file_search(filepath(glob, root=l2_dir), count=n_files)
            if (n_files gt 0L) then begin
              mg_log, 'publishing %d %s nm average %s files', $
                      n_files, wave_regions[w], l2_polarization_types[p], $
                      name=run.logger_name, /info
              quicklook_files_list->add, files, /extract
            endif
          endfor
        end
      'dynamics': begin
          ; add dynamics files
          if (publish_l1) then begin
            n_dynamics_files = 0L
            l1_dynamics_types = ['enhanced_intensity', $
                                 'intensity']
            for f = 0L, n_wave_region_files - 1L do begin
              if (~wave_region_files[f].good) then continue
              basename = file_basename(wave_region_files[f].l1_basename, '.fts')
              for d = 0L, n_elements(l1_dynamics_types) - 1L do begin
                gif_filename = filepath(string(basename, l1_dynamics_types[d], $
                                               format='%s.%s.gif'), $
                                        root=l1_dir)
                if (file_test(gif_filename, /regular)) then begin
                  quicklook_files_list->add, gif_filename
                  n_dynamics_files += 1L
                endif
              endfor
            endfor

            for d = 0L, n_elements(l1_dynamics_types) - 1L do begin
              movie_filename = filepath(string(run.date, wave_regions[w], l1_dynamics_types[d], $
                                               format='%s.ucomp.%s.l1.%s.mp4'), $
                                        root=l1_dir)
              if (file_test(movie_filename, /regular)) then begin
                quicklook_files_list->add, movie_filename
                n_dynamics_files += 1L
              endif
            endfor

            mg_log, 'publishing %d %s nm level 1 dynamics quicklook files', $
                    n_dynamics_files, wave_regions[w], $
                    name=run.logger_name, /info
          endif else begin
            mg_log, 'skipping publishing %s nm level 1 dynamics files', $
                    wave_regions[w], $
                    name=run.logger_name, /info
          endelse

          l2_dynamics_types = ['all.png', $
                               'center_intensity.png', $
                               'center_intensity.mp4', $
                               'enhanced_intensity.png', $
                               'enhanced_intensity.mp4', $
                               'peak_intensity.png', $
                               'peak_intensity.mp4', $
                               'line_width.png', $
                               'line_width.mp4', $
                               'los_velocity.png', $
                               'los_velocity.mp4', $
                               'weighted_average_azimuth.png', $
                               'weighted_average_azimuth.mp4', $
                               'weighted_average_intensity.png', $
                               'weighted_average_intensity.mp4', $
                               'weighted_average_radial_azimuth.png', $
                               'weighted_average_radial_azimuth.mp4']
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

            glob = string(wave_regions[w], l2_dynamics_types[d], $
                          format='*.ucomp.%s.l2.{synoptic,waves}.{mean,median,sigma}.%s')
            files = file_search(filepath(glob, root=l2_dir), count=n_files)
            if (n_files gt 0L) then begin
              mg_log, 'publishing %d %s nm average %s files', $
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
  composite_wave_regions = strarr(n_elements(rgb))
  n_published_temperature_maps = 0L
  for m = 0L, n_temperature_maps - 1L do begin
    publish = run->temperature_map_option(all_temperature_maps[m], 'publish') eq 'YES'
    if (publish) then begin
      for w = 0L, n_elements(rgb) - 1L do begin
        composite_wave_regions[w] = run->temperature_map_option(all_temperature_maps[m], rgb[w])
      endfor
      map_basename = string(run.date, composite_wave_regions, $
                            format='%s.ucomp.%s-%s-%s.daily_temperature.png')
      map_filename = filepath(map_basename, root=l2_dir)
      if (file_test(map_filename, /regular)) then begin
        quicklook_files_list->add, map_filename
        n_published_temperature_maps += 1L
      endif
    endif
  endfor
  if (n_published_temperature_maps gt 0L) then begin
    mg_log, 'publishing %d temperature maps', n_published_temperature_maps, $
            name=run.logger_name, /info
  endif

  ; add catalog, GBU, quality files and user guide

  citation_filename = filepath('UCOMP_CITATION.txt', $
                               subdir='docs', $
                               root=run.resource_root)
  quicklook_files_list->add, citation_filename

  userguide_version = run->epoch('doc_version')
  userguide_basename = string(userguide_version, $
                              format='ucomp-user-guide.v%s.pdf')
  userguide_filename = filepath(userguide_basename, $
                                root=run->config('documentation/docs_dir'))
  quicklook_files_list->add, userguide_filename

  catalog_filename = filepath(string(run.date, format='%s.ucomp.catalog.txt'), $
                              root=processing_dir)
  if (~file_test(catalog_filename, /regular)) then begin
    mg_log, 'no catalog file, skipping quicklooks publishing', $
            name=run.logger, /info
    goto, cleanup
  endif
  quicklook_files_list->add, catalog_filename

  for w = 0L, n_elements(wave_regions) - 1L do begin
    wave_region_catalog_filename = filepath(string(run.date, wave_regions[w], $
                                                   format='%s.ucomp.%s.files.txt'), $
                                            root=processing_dir)
    if (file_test(wave_region_catalog_filename, /regular)) then begin
      quicklook_files_list->add, wave_region_catalog_filename
    endif

    gbu_filename = filepath(string(run.date, wave_regions[w], $
                                   format='%s.ucomp.%s.gbu.log'), $
                            root=l1_dir)
    if (file_test(gbu_filename, /regular)) then begin
      quicklook_files_list->add, gbu_filename
    endif

    quality_filename = filepath(string(run.date, wave_regions[w], $
                                       format='%s.ucomp.%s.quality.log'), $
                                root=l1_dir)
    if (file_test(quality_filename, /regular)) then begin
      quicklook_files_list->add, quality_filename
    endif
  endfor

  n_quicklook_files = quicklook_files_list->count()
  quicklook_files = quicklook_files_list->toArray()

  if (n_quicklook_files eq 0L) then begin
    mg_log, 'no quicklook files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  ; copy individual files to fullres directory
  file_copy, quicklook_files, fullres_dir, /overwrite

  ; create gzip file
  gzip_basename = string(run.date, format='%s.ucomp.quicklooks.zip')
  gzip_filename = filepath(gzip_basename, root=processing_dir)
  mg_log, '%d files in %s', $
          n_quicklook_files, gzip_basename, $
          name=run.logger_name, /info
  file_zip, quicklook_files, gzip_filename
  ucomp_fix_permissions, gzip_filename, logger=run.logger_name

  gziplist_basename = string(run.date, format='%s.ucomp.quicklooks.ziplist.txt')
  gziplist_filename = filepath(gziplist_basename, root=processing_dir)
  openw, lun, gziplist_filename, /get_lun
  printf, lun, transpose(file_basename(quicklook_files))
  free_lun, lun
  ucomp_fix_permissions, gziplist_filename, logger=run.logger_name

  ; copy gzip file to fullres directory
  file_copy, gzip_filename, fullres_dir, /overwrite
  file_copy, gziplist_filename, fullres_dir, /overwrite

  cleanup:
  if (obj_valid(quicklook_files_list)) then obj_destroy, quicklook_files_list
end


; main-level example program

date = '20220901'
config_basename = 'ucomp.publish.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

processing_basedir = run->config('processing/basedir')

ucomp_quicklooks_publish, run=run

obj_destroy, run

end
