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
pro ucomp_l1_publish, wave_region, run=run
  compile_opt strictarr

  if (~run->config(wave_region + '/publish_l1')) then begin
    mg_log, 'skipping publishing %s nm L1 data', wave_region, $
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

  publish_type = run->config(wave_region + '/publish_type')

  if (distribute_fits) then begin
    l1_dir = filepath('', $
                      subdir=[run.date, 'level1'], $
                      root=run->config('processing/basedir'))

    files = run->get_files(wave_region=wave_region, count=n_files)

    n_total_fits_files = 0L
    for f = 0L, n_files - 1L do begin
      if (files[f].ok and files[f].wrote_l1 and (files[f].gbu eq 0L)) then begin
        ; grab the date/time, e.g., "20220829.205656"
        prefix = strmid(files[f].l1_basename, 0, 15)

        ; The two types of level 1 FITS files:
        ;   YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.fts
        ;   YYYYMMDD.HHMMSS.ucomp.WWWW.l1.N.intensity.fts
        case strlowcase(publish_type) of
          'all': begin
              fits_glob = string(prefix, wave_region, format='%s.ucomp.%s.l1.*.fts*')
              fits_files = file_search(filepath(fits_glob, root=l1_dir), $
                                        count=n_fits_files)
            end
          'dynamics': begin
              fits_glob = string(prefix, wave_region, $
                                 format='%s.ucomp.%s.l1.*.intensity.fts*')
              fits_files = file_search(filepath(fits_glob, root=l1_dir), $
                                       count=n_fits_files)
            end
          else: n_fits_files = 0L
        endcase

        n_total_fits_files += n_fits_files
        if (n_fits_files gt 0L) then file_copy, fits_files, web_dir, /overwrite
      endif
    endfor

    mg_log, 'copied %d %s nm FITS files to web archive', $
            n_total_fits_files, wave_region, $
            name=run.logger_name, /info
  endif

  done:
end
