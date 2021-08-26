; docformat = 'rst'

;+
; Center the images on center of occulter in the correct orientation, i.e.,
; rotate them to be North up.
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

  ; center images on occulter center

  n_pol_states = 4L
  dims = size(data, /dimensions)

  occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
  occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
  dradius = 25.0

  post_angle_guess = run->epoch('post_angle_guess')
  post_angle_tolerance = run->epoch('post_angle_tolerance')

  rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
  rcam_ext = file->get_occulter_finding_extension(0)
  if (n_elements(rcam_ext) eq 0L) then begin
    status = 1L
    goto, done
  endif
  rcam_index = rcam_ext - 1L
  rcam_im = total(data[*, *, *, 0, rcam_index], 3) / n_pol_states
  file.rcam_geometry = ucomp_find_geometry(rcam_im, $
                                           center_guess=rcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance)
  tcam_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)
  tcam_ext = file->get_occulter_finding_extension(1)
  if (n_elements(tcam_ext) eq 0L) then begin
    status = 1L
    goto, done
  endif
  tcam_index = tcam_ext - 1L
  tcam_im = total(data[*, *, *, 1, tcam_index], 3) / n_pol_states
  file.tcam_geometry = ucomp_find_geometry(tcam_im, $
                                           center_guess=tcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance)

  ; TODO: put geometry info in the primary header after RCAMNUC

  for p = 0, n_pol_states - 1L do begin
    for e = 0L, file.n_extenions - 1L do begin
      data[*, *, p, 0, e] = ucomp_fshift(data[*, *, p, 0, e], $
                                         (dims[0] - 1.0) / 2.0 - rcam_geometry[0], $
                                         (dims[1] - 1.0) / 2.0 - rcam_geometry[1], $
                                         interp=1)

      data[*, *, p, 1, e] = ucomp_fshift(data[*, *, p, 1, e], $
                                         (dims[0] - 1.0) / 2.0 - tcam_geometry[0], $
                                         (dims[1] - 1.0) / 2.0 - tcam_geometry[1], $
                                         interp=1)

      ; RCAM is flipped both vertically and horizontally, while TCAM is flipped
      ; only vertically
      data[*, *, p, 0, e] = reverse(reverse(data[*, *, p, 0, e], 1), 2)
      data[*, *, p, 1, e] = reverse(data[*, *, p, 1, e], 2)
    endfor
  endfor

  ; TODO: rotate the images North up

  done:
end
