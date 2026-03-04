; docformat = 'rst'

;+
; Correct camera non-linearity.
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
pro ucomp_l1_camera_linearity, file, $
                               primary_header, $
                               data, headers, $
                               backgrounds, background_headers, $
                               run=run, status=status
  compile_opt strictarr

  status = 0L

  if (~run->config('cameras/apply_linearity')) then begin
    mg_log, 'skipping camera linearity correction', name=run.logger_name, /debug
    goto, done
  endif

  rcam_camera = ucomp_getpar(primary_header, 'RCAMID')
  tcam_camera = ucomp_getpar(primary_header, 'TCAMID')

  exptime = ucomp_getpar(headers[0], 'EXPTIME')

  ; get linearity table for cameras present
  rcam_table = run->get_camera_linearity(rcam_camera, exptime, found=rcam_found)
  if (rcam_found) then begin
    mg_log, 'found camera linearity correction for RCAM: %s', rcam_camera, $
            name=run.logger_name, /debug
  endif else begin
    mg_log, 'no camera linearity correction found for RCAM: %s', rcam_camera, $
            name=run.logger_name, /error
  endelse

  tcam_table = run->get_camera_linearity(tcam_camera, exptime, found=tcam_found)
  if (tcam_found) then begin
    mg_log, 'found camera linearity correction for TCAM: %s', tcam_camera, $
            name=run.logger_name, /debug
  endif else begin
    mg_log, 'no camera linearity correction found for TCAM: %s', tcam_camera, $
            name=run.logger_name, /error
  endelse

  if (~rcam_found || ~tcam_found) then goto, done

  rcam = data[*, *, *, 0, *]
  tcam = data[*, *, *, 1, *]

  rcam = rcam_table[rcam]
  tcam = tcam_table[tcam]

  data[*, *, *, 0, *] = rcam
  data[*, *, *, 1, *] = tcam

  file.linearity_corrected = 1B

  done:
  ucomp_addpar, primary_header, 'LIN_CRCT', boolean(file.linearity_corrected), $
                comment='camera linearity corrected', after='OBJECT'
end
