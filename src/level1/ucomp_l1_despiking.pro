; docformat = 'rst'

;+
; Remove spikes.
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
;   backgrounds : out, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_despiking, file, $
                        primary_header, $
                        data, headers, $
                        backgrounds, background_headers, $
                        run=run, status=status
  compile_opt strictarr

  status = 0L

  dims = size(data, /dimensions)
  n_columns    = dims[0]
  n_rows       = dims[1]
  n_polstates  = dims[2]
  n_cameras    = dims[3]
  n_extensions = n_elements(headers)

  ; TODO: this should be in a config file and probably depends on wave region
  max_difference = 10.0

  mask = bytarr(n_columns, n_rows, n_cameras, n_extensions)
  for e = 0L, n_extensions - 1L do begin
    for c = 0L, n_cameras - 1L do begin
      d = data[*, *, 0, c, e]
      s = smooth(d, 3, /edge_zero)
      mask[*, *, c, e] = abs(s - d) gt max_difference
    endfor
  endfor

  bad_pixel_indices = where(mask, n_bad_pixels)
  mg_log, '%d spiked pixels', n_bad_pixels, name=run.logger_name, /warn

  done:
end
