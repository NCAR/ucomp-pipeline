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

  files = run->get_files(count=n_files)
  if (n_files eq 0L) then goto, done

  openw, lun, filename, /get_lun
  for f = 0L, n_files - 1L do begin
    if (files[f].ok) then begin
      printf, lun, $
              files[f].l1_basename, $
              files[f].rcam_xcenter, $
              files[f].rcam_ycenter, $
              files[f].rcam_radius, $
              files[f].tcam_xcenter, $
              files[f].tcam_ycenter, $
              files[f].tcam_radius, $
              format='(%"%-30s   %0.2f %0.2f %0.2f   %0.2f %0.2f %0.2f")'
    endif
  endfor
  free_lun, lun

  done:
end
