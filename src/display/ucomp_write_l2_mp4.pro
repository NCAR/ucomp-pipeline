; docformat = 'rst'

;+
; Create a level 2 mp4 for a given wave region and type, e.g., radial_azimuth,
; line_width, etc.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, i.e., "1074"
;   type : in, required, type=string
;     type of data to be used in the creating the mp4, corresponding to the
;     name indicating type used in the PNG files
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_l2_mp4, wave_region, type, run=run
  compile_opt strictarr

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  glob = filepath(string(wave_region, type, format='(%"*.ucomp.%s.l2.%s.png")'), $
                  root=l2_dir)
  image_filenames = file_search(glob, count=n_images)

  if (n_images eq 0L) then begin
    mg_log, 'no %s nm %s images, skipping making mp4', wave_region, type, $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'making %s nm %s mp4 from %d images', wave_region, type, n_images, $
          name=run.logger_name, /info

  mp4_basename = string(run.date, wave_region, type, $
                        format='(%"%s.ucomp.%s.l2.%s.mp4")')
  mp4_filename = filepath(mp4_basename, root=l2_dir)

  mg_log, 'writing %s...', $
          mp4_basename, $
          name=run.logger_name, /info
  ucomp_create_mp4, image_filenames, mp4_filename, run=run, status=status

  done:
end
