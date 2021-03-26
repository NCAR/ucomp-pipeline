; docformat = 'rst'

;+
; Align images, i.e., distortion correction and centering on center of occulter.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, nx, n_cameras, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_alignment, file, primary_header, data, headers, run=run
  compile_opt strictarr

  ; restore distortion coefficients
  distortion_basename = run->epoch('distortion_basename', datetime=datetime)
  distortion_filename = filepath(distortion_basename, $
                                 subdir='distortion', $
                                 root=run.resource_root)
  restore, filename=distortion_filename

  for p = 0, 3 do begin
    for e = 0L, file.n_extensions - 1L do begin
      data[*, *, p, 0, e] = ucomp_apply_distortion(data[*, *, p, 0, e], dx1_c, dy1_c)
      data[*, *, p, 1, e] = ucomp_apply_distortion(data[*, *, p, 1, e], dx2_c, dy2_c)
    endfor
  endfor

  ; TODO: center on occulter center
  mg_log, 'not implemented', name=run.logger, /warn
end
