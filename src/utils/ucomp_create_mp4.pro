; docformat = 'rst'

;+
; Create an mp4 animation from an array of image filenames.
;
; :Params:
;   image_filenames : in, required, type=strarr
;     string array of filenames of the image files representing frames of the
;     mp4; they must all be the same extension
;   mp4_filename : in, required, type=string
;     filename of output mp4 file
;
; :Keywords:
;   executable : in, optional, type=string, default=ffmpeg
;     filename of ffmpeg executable binary
;   frames_per_second : in, optional, type=integer, default=10
;     frame rate in frames per second
;   status : out, optional, type=integer
;     set to a named variable to retrieve the exit status; 0 indicates success,
;     1 indicates an error in the filenames, otherwise an ffmpeg error status
;   error_message : out, optional, type=string/strarr
;     set to a named variable to retrieve an error message if `STATUS` is not 0
;-
pro ucomp_create_mp4, image_filenames, mp4_filename, $
                      executable=executable, $
                      frames_per_second=frames_per_second, $
                      status=status, $
                      error_message=error_message
  compile_opt strictarr

  status = 0L
  error_message = ''

  _executable = mg_default(executable, 'ffmpeg')
  _frames_per_second = mg_default(frames_per_second, 10L)

  n_image_files = n_elements(image_filenames)

  extensions = strarr(n_image_files)
  for f = 0L, n_image_files - 1L do begin
    extensions[f] = strmid(image_filenames[f], $
                           strpos(image_filenames[f], '.', /reverse_search) + 1L)
  endfor

  ; check all extensions are the same
  !null = where(extensions ne extensions[0], n_different)
  if (n_different gt 0L) then begin
    status = 1L
    error_message = 'not all image files of the same extension'
    goto, done
  endif

  tmp_dir = filepath('', /tmp)
  tmp_fmt = mg_format(filepath('ucomp-tmp-%d.%s', root=tmp_dir))

  ; remove previous temporary links if they are still around
  for f = 0L, n_image_files - 1L do begin
    file_delete, string(f, extensions[0], format=tmp_fmt), /allow_nonexistent
  endfor

  ; create links so filenames are in correct order
  for f = 0L, n_image_files - 1L do begin
    file_link, image_filenames[f], string(f, extensions[0], format=tmp_fmt)
  endfor

  video_codec = 'libx264'
  video_bitrate = '2000k'
  n_frames_per_intraframe = 5L   ; number of frames between intraframes

  cmd_format = '(%"%s -r %d ' $
                  + '-i %s.%s ' $
                  + '-y ' $
                  + '-pass %d ' $
                  + '-loglevel error ' $
                  + '-passlogfile %s ' $
                  + '-vcodec %s ' $
                  + '-b:v %s ' $
                  + '-g %d ' $
                  + '%s")'
  for pass = 1, 2 do begin
    cmd = string(_executable, $
                 _frames_per_second, $
                 filepath('ucomp-tmp-%d', root=tmp_dir), $
                 extensions[0], $
                 pass, $
                 filepath('ucomp-pass', root=tmp_dir), $
                 video_codec, $
                 video_bitrate, $
                 n_frames_per_intraframe, $
                 mp4_filename, $
                 format=cmd_format)
    spawn, cmd, result, error_message, exit_status=status
    if (status ne 0L) then break
  endfor

  done:

  ; remove two-pass logfiles
  log_files = file_search(filepath('ucomp-pass-*.log*', root=tmp_dir), $
                          count=n_log_files)
  if (n_log_files gt 0L) then file_delete, log_files, /allow_nonexistent

  ; remove temporary links
  if (n_elements(tmp_fmt) gt 0L && n_elements(n_image_files) gt 0L) then begin
    for f = 0L, n_image_files - 1L do begin
      file_delete, string(f, extensions[0], format=tmp_fmt), /allow_nonexistent
    endfor
  endif
end
