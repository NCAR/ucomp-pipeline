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

  return

  ; copy L2 data into archive, etc. directories

  web_basedir = run->config('results/web_basedir')
  if (n_elements(web_basedir) eq 0L) then begin
    mg_log, 'results/web_basedir not specified', name=run.logger, /warn
    goto, cleanup
  endif

  web_dir = filepath('', $
                     subdir=ucomp_decompose_date(run.date), $
                     root=web_basedir)
  ucomp_mkdir, web_dir, logger_name=run.logger_name

  publish_type = strlowcase(run->config(wave_region + '/publish_type'))

  ; publish level 2 files

  case publish_type of
    'none':
    else: begin
        ucomp_l2_tar_type, 'l2', $
                           wave_region, $
                           string(wave_region, format='*.ucomp.%s.l2.fts'), $
                           tarfile=l2_tarfile, $
                           tarlist=l2_tarlist, $
                           filenames=l2_filenames, $
                           n_files=n_l2_files, $
                           run=run
        if (n_l2_files gt 0L) then begin
          file_copy, l2_tarfile, web_dir, /overwrite
          file_copy, l2_tarlist, web_dir, /overwrite

          ; TODO: don't copy individual files yet
          ;file_copy, l2_filenames, web_dir, /overwrite

          mg_log, 'copied %d %s nm level 2 FITS files to web archive', $
                  n_polarization_files, wave_region, $
                  name=run.logger_name, /info
        endif else begin
          mg_log, 'no %s nm level 2 FITS files to copy to web archive', $
                  wave_region, $
                  name=run.logger_name, /info
        endelse
      end
  endcase

  ; publish l2 average files
  if (publish_type ne 'none') then begin
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

  ; publish l1 average files
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


; main-level example program

date = '20220901'
config_basename = 'ucomp.publish.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

wave_regions = run->config('options/wave_regions')
for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_l2_publish, wave_regions[w], run=run
endfor

obj_destroy, run

end
