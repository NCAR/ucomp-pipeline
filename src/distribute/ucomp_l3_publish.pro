; docformat = 'rst'

;+
; Package and distribute level 3 FITS files to the appropriate locations.
; Create YYYYMMDD.ucomp.l3.tar.gz and its list file. Copy them to the web
; archive directory.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l3_publish, run=run
  compile_opt strictarr

  ; copy L3 data into archive, etc. directories

  n_nondatafiles = 0L

  web_basedir = run->config('results/web_basedir')
  distribute_fits = n_elements(web_basedir) gt 0L
  if (distribute_fits) then begin
    web_dir = filepath('', $
                       subdir=ucomp_decompose_date(run.date), $
                       root=web_basedir)
    ucomp_mkdir, web_dir, logger_name=run.logger_name
  endif

  fullres_basedir = run->config('results/fullres_basedir')
  distribute_gifs = n_elements(fullres_basedir) gt 0L
  if (distribute_gifs) then begin
    fullres_dir = filepath('', $
                           subdir=ucomp_decompose_date(run.date), $
                           root=fullres_basedir)
    ucomp_mkdir, web_dir, logger_name=run.logger_name
  endif

  if (~distribute_fits && ~distribute_gifs)
    mg_log, 'no results basedirs, skipping publishing L3 data', name=run.logger, /info
    goto, cleanup
  endelse

  processing_dir = filepath(run.date, root=run->config('processing/basedir'))
  l3_dir = filepath('', subdir='level3', root=processing_dir)

  publish_level3 = run->config('level3/publish')
  if (publish_level3) then begin
    mg_log, 'publishing L3 data', name=run.logger, /info
  endif else begin
    mg_log, 'skipping publishing L3 data', name=run.logger, /info
    goto, cleanup
  endelse

  files_list = list()

  density_fits_files = file_search(filepath('*density.fts*', root=l3_dir), $
                                   count=n_density_fits_files)
  density_gif_files = file_search(filepath('*density.gif', root=l3_dir), $
                                  count=n_density_gif_files)

  if (n_density_fits_files + n_density_gif_files eq 0L) then begin
    mg_log, 'no level 3 files to distribute', name=run.logger_name, /info
    goto, cleanup
  endif

  if (n_density_fits_files gt 0L) then files_list->add, density_fits_files
  if (n_density_gif_files gt 0L) then files_list->add, density_gif_files

  ; add catalog, GBU, quality files and user guide

  citation_template_filename = filepath('UCOMP_CITATION.txt', $
                                        subdir='docs', $
                                        root=run.resource_root)
  citation_filename = filepath('UCOMP_CITATION.txt', root=processing_dir)
  ucomp_make_citation_file, citation_template_filename, citation_filename
  files_list->add, citation_filename

  ucomp_add_userguide, files_list, run=run

  n_files = files_list->count()
  files = files_list->toArray()

  ; copy individual files
  if (n_density_fits_files gt 0L && distribute_fits) then begin
    file_copy, density_fits_files, web_dir, /overwrite
  endif

  if (n_density_gif_files gt 0L && distribute_gifs) then begin
    file_copy, density_gif_files, fullres_dir, /overwrite
  endif

  ; create tarball/listing file
  tar_basename = string(run.date, format='%s.ucomp.l3.tar.gz')
  tar_filename = filepath(tar_basename, root=processing_dir)
  mg_log, 'adding %d files to %s', n_files, tar_basename, $
          name=run.logger_name, /info
  file_tar, files, tar_filename, /gzip
  ucomp_fix_permissions, tar_filename, logger=run.logger_name

  tarlist_basename = string(run.date, format='%s.ucomp.l3.tarlist.txt')
  tarlist_filename = filepath(tarlist_basename, root=processing_dir)
  openw, lun, tarlist_filename, /get_lun
  printf, lun, transpose(file_basename(files))
  free_lun, lun
  ucomp_fix_permissions, tarlist_filename, logger=run.logger_name

  ; copy tarball/listing file to web archive directory
  file_copy, tar_filename, web_dir, /overwrite
  file_copy, tarlist_filename, web_dir, /overwrite

  cleanup:
  if (obj_valid(files_list)) then obj_destroy, files_list
end
