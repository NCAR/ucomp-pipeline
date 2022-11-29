; docformat = 'rst'

;+
; Create a movie from an array of image filenames. Creates temporary files in
; the current directory and deletes them when finished.
;
; :Params:
;   image_filenames : in, required, type=strarr
;     image filenames that represent frames of the movie (must all be the same
;     format)
;   mp4_filename : in, required, type=string
;     filename for output mp4 file
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of creating the mp4 file;
;     0 indicates success, anything else if failure
;-
pro ucomp_create_mp4, image_filenames, mp4_filename, run=run, status=status
  compile_opt strictarr

  n_image_files = n_elements(image_filenames)

  tmp_image_fmt = '(%"tmp-%04d.%s")'
  pid = mg_pid()
  tmp_dir = filepath(string(pid, format='(%"ucomp-%s")'), /tmp)

  ; delete any previous tmp files
  file_delete, tmp_dir, /recursive, /quiet, /allow_nonexistent

  file_mkdir, tmp_dir

  basename = file_basename(image_filenames[0])
  ext = strmid(basename, strpos(basename, '.', /reverse_search) + 1L)

  ; create links so filenames are in correct order and filename format
  for f = 0L, n_image_files - 1L do begin
    file_link, image_filenames[f], $
               filepath(string(f, ext, format=tmp_image_fmt), $
                        root=tmp_dir)
  endfor

  ; use ffmpeg to create mp4 from image files
  cmd_format = '(%"%s -r 20 -i %s/tmp-%%*.%s -y -loglevel error ' $
                 + '-vcodec libx264 -passlogfile ucomp_tmp -r 20 %s")'

  cmd = string(run->config('externals/ffmpeg'), $
               tmp_dir, $
               ext, $
               mp4_filename, $
               format=cmd_format)
  bash_cmd = string(cmd, format='(%"sh -c \"%s\"")')
  spawn, bash_cmd, result, error_result, exit_status=status
  if (status ne 0L) then begin
    mg_log, 'problem creating mp4 with command: %s', bash_cmd, $
            name=run.logger_name, /error
    mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
  endif

  ; delete tmp files
  file_delete, tmp_dir, /recursive, /quiet, /allow_nonexistent
end


; main-level example program

date = '20221123'

config_filename = filepath('ucomp.latest.cfg', $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

image_glob = filepath('*.ucomp.1074.l1.3.int.gif', $
                      subdir=[date, 'level1'], $
                      root=run->config('processing/basedir'))
image_files = file_search(image_glob, count=n_image_files)

int_mp4_basename = string(date, format='(%"%s_ucomp_int_test.mp4")')
int_mp4_filename = filepath(int_mp4_basename, $
                            subdir=[date, 'level1'], $
                            root=run->config('processing/basedir'))

ucomp_create_mp4, image_files, int_mp4_filename, run=run, status=status
help, status

obj_destroy, run

end
