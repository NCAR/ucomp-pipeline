; docformat = 'rst'

;+
; Log the centering information for all the images in the run.
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

  ; sort the files in chronological order
  ; basenames = strarr(n_files)
  ; for f = 0L, n_files - 1L do basenames[f] = files[f].l1_basename
  ; ind = sort(basenames)
  ; files = files[ind]

  openw, lun, filename, /get_lun
  for f = 0L, n_files - 1L do begin
    if (files[f].ok) then begin
      rcam_geometry = files[f].rcam_geometry
      tcam_geometry = files[f].tcam_geometry
      if (obj_valid(rcam_geometry) && obj_valid(tcam_geometry)) then begin
        printf, lun, $
                files[f].l1_basename, $
                rcam_geometry.occulter_center, $
                rcam_geometry.occulter_radius, $
                rcam_geometry.occulter_chisq, $
                rcam_geometry.occulter_error, $
                tcam_geometry.occulter_center, $
                tcam_geometry.occulter_radius, $
                tcam_geometry.occulter_chisq, $
                tcam_geometry.occulter_error, $
                format='(%"%-36s   %0.2f %0.2f %0.2f %0.2f %d    %0.2f %0.2f %0.2f %0.2f %d")'
      endif
    endif
  endfor
  free_lun, lun

  done:
end
