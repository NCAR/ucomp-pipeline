; docformat = 'rst'

;+
; Package and distribute level 2 FITS files to the appropriate locations.
;
; :Params:
;   wave_region : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_publish, wave_region, run=run
  compile_opt strictarr

  ; copy L2 data into archive, etc. directories

  web_basedir = run->config('results/web_basedir')
  if (n_elements(web_basedir) eq 0L) then begin
    mg_log, 'results/web_basedir specified', name=run.logger, /warn
    goto, cleanup
  endif

  web_dir = filepath('', $
                     subdir=ucomp_decompose_date(run.date), $
                     root=web_basedir)
  ucomp_mkdir, web_dir, logger_name=run.logger_name

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

  if (run->config(wave_region + '/publish_dynamics')) then begin
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

  if (run->config(wave_region + '/publish_polarization')) then begin
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

  process_dir = filepath('', $
                         subdir=[run.date, 'level2'], $
                         root=run->config('processing/basedir'))

  files = run->get_files(wave_region=wave_region, count=n_files)

  for f = 0L, n_files - 1L do begin
    if (files[f].ok and files[f].wrote_l1 and (files[f].gbu eq 0L)) then begin
      ; grab the date/time, e.g., "20220829.205656"
      prefix = strmid(files[f].l1_basename, 0, 15)

      fits_glob = string(prefix, wave_region, format='%s.ucomp.%s.l2.*.fts*')
      fits_files = file_search(filepath(fits_glob, root=process_dir), $
                                count=n_fits_files)
      if (n_fits_files gt 0L) then file_copy, fits_files, web_dir, /overwrite
    endif
  endfor

  mg_log, 'copied %d %s nm FITS files to web archive', $
          n_fits_files, wave_region, $
          name=run.logger_name, /info

  average_fits_glob = string(run.date, wave_region, format='%s.ucomp.%s.{mean,median}.*.fts*')
  average_fits_files = file_search(filepath(average_fits_glob, root=process_dir), $
                            count=n_average_fits_files)
  if (n_average_fits_files gt 0L) then begin
    file_copy, average_fits_files, web_dir, /overwrite
    mg_log, 'copied %d %s nm average FITS files to web archive', $
            n_average_fits_files, wave_region, $
            name=run.logger_name, /info
  endif

  cleanup:
end
