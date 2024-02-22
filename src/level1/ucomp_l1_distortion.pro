; docformat = 'rst'

;+
; Apply distortion.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : type=undefined
;     not used in this step
;   background_headers : in, required, type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_distortion, file, $
                         primary_header, $
                         data, headers, $
                         backgrounds, background_headers, $
                         run=run, status=status
  compile_opt strictarr

  status = 0L

  apply_distortion = run->config('cameras/apply_distortion')
  if (~apply_distortion) then begin
    mg_log, 'skipping distortion correction', name=run.logger_name, /warn
  endif

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  run->get_distortion, datetime=datetime, $
                       dx0_c=dx0_c, $
                       dy0_c=dy0_c, $
                       dx1_c=dx1_c, $
                       dy1_c=dy1_c

  for p = 0, 3 do begin
    for e = 0L, file.n_extensions - 1L do begin
      ; we do a reverse here for camera 0 to deal with the image flip
      cam0 = reverse(data[*, *, p, 0, e], 1)
      cam1 = data[*, *, p, 1, e]

      if (apply_distortion) then begin
        cam0 = ucomp_apply_distortion(cam0, dx0_c, dy0_c)
        cam1 = ucomp_apply_distortion(cam1, dx1_c, dy1_c)
      endif

      data[*, *, p, 0, e] = reverse(cam0, 2)
      data[*, *, p, 1, e] = reverse(cam1, 2)
    endfor
  endfor

  done:
  ucomp_addpar, primary_header, 'DISTORTC', boolean(apply_distortion), $
                comment='whether distortion corrected', after='DEMODV'
end
