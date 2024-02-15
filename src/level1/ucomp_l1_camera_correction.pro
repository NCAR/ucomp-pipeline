; docformat = 'rst'

;+
; Perform camera corrections.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol, n_camera, n)"
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
pro ucomp_l1_camera_correction, file, $
                                primary_header, $
                                data, headers, $
                                backgrounds, background_headers, $
                                run=run, status=status
  compile_opt strictarr

  status = 0L

  fix_hot_pixels = run->config('cameras/fix_hot_pixels')
  if (~fix_hot_pixels) then begin
    mg_log, 'skipping hot pixel correction', name=run.logger_name, /warn
    goto, done
  endif

  dims = size(data, /dimensions)
  n_polstates = dims[2]
  n_cameras = dims[3]

  for e = 0, n_elements(headers) - 1L do begin
    for c = 0L, n_cameras - 1L do begin
      run->get_hot_pixels, file.gain_mode, c, hot=hot, adjacent=adjacent
      for p = 0L, n_polstates - 1L do begin
        data[*, *, p, c, e] = ucomp_fix_hot(data[*, *, p, c, e], $
                                            hot=hot, $
                                            adjacent=adjacent)
      endfor
    endfor
  endfor

  done:
  ucomp_addpar, primary_header, 'HOTPIXC', boolean(fix_hot_pixels), $
                comment='hot pixels corrected', after='LIN_CRCT'
end
