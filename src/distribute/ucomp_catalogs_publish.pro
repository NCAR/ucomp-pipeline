; docformat = 'rst'

;+
; Package and distribute catalog files appropriate locations.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_catalogs_publish, run=run
  compile_opt strictarr

  fullres_basedir = run->config('results/fullres_basedir')
  if (n_elements(fullres_basedir) eq 0L) then begin
    mg_log, 'skipping catalog distribution', name=run.logger_name, /info
    goto, cleanup
  endif

  fullres_dir = filepath('', $
                         subdir=ucomp_decompose_date(run.date), $
                         root=fullres_basedir)
  ucomp_mkdir, fullres_dir, logger_name=run.logger_name

  processing_dir = filepath(run.date, root=run->config('processing/basedir'))
  l1_dir = filepath('', subdir='level1', root=processing_dir)
  l2_dir = filepath('', subdir='level2', root=processing_dir)

  ; make list of files to distribute
  catalog_files_list = list()


  ; populate catalog_files_list
  wave_regions = run->config('options/wave_regions')

  ; add catalog, GBU, quality files and user guide

  citation_filename = filepath('UCOMP_CITATION.txt', $
                               subdir='docs', $
                               root=run.resource_root)
  catalog_files_list->add, citation_filename

  userguide_filename = filepath('ucomp-user-guide.v1.0.pdf', $
                                subdir='docs', $
                                root=run.resource_root)
  catalog_files_list->add, userguide_filename

  catalog_filename = filepath(string(run.date, format='%s.ucomp.catalog.txt'), $
                              root=processing_dir)
  catalog_files_list->add, catalog_filename

  for w = 0L, n_elements(wave_regions) - 1L do begin
    wave_region_catalog_filename = filepath(string(run.date, wave_regions[w], $
                                                   format='%s.ucomp.%s.files.txt'), $
                                            root=processing_dir)
    catalog_files_list->add, wave_region_catalog_filename

    gbu_filename = filepath(string(run.date, wave_regions[w], $
                                   format='%s.ucomp.%s.gbu.log'), $
                            root=l1_dir)
    catalog_files_list->add, gbu_filename

    quality_filename = filepath(string(run.date, wave_regions[w], $
                                       format='%s.ucomp.%s.quality.log'), $
                                root=l1_dir)
    catalog_files_list->add, quality_filename
  endfor

  n_catalog_files = catalog_files_list->count()
  catalog_files = catalog_files_list->toArray()
  obj_destroy, catalog_files_list

  if (n_catalog_files eq 0L) then begin
    mg_log, 'no catalog files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  ; copy individual files to fullres directory
  file_copy, catalog_files, fullres_dir, /overwrite

  ; create gzip file
  gzip_basename = string(run.date, format='%s.ucomp.catalogs.zip')
  gzip_filename = filepath(gzip_basename, root=processing_dir)
  mg_log, '%d files in %s', $
          n_catalog_files, gzip_basename, $
          name=run.logger_name, /info
  file_zip, catalog_files, gzip_filename

  gziplist_basename = string(run.date, format='%s.ucomp.catalogs.txt')
  gziplist_filename = filepath(gziplist_basename, root=processing_dir)
  openw, lun, gziplist_filename, /get_lun
  printf, lun, transpose(file_basename(catalog_files))
  free_lun, lun

  ; copy gzip file to fullres directory
  file_copy, gzip_filename, fullres_dir, /overwrite
  file_copy, gziplist_filename, fullres_dir, /overwrite

  cleanup:
end
