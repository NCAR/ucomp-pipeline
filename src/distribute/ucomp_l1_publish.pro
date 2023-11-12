; docformat = 'rst'

;+
; Package and distribute level 1 products to the appropriate locations.
; Create YYYYMMDD.ucomp.l1.tar.gz and its list file. Copy them to the web
; archive directory.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_publish, run=run
  compile_opt strictarr

  web_basedir = run->config('results/web_basedir')
  distribute_fits = n_elements(web_basedir) gt 0L
  if (distribute_fits) then begin
    web_dir = filepath('', $
                       subdir=ucomp_decompose_date(run.date), $
                       root=web_basedir)
    ucomp_mkdir, web_dir, logger_name=run.logger_name
  endif else begin
    mg_log, 'skipping publishing L1 data', name=run.logger, /info
    goto, cleanup
  endelse

  processing_dir = filepath(run.date, root=run->config('processing/basedir'))
  l1_dir = filepath('', subdir='level1', root=processing_dir)
  l2_dir = filepath('', subdir='level2', root=processing_dir)

  files_list = list()
  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    publish_type = run->config(wave_regions[w] + '/publish_type')
    if (publish_type eq 'none' || ~run->config(wave_regions[w] + '/publish_l1')) then begin
      mg_log, 'skipping publishing %s nm L1 data', wave_regions[w], $
              name=run.logger, /info
      continue
    endif

    ; The types of level 1 FITS files:
    ;   level1/YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.fts
    ;   level1/YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.intensity.fts
    ;   level2/YYYYMMDD.ucomp.WWWW.l1.{synoptic,waves}.{mean,median}.fts

    files = run->get_files(wave_region=wave_regions[w], count=n_files)
    for f = 0L, n_files - 1L do begin
      if (files[f].wrote_l1) then begin
        files_list->add, filepath(files[f].l1_basename, root=l1_dir)
        files_list->add, filepath(files[f].l1_intensity_basename, root=l1_dir)
      endif
    endfor

    average_format = '%s.ucomp.%s.l1.{synoptic,waves}.{mean,median}.fts'
    average_filenames = file_search(filepath(string(run.date, wave_regions[w], $
                                                    format=average_format), $
                                             root=l2_dir), $
                                    count=n_average_files)
    if (n_average_files gt 0L) then begin
      files_list->add, average_filenames, /extract
    endif
  endfor

  ; add catalog, GBU, quality files and user guide

  citation_filename = filepath('UCOMP_CITATION.txt', $
                               subdir='docs', $
                               root=run.resource_root)
  files_list->add, citation_filename

  userguide_filename = filepath('ucomp-user-guide.v1.0.pdf', $
                                subdir='docs', $
                                root=run.resource_root)
  files_list->add, userguide_filename

  catalog_filename = filepath(string(run.date, format='%s.ucomp.catalog.txt'), $
                              root=processing_dir)
  if (~file_test(catalog_filename, /regular)) then begin
    mg_log, 'no catalog file, skipping L1 publishing', $
            name=run.logger, /info
    goto, cleanup
  endif
  files_list->add, catalog_filename

  for w = 0L, n_elements(wave_regions) - 1L do begin
    wave_region_catalog_filename = filepath(string(run.date, wave_regions[w], $
                                                   format='%s.ucomp.%s.files.txt'), $
                                            root=processing_dir)
    if (file_test(wave_region_catalog_filename, /regular)) then begin
      files_list->add, wave_region_catalog_filename
    end

    gbu_filename = filepath(string(run.date, wave_regions[w], $
                                   format='%s.ucomp.%s.gbu.log'), $
                            root=l1_dir)
    if (file_test(gbu_filename, /regular)) then begin
      files_list->add, gbu_filename
    endif

    quality_filename = filepath(string(run.date, wave_regions[w], $
                                       format='%s.ucomp.%s.quality.log'), $
                                root=l1_dir)
    if (file_test(quality_filename, /regular)) then begin
      files_list->add, quality_filename
    endif
  endfor

  n_files = files_list->count()
  files = files_list->toArray()

  if (n_files eq 0L) then begin
    mg_log, 'no level 1 files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  ; create tarball/listing file
  tar_basename = string(run.date, format='%s.ucomp.l1.tar.gz')
  tar_filename = filepath(tar_basename, root=processing_dir)
  mg_log, '%d files in %s', n_files, tar_basename, $
          name=run.logger_name, /info
  file_tar, files, tar_filename, /gzip
  ucomp_fix_permissions, tar_filename, logger=run.logger_name

  tarlist_basename = string(run.date, format='%s.ucomp.l1.tarlist.txt')
  tarlist_filename = filepath(tarlist_basename, root=processing_dir)
  openw, lun, tarlist_filename, /get_lun
  printf, lun, transpose(file_basename(files))
  free_lun, lun
  ucomp_fix_permissions, tarlist_filename, logger=run.logger_name

  ; copy tarball/listing file to fullres directory
  file_copy, tar_filename, web_dir, /overwrite
  file_copy, tarlist_filename, web_dir, /overwrite

  cleanup:
  if (obj_valid(files_list)) then obj_destroy, files_list
end
