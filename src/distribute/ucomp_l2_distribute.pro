; docformat = 'rst'

;+
; Package and distribute level 2 products to the appropriate locations.
;
; :Params:
;   wave_region : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_distribute, wave_region, run=run
  compile_opt strictarr

  ; copy L2 data into archive, etc. directories

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
  if (distribute_images) then begin
    fullres_dir = filepath('', $
                           subdir=ucomp_decompose_date(run.date), $
                           root=fullres_basedir)
    ucomp_mkdir, fullres_dir, logger_name=run.logger_name
  endif

  files = run->get_files(wave_region=wave_region, count=n_files)
  dynamics_basenames = strarr(n_files)
  dynamics_available = bytarr(n_files)
  polarization_basenames = strarr(n_files)
  polarization_available = bytarr(n_files)
  for f = 0L, n_files - 1L do begin
    file = files[f]

    dynamics_basenames[f] = file.dynamics_basename
    dynamics_available[f] = file.wrote_dynamics

    polarization_basenames[f] = file.polarization_basename
    polarization_available[f] = file.wrote_polarization
  endfor

  if (run->config(wave_region + '/distribute_dynamics')) then begin
    ; make dynamics, polarization FITS tarballs and copy to web archive
    ucomp_l2_tar_type, 'dynamics', wave_region, $
                       tarfile=dynamics_tarfile, tarlist=dynamics_tarlist, $
                       run=run
    file_copy, dynamics_tarfile, web_dir, /overwrite
    file_copy, dynamics_tarlist, web_dir, /overwrite
  endif else begin
    mg_log, 'skipping distributing %s nm L2 dynamics data', wave_region, $
            name=run.logger, /info
  endelse

  if (run->config(wave_region + '/distribute_polarization')) then begin
    ucomp_l2_tar_type, 'polarization', wave_region, $
                       tarfile=polarization_tarfile, tarlist=polarization_tarlist, $
                       run=run
    file_copy, polarization_tarfile, web_dir, /overwrite
    file_copy, polarization_tarlist, web_dir, /overwrite
  endif else begin
    mg_log, 'skipping distributing %s nm L2 polarization data', wave_region, $
            name=run.logger, /info
  endelse

  ; TODO: make other tarballs from issue #114
  ; TODO: make sure the following is still correct

  if (distribute_fits || distribute_images) then begin
    process_dir = filepath('', $
                           subdir=[run.date, 'level2'], $
                           root=run->config('processing/basedir'))

    files = run->get_files(wave_region=wave_region, count=n_files)

    n_total_fits_files = 0L
    n_total_image_files = 0L
    for f = 0L, n_files - 1L do begin
      if (files[f].ok and files[f].wrote_l1 and (files[f].gbu eq 0L)) then begin
        ; grab the date/time, e.g., "20220829.205656"
        prefix = strmid(files[f].l1_basename, 0, 15)

        if (distribute_fits) then begin
          fits_glob = string(prefix, wave_region, format='%s.ucomp.%s.l2.*.fts*')
          fits_files = file_search(filepath(fits_glob, root=process_dir), $
                                    count=n_fits_files)
          n_total_fits_files += n_fits_files
          if (n_fits_files gt 0L) then file_copy, fits_files, web_dir, /overwrite
        endif

        if (distribute_images) then begin
          image_glob = string(prefix, wave_region, format='%s.ucomp.%s.l2.*.png')
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

    if (distribute_fits) then begin
      average_fits_glob = string(run.date, wave_region, format='%s.ucomp.%s.{mean,median}.*.fts*')
      average_fits_files = file_search(filepath(average_fits_glob, root=process_dir), $
                                count=n_average_fits_files)
      if (n_average_fits_files gt 0L) then begin
        file_copy, average_fits_files, web_dir, /overwrite
        mg_log, 'copied %d %s nm average FITS files to web archive', $
                n_average_fits_files, wave_region, $
                name=run.logger_name, /info
      endif
    endif

    if (distribute_images) then begin
      average_image_glob = string(run.date, wave_region, format='%s.ucomp.%s.{mean,median}.iquv.png')
      average_image_files = file_search(filepath(average_image_glob, root=process_dir), $
                                count=n_average_image_files)
      if (n_average_image_files gt 0L) then begin
        file_copy, average_image_files, fullres_dir, /overwrite
        mg_log, 'copied %d %s nm average image files to fullres archive', $
                n_average_image_files, wave_region, $
                name=run.logger_name, /info
      endif
    endif
  endif else begin
    mg_log, 'neither results/{web,fullres}_basedir specified', name=run.logger, /warn
  endelse

  done:
end
