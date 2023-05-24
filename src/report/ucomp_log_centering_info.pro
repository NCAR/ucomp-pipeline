; docformat = 'rst'

;+
; Log the centering information for all the images in the run.
;
; :Params:
;   filename : in, required, type=string
;     output log filename
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_log_centering_info, filename, run=run
  compile_opt strictarr

  mg_log, 'logging centering info...', name=run.logger_name, /info

  files = run->get_files(data_type='sci', count=n_files)
  if (n_files eq 0L) then goto, done

  success_fmt = '%6.2f %6.2f %6.2f %6.2f'
  fail_fmt = '%6.2f %6.2f %6.2f %-6s'

  openw, lun, filename, /get_lun
  for f = 0L, n_files - 1L do begin
    if (files[f].ok) then begin
      rcam_geometry = files[f].rcam_geometry
      tcam_geometry = files[f].tcam_geometry

      ; skip the files that were not processed
      if (~obj_valid(rcam_geometry) || ~obj_valid(tcam_geometry)) then continue

      if (rcam_geometry.occulter_error eq 0) then begin
        rcam_output = string(rcam_geometry.occulter_center, $
                             rcam_geometry.occulter_radius, $
                             rcam_geometry.occulter_chisq, $
                             format=mg_format(success_fmt))
      endif else begin
        rcam_output = string(rcam_geometry.occulter_center, $
                             rcam_geometry.occulter_radius, $
                             'failed', $
                             format=mg_format(fail_fmt))
      endelse

      if (tcam_geometry.occulter_error eq 0) then begin
        tcam_output = string(tcam_geometry.occulter_center, $
                             tcam_geometry.occulter_radius, $
                             tcam_geometry.occulter_chisq, $
                             format=mg_format(success_fmt))
      endif else begin
        tcam_output = string(tcam_geometry.occulter_center, $
                             tcam_geometry.occulter_radius, $
                             'failed', $
                             format=mg_format(fail_fmt))
      endelse

      if (obj_valid(rcam_geometry) && obj_valid(tcam_geometry)) then begin
        printf, lun, $
                files[f].l1_basename, $
                rcam_output, $
                tcam_output, $
                format='(%"%-36s  %s  %s")'
      endif
    endif
  endfor
  free_lun, lun

  done:
end
