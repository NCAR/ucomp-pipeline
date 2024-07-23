; docformat = 'rst'

;+
; Package and distribute level 2 FITS files to the appropriate locations.
; Create YYYYMMDD.ucomp.l2.tar.gz and its list file. Copy them to the web
; archive directory.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_publish, run=run
  compile_opt strictarr

  ; copy L2 data into archive, etc. directories

  n_nondatafiles = 0L

  web_basedir = run->config('results/web_basedir')
  distribute_fits = n_elements(web_basedir) gt 0L
  if (distribute_fits) then begin
    web_dir = filepath('', $
                       subdir=ucomp_decompose_date(run.date), $
                       root=web_basedir)
    ucomp_mkdir, web_dir, logger_name=run.logger_name
  endif else begin
    mg_log, 'skipping publishing L2 data', name=run.logger, /info
    goto, cleanup
  endelse

  processing_dir = filepath(run.date, root=run->config('processing/basedir'))
  l2_dir = filepath('', subdir='level2', root=processing_dir)

  files_list = list()
  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    publish_type = strlowcase(run->config(wave_regions[w] + '/publish_type'))
    if (publish_type eq 'none') then begin
      mg_log, 'skipping publishing %s nm L2 data', wave_regions[w], $
              name=run.logger, /info
      continue
    endif else begin
      mg_log, 'publishing %s nm L2 data (%s)', wave_regions[w], publish_type, $
              name=run.logger, /info
    endelse

    ; The types of level 2 FITS files:
    ;   level2/YYYYMMDD.HHMMSS.ucomp.WWWW.l2.fts
    ;   level2/YYYYMMDD.HHMMSS.ucomp.WWWW.l2.{synoptic,waves}.{mean,median}.fts

    files = run->get_files(wave_region=wave_regions[w], count=n_files)
    for f = 0L, n_files - 1L do begin
      if (files[f].wrote_l2) then begin
        files_list->add, filepath(files[f].l2_basename, root=l2_dir)
      endif
    endfor

    average_format = '%s.ucomp.%s.l2.{synoptic,waves}.{mean,median}.fts'
    average_filenames = file_search(filepath(string(run.date, wave_regions[w], $
                                                    format=average_format), $
                                             root=l2_dir), $
                                    count=n_average_files)
    if (n_average_files gt 0L) then begin
      mg_log, 'adding %d L2 average files', n_average_files, $
              name=run.logger_name, /info
      files_list->add, average_filenames, /extract
    endif
  endfor

  ; add catalog, GBU, quality files and user guide

  citation_filename = filepath('UCOMP_CITATION.txt', $
                               subdir='docs', $
                               root=run.resource_root)
  files_list->add, citation_filename
  n_nondatafiles += 1L

  ucomp_add_userguide, files_list, run=run
  n_nondatafiles += 1L

  catalog_filename = filepath(string(run.date, format='%s.ucomp.catalog.txt'), $
                              root=processing_dir)
  if (~file_test(catalog_filename, /regular)) then begin
    mg_log, 'no catalog file, skipping L2 publishing', $
            name=run.logger, /info
    goto, cleanup
  endif
  files_list->add, catalog_filename
  n_nondatafiles += 1L

  for w = 0L, n_elements(wave_regions) - 1L do begin
    wave_region_catalog_filename = filepath(string(run.date, wave_regions[w], $
                                                   format='%s.ucomp.%s.files.txt'), $
                                            root=processing_dir)
    if (file_test(wave_region_catalog_filename, /regular)) then begin
      files_list->add, wave_region_catalog_filename
    endif

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

  if (n_files - n_nondatafiles le 0L) then begin
    mg_log, 'no level 2 files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  ; copy individual files
  file_copy, files, web_dir, /overwrite

  ; create tarball/listing file
  tar_basename = string(run.date, format='%s.ucomp.l2.tar.gz')
  tar_filename = filepath(tar_basename, root=processing_dir)
  mg_log, 'adding %d files to %s', n_files, tar_basename, $
          name=run.logger_name, /info
  file_tar, files, tar_filename, /gzip
  ucomp_fix_permissions, tar_filename, logger=run.logger_name

  tarlist_basename = string(run.date, format='%s.ucomp.l2.tarlist.txt')
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
