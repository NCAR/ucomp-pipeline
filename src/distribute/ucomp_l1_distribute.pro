; docformat = 'rst'

;+
; Package and distribute level 1 products to the appropriate locations.
;
; :Params:
;   wave_region : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_distribute, wave_region, run=run
  compile_opt strictarr

  if (~run->config(wave_region + '/distribute_l1')) then begin
    mg_log, 'skipping distributing %s nm L1 data', wave_region, $
            name=run.logger, /info
    goto, done
  endif

  ; copy L1 data into web archive, etc. directories

  web_basedir = run->config('results/web_basedir')
  distribute_fits = n_elements(web_basedir) gt 0L
  if (distribute_fits) then begin
    web_dir = filepath('', $
                       subdir=ucomp_decompose_date(run.date), $
                       root=web_basedir)
    ucomp_mkdir, web_dir, logger_name=run.logger_name
  endif

  fullres_basedir = run->config('results/fullres_basedir')
  distribute_images = n_elements(fullres_basedir) gt 0L
  distribute_movies = distribute_images
  if (distribute_images) then begin
    fullres_dir = filepath('', $
                           subdir=ucomp_decompose_date(run.date), $
                           root=fullres_basedir)
    ucomp_mkdir, fullres_dir, logger_name=run.logger_name
  endif

  if (distribute_fits || distribute_images) then begin
    process_dir = filepath('', $
                           subdir=[run.date, 'level1'], $
                           root=run->config('processing/basedir'))

    files = run->get_files(wave_region=wave_region, count=n_files)
    n_total_fits_files = 0L
    n_total_image_files = 0L
    for f = 0L, n_files - 1L do begin
      if (files[f].ok and files[f].wrote_l1 and (files[f].gbu eq 0L)) then begin
        ; grab the date/time, e.g., "20220829.205656"
        prefix = strmid(files[f].l1_basename, 0, 15)

        if (distribute_fits) then begin
          fits_glob = string(prefix, wave_region, format='%s.ucomp.%s.l1.*.fts*')
          fits_files = file_search(filepath(fits_glob, root=process_dir), $
                                    count=n_fits_files)
          n_total_fits_files += n_fits_files
          if (n_fits_files gt 0L) then file_copy, fits_files, web_dir, /overwrite
        endif

        if (distribute_images) then begin
          image_glob = string(prefix, wave_region, format='%s.ucomp.%s.l1.*.{png,gif}')
          image_files = file_search(filepath(image_glob, root=process_dir), $
                                    count=n_image_files)
          n_total_image_files += n_image_files
          if (n_image_files gt 0L) then file_copy, image_files, fullres_dir, /overwrite
        endif
      endif
    endfor

    mg_log, 'copied %d %s nm FITS files to web archive', $
            n_total_fits_files, wave_region, $
            name=run.logger_name, /info
    mg_log, 'copied %d %s nm image files to fullres archive', $
            n_total_image_files, wave_region, $
            name=run.logger_name, /info

    if (distribute_movies) then begin
      movie_glob = string(run.date, wave_region, format='%s.ucomp.%s.l1.*.mp4*')
      movie_files = file_search(filepath(movie_glob, root=process_dir), $
                                count=n_movie_files)
      if (n_movie_files gt 0L) then begin
        file_copy, movie_files, fullres_dir, /overwrite
        mg_log, 'copied %d %s nm movie files to fullres archive', $
                n_movie_files, wave_region, $
                name=run.logger_name, /info
      endif
    endif
  endif else begin
    mg_log, 'neither results/{web,fullres}_basedir specified', name=run.logger, /warn
  endelse

  done:
end
