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

  ; sort the files in chronological order
  ; basenames = strarr(n_files)
  ; for f = 0L, n_files - 1L do basenames[f] = files[f].l1_basename
  ; ind = sort(basenames)
  ; files = files[ind]

  openw, lun, filename, /get_lun
  for f = 0L, n_files - 1L do begin
    if (files[f].ok && files[f].data_type eq 'sci') then begin
      printf, lun, $
              files[f].l1_basename, $
              files[f].rcam_xcenter, $
              files[f].rcam_ycenter, $
              files[f].rcam_radius, $
              files[f].rcam_chisq, $
              files[f].rcam_error, $
              files[f].tcam_xcenter, $
              files[f].tcam_ycenter, $
              files[f].tcam_radius, $
              files[f].tcam_chisq, $
              files[f].tcam_error, $
              format='(%"%-36s   %0.2f %0.2f %0.2f %0.2f %d    %0.2f %0.2f %0.2f %0.2f %d")'
    endif
  endfor
  free_lun, lun

  done:
end
