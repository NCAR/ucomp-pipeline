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

  n_files = files_list->count()
  files = files_list->toArray()
  obj_destroy, files_list

  if (n_files eq 0L) then begin
    mg_log, 'no level 1 files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  ; create gzip file
  tar_basename = string(run.date, format='%s.ucomp.l1.tar.gz')
  tar_filename = filepath(tar_basename, root=processing_dir)
  mg_log, '%d files in %s', n_files, tar_basename, $
          name=run.logger_name, /info
  file_tar, files, tar_filename, /gzip

  tarlist_basename = string(run.date, format='%s.ucomp.l1.txt')
  tarlist_filename = filepath(tarlist_basename, root=processing_dir)
  openw, lun, tarlist_filename, /get_lun
  printf, lun, transpose(file_basename(files))
  free_lun, lun

  ; copy gzip file to fullres directory
  file_copy, tar_filename, web_dir, /overwrite
  file_copy, tarlist_filename, web_dir, /overwrite

  cleanup:
end
