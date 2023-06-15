; docformat = 'rst'

;+
; Perform polarimetric correction.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol_states, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_exts)"
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
pro ucomp_l1_polarimetric_correction, file, $
                                      primary_header, $
                                      data, headers, $
                                      backgrounds, background_headers, $
                                      run=run, status=status
  compile_opt strictarr

  status = 0L

  for e = 0L, n_elements(headers) - 1L do begin
    q = data[*, *, 1, e]
    u = data[*, *, 2, e]
    ucomp_polarimetric_transform, q, u, file.p_angle, new_q=new_q, new_u=new_u
    data[*, *, 1, e] = new_q
    data[*, *, 2, e] = new_u
  endfor
end
