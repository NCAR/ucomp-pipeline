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

  publish_type = strlowcase(run->config(wave_region + '/publish_type'))

  ; publish dynamics/polarization files

  switch publish_type of
    'all': begin
        ; 20220902.005109.ucomp.1074.l2.polarization.fts
        ucomp_l2_tar_type, 'polarization', $
                           wave_region, $
                           string(wave_region, name, format='*.ucomp.%s.l2.polarization.fts'), $
                           tarfile=polarization_tarfile, $
                           tarlist=polarization_tarlist, $
                           filenames=polarization_filenames, $
                           n_files=n_polarization_files, $
                           run=run
        if (n_polarization_files gt 0L) then begin
          file_copy, polarization_tarfile, web_dir, /overwrite
          file_copy, polarization_tarlist, web_dir, /overwrite
          file_copy, polarization_filenames, web_dir, /overwrite
          mg_log, 'copied %d %s nm polarization FITS files to web archive', $
                  n_polarization_files, wave_region, $
                  name=run.logger_name, /info
        endif else begin
          mg_log, 'no %s nm polarization FITS files to copy to web archive', $
                  wave_region, $
                  name=run.logger_name, /info
        endelse
      end
    'dynamics': begin
        ; 20220902.005109.ucomp.1074.l2.dynamics.fts
        ucomp_l2_tar_type, 'dynamics', $
                           wave_region, $
                           string(wave_region, name, format='*.ucomp.%s.l2.dynamics.fts'), $
                           tarfile=dynamics_tarfile, $
                           tarlist=dynamics_tarlist, $
                           filenames=dynamics_filenames, $
                           n_files=n_dynamics_files, $
                           run=run
        if (n_dynamics_files gt 0L) then begin
          file_copy, dynamics_tarfile, web_dir, /overwrite
          file_copy, dynamics_tarlist, web_dir, /overwrite
          file_copy, dynamics_filenames, web_dir, /overwrite
          mg_log, 'copied %d %s nm dynamics FITS files to web archive', $
                  n_dynamics_files, wave_region, $
                  name=run.logger_name, /info
        endif else begin
          mg_log, 'no %s nm dynamics FITS files to copy to web archive', $
                  wave_region, $
                  name=run.logger_name, /info
        endelse
      end
    else:
  endswitch

  ; publish quick invert files
  if (publish_type eq 'all') then begin
    ; 20220901.ucomp.1074.l2.waves.median.quick_invert.fts
    ucomp_l2_tar_type, 'quick_invert', $
                       wave_region, $
                       string(run.date, wave_region, format='%s.ucomp.%s.l2.*.{mean,median}.quick_invert.fts'), $
                       tarfile=quickinvert_tarfile, $
                       tarlist=quickinvert_tarlist, $
                       filenames=quickinvert_filenames, $
                       n_files=n_quickinvert_files, $
                       run=run
    if (n_quickinvert_files gt 0L) then begin
      file_copy, quickinvert_tarfile, web_dir, /overwrite
      file_copy, quickinvert_tarlist, web_dir, /overwrite
      file_copy, quickinvert_filenames, web_dir, /overwrite
      mg_log, 'copied %d %s nm quick invert FITS files to web archive', $
              n_quickinvert_files, wave_region, $
              name=run.logger_name, /info
    endif else begin
      mg_log, 'no %s nm quick invert FITS files to copy to web archive', $
              wave_region, $
              name=run.logger_name, /info
    endelse
  endif

  ; publish mean/median files
  if (publish_type ne 'none') then begin
    ; 20220901.ucomp.1074.l2.waves.mean.fts
    ucomp_l2_tar_type, 'average', $
                       wave_region, $
                       string(run.date, wave_region, format='%s.ucomp.%s.l2.*.{mean,median}.fts'), $
                       tarfile=average_tarfile, $
                       tarlist=average_tarlist, $
                       filenames=average_filenames, $
                       n_files=n_average_files, $
                       run=run
    if (n_average_files gt 0L) then begin
      file_copy, average_tarfile, web_dir, /overwrite
      file_copy, average_tarlist, web_dir, /overwrite
      file_copy, average_filenames, web_dir, /overwrite
      mg_log, 'copied %d %s nm mean/median FITS files to web archive', $
              n_average_files, wave_region, $
              name=run.logger_name, /info
    endif else begin
      mg_log, 'no %s nm mean/median FITS files to copy to web archive', $
              wave_region, $
              name=run.logger_name, /info
    endelse
  endif

  cleanup:
end
