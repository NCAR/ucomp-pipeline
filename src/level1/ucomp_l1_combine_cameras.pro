; docformat = 'rst'

;+
; Combine cameras and off-band (continuum) subtraction.
;
; After `UCOMP_L1_AVERAGE_DATA`, there should be only a single extension match
; for each wavelength.
; .
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_combine_cameras, file, primary_header, ext_data, ext_headers, $
                              run=run, status=status
  compile_opt strictarr

  status = 0L

  cameras = strlowcase(run->config('combinecameras/use'))
  case cameras of
    'rcam': ext_data = reform(ext_data[*, *, *, 0, *])
    'tcam': ext_data = reform(ext_data[*, *, *, 1, *])
    'both': ext_data = mean(ext_data, dimension=4, /nan)
    else: message, string(cameras, format='(%"invalid combinecameras/use value: ''%s''")')
  endcase

  ucomp_addpar, primary_header, 'CAMERAS', cameras, $
                comment=string(cameras eq 'both' ? 's' : '', $
                               format='(%"camera%s used in processing")')
  done:
end
