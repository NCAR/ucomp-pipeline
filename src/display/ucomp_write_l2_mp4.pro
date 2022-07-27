; docformat = 'rst'

pro ucomp_write_l2_mp4, wave_region, type, run=run
  compile_opt strictarr

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  glob = string(wave_region, type, format='(%"*.ucomp.%s.%s.png")')
  image_filenames = file_search(glob, count=n_images)

  if (n_images eq 0L) then begin
    mg_log, 'no %s nm %s images, skipping making mp4', wave_region, type, $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'making %s nm %s mp4 from %d images', wave_region, type, n_images, $
          name=run.logger_name, /info

  mp4_basename = string(run.date, wave_region, type, $
                        format='(%"%s.ucomp.%s.%s.mp4")')
  mp4_filename = filepath(mp4_basename, root=l2_dir)

  ucomp_create_mp4, image_filenames, mp4_filename, run=run, status=status

  done:
end
