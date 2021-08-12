; docformat = 'rst'

;+
; Perform geometric operations on the images, i.e., distortion correction,
; centering images on center of occulter, combining the cameras, and rotating
; them to be North up.
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
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_alignment, file, primary_header, data, headers, run=run, status=status
  compile_opt strictarr

  status = 0L

  ; distortion correction

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  run->get_distortion, datetime=datetime, $
                       dx1_c=dx1_c, $
                       dy1_c=dy1_c, $
                       dx2_c=dx2_c, $
                       dy2_c=dy2_c


  ; TODO: the C implementation
  ; data = ucomp_quick_distortion(data, dx1_c, dy1_c, dx2_c, dy2_c)

  ; for p = 0, 3 do begin
  ;   for e = 0L, file.n_extensions - 1L do begin
  ;     data[*, *, p, 0, e] = ucomp_apply_distortion(data[*, *, p, 0, e], dx1_c, dy1_c)
  ;     data[*, *, p, 1, e] = ucomp_apply_distortion(data[*, *, p, 1, e], dx2_c, dy2_c)
  ;   endfor
  ; endfor

  ; center images on occulter center

  n_pol_states = 4L
  dims = size(data, /dimensions)

  occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
  occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
  dradius = 20.0

  rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
  rcam_index = file->get_occulter_finding_extension(0) - 1L
  rcam_im = total(data[*, *, *, 0, rcam_index], 3) / n_pol_states
  rcam_geometry = ucomp_find_occulter(rcam_im, $
                                      center_guess=rcam_center_guess, $
                                      radius_guess=radius_guess, $
                                      dradius=dradius, $
                                      error=rcam_error, chisq=rcam_chisq)
  file.rcam_xcenter = rcam_geometry[0]
  file.rcam_ycenter = rcam_geometry[1]
  file.rcam_radius = rcam_geometry[2]
  file.rcam_chisq = rcam_chisq
  file.rcam_error = rcam_error

  tcam_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)
  tcam_index = file->get_occulter_finding_extension(0) - 1L
  tcam_im = total(data[*, *, *, 1, tcam_index], 3) / n_pol_states
  tcam_geometry = ucomp_find_occulter(tcam_im, $
                                      center_guess=tcam_center_guess, $
                                      radius_guess=radius_guess, $
                                      dradius=dradius, $
                                      error=tcam_error, chisq=tcam_chisq)
  file.tcam_xcenter = tcam_geometry[0]
  file.tcam_ycenter = tcam_geometry[1]
  file.tcam_radius = tcam_geometry[2]
  file.tcam_chisq = tcam_chisq
  file.tcam_error = tcam_error

;   for p = 0, n_pol_states - 1L do begin
;     for e = 0L, file.n_extenions - 1L do begin
;       data[*, *, p, 0, e] = ucomp_fshift(data[*, *, p, 0, e], $
;                                          (dims[0] - 1.0) / 2.0 - rcam_geometry[0], $
;                                          (dims[1] - 1.0) / 2.0 - rcam_geometry[1], $
;                                          interp=1)
;
;       data[*, *, p, 1, e] = ucomp_fshift(data[*, *, p, 1, e], $
;                                          (dims[0] - 1.0) / 2.0 - tcam_geometry[0], $
;                                          (dims[1] - 1.0) / 2.0 - tcam_geometry[1], $
;                                          interp=1)
; 
;       ; RCAM is flipped both vertically and horizontally, while TCAM is flipped
;       ; only vertically
;       data[*, *, p, 0, e] = reverse(reverse(data[*, *, p, 0, e], 1), 2)
;       data[*, *, p, 1, e] = reverse(data[*, *, p, 1, e], 2)
;     endfor
;   endfor
end
