; docformat = 'rst'

;+
; Package and distribute quicklook images and movies to the appropriate
; locations.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_quicklook_distribute, run=run
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

  processing_basedir = run->config('processing/basedir')

  ; make list of files to distribute
  quicklook_files_list = list()

  ; TODO: populate quicklook_files_list
  ; for each wave region:
  ;   if distribute dynamics for the wave region:
  ;     - level 1 intensity GIFs
  ;     - level 2 dynamics PNG dashboards
  ;   if distribute polarization for the wave region:
  ;     - level 2 polarization PNG dashboards
  ; for each temperature map:
  ;   if temperature map is to be distributed
  ;     - temperature map

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
                           subdir=run.date, $
                           root=processing_basedir)
  file_gzip, quicklook_files, gzip_filename

  ; copy gzip file to fullres directory
  file_copy, gzip_filename, fullres_dir, /overwrite

  cleanup:
end
