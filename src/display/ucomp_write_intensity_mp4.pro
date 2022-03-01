; docformat = 'rst'

;+
; Write an intensity mp4 for all the intensity images for a given wave region.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, i.e., "1074"
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_intensity_mp4, wave_region, run=run
  compile_opt strictarr

  mg_log, 'writing intensity mp4 for %s nm', wave_region, name=run.logger_name, /info

  perform_centering = run->config('centering/perform')
  if (~perform_centering) then begin
    mg_log, 'skipping writing intensity mp4 because not centering images', $
            name=run.logger_name, /warn
    goto, done
  endif

  center_wavelength_only = run->config('intensity/center_wavelength_gifs_only')
  if (~center_wavelength_only) then begin
    mg_log, 'skipping writing intensity mp4 because not only center wavelength images', $
            name=run.logger_name, /warn
    goto, done
  endif

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_region, name=run.logger_name, /warn
    goto, done
  endif

  use = bytarr(n_files)
  for f = 0L, n_files - 1L do begin
    use[f] = files[f].ok and ~files[f].gbu
  endfor

  use_indices = where(use, n_use)
  if (n_use eq 0L) then begin
    mg_log, 'no usable files @ %s nm', wave_region, name=run.logger_name, /warn
    goto, done
  endif

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))

  image_filenames = strarr(n_use)
  for f = 0L, n_use - 1L do begin
    image_filenames[f] = file_basename(files[use_indices[f]].l1_basename, '.fts')
    image_filenames[f] += '.int.gif'
    image_filenames[f] = filepath(image_filenames[f], root=l1_dirname)
  endfor

  mp4_filename = filepath(string(run.date, wave_region, $
                                 format='(%"%s.ucomp.%s.l1.int.mp4")'), $
                          root=l1_dirname)

  ucomp_create_mp4, image_filenames, mp4_filename, run=run, status=status
  mg_log, 'wrote intensity mp4 %s for %s nm', mp4_filename, wave_region, $
          name=run.logger_name, /info

  done:
  mg_log, 'done', name=run.logger_name, /info
end