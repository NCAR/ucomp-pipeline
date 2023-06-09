; docformat = 'rst'

;+
; Combine cameras and off-band (continuum) subtraction.
;
; After `UCOMP_L1_AVERAGE_DATA`, there should be only a single extension match
; for each wavelength.
; .
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images, removes `n_cameras` dimension on output
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_combine_cameras, file, $
                              primary_header, ext_data, ext_headers, backgrounds, $
                              run=run, status=status
  compile_opt strictarr

  status = 0L

  cameras = strlowcase(run->config('cameras/use'))
  ucomp_addpar, primary_header, 'CAMERAS', cameras, $
                comment=string(cameras eq 'both' ? 's' : '', $
                               format='(%"camera%s used in processing")'), $
                after='DEMOD_C'

  occulter_radius = (file.rcam_geometry.radius + file.tcam_geometry.radius) / 2.0

  for e = 0L, n_elements(ext_headers) - 1L do begin
    ; use intensity for each camera for this extension
    rcam = reform(ext_data[*, *, 0, 0, e])
    tcam = reform(ext_data[*, *, 0, 1, e])
    camera_correlation = ucomp_centering_metric(rcam, tcam, occulter_radius, $
                                                difference_median=difference_median, $
                                                rcam_median=rcam_median, $
                                                tcam_median=tcam_median)

    ext_header = ext_headers[e]

    after = 'FLATDN'
    ucomp_addpar, ext_header, 'CAMCORR', camera_correlation, $
                  comment='correlation between camera images', $
                  after=after
    ucomp_addpar, ext_header, 'CAMDIFF', difference_median, $
                  comment='median of absolute difference between camera images', $
                  after=after
    ucomp_addpar, ext_header, 'RCAMMED', rcam_median, $
                  comment='median value in test annulus in RCAM', $
                  after=after
    ucomp_addpar, ext_header, 'TCAMMED', tcam_median, $
                  comment='median value in test annulus in TCAM', $
                  after=after

    ext_headers[e] = ext_header
  endfor

  case cameras of
    'rcam': begin
        ext_data = reform(ext_data[*, *, *, 0, *])
        backgrounds = reform(backgrounds[*, *, 0, *])
      end
    'tcam': begin
        ext_data = reform(ext_data[*, *, *, 1, *])
        backgrounds = reform(backgrounds[*, *, 1, *])
      end
    'both': begin
        ext_data = mean(ext_data, dimension=4, /nan)
        backgrounds = mean(backgrounds, dimension=3, /nan)
      end
    else: message, string(cameras, format='(%"invalid combinecameras/use value: ''%s''")')
  endcase

  done:
end
