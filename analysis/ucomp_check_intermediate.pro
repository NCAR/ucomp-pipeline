files = file_search('*/20211015.195202*.fts', count=n_files)
for f = 0L, n_files - 1L do begin
  fits_open, files[f], fcb
  fits_read, fcb, data, header, exten_no=3
  fits_close, fcb
  t = total(data, 3)
  n_dims = size(t, /n_dimensions)
  if (n_dims lt 3) then begin
    print, f + 1, file_dirname(files[f]), mean(t, /nan), format='(%"%d [%s]: %f")'
  endif else begin
    print, f + 1, file_dirname(files[f]), mean(t[*, *, 0], /nan), mean(t[*, *, 1], /nan), format='(%"%d [%s]: %f %f")'
  endelse
endfor

end

; with /= file.numsum

; 1 [01-average_data]: 3334.824951 3185.042725
; 2 [02-camera_correction]: 3335.130127 3184.332520
; 3 [03-apply_dark]: 1126.589111 872.520691
; 4 [04-camera_linearity]: 1126.589111 872.520691
; 5 [05-apply_gain]: 75.235893 69.155037
; 6 [06-continuum_correction]: 75.235893 69.155037
; 7 [07-demodulation]: 549.146912 508.679108
; 8 [08-distortion]: 551.594849 506.743988
; 9 [09-continuum_subtraction]: 43.631207 39.349968
; 10 [10-combine_cameras]: 41.490608
; 11 [11-masking]: 41.490608
; 12 [12-polarimetric_correction]: 41.490608
; 13 [13-sky_transmission]: 41.490608
; 14 [14-promote_header]: 41.490608


; without /= file.numsum (not correct because not normalizing darks/flats)

; 1 [01-average_data]: 53357.199219 50960.683594
; 2 [02-camera_correction]: 53362.082031 50949.320312
; 3 [03-apply_dark]: 51153.574219 48637.464844
; 4 [04-camera_linearity]: 51153.574219 48637.464844
; 5 [05-apply_gain]: 4362.747070 5774.503906
; 6 [06-continuum_correction]: 4362.747070 5774.503906
; 7 [07-demodulation]: 28950.115234 48870.132812
; 8 [08-distortion]: 29719.160156 37621.632812
; 9 [09-continuum_subtraction]: -3423.838379 -7537.123535
; 10 [10-combine_cameras]: -5480.469238
; 11 [11-masking]: -5480.469238
; 12 [12-polarimetric_correction]: -5480.469238
; 13 [13-sky_transmission]: -5480.469238
; 14 [14-promote_header]: -5480.469238
