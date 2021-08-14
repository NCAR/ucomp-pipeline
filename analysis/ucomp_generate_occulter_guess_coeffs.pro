; docformat = 'rst'

;+
; Determine optimal occulter center guess for a given OCCLTR-{X,Y} value.
;
; :Params:
;   filename : in, required, type=string
;     filename of file containing OCCLTR-{X,Y} value, cam 0 offset, and
;     cam0_offset
;-
pro ucomp_generate_occulter_guess_coeffs, filename
  compile_opt strictarr

  n_lines = file_lines(filename)
  occulter = fltarr(n_lines - 1L)
  cam0_offset = fltarr(n_lines - 1L)
  cam1_offset = fltarr(n_lines - 1L)
  openr, lun, filename, /get_lun
  line = ''
  readf, lun, line
  for i = 0L, n_lines - 2L do begin
    readf, lun, line
    tokens = strsplit(line, ' ,', /extract)
    occulter[i] = float(tokens[0])
    cam0_offset[i] = float(tokens[1])
    cam1_offset[i] = float(tokens[2])
  endfor
  free_lun, lun

  cam0_coeffs = linfit(occulter, cam0_offset, chisq=cam0_chisq)
  cam1_coeffs = linfit(occulter, cam1_offset, chisq=cam1_chisq)
  print, cam0_coeffs, format='camera 0 coeffs: %0.4f + %0.4f * occulter'
  print, cam0_chisq, format='camera 0 chi-squared: %0.2f'
  print, cam1_coeffs, format='camera 1 coeffs: %0.4f + %0.4f * occulter'
  print, cam1_chisq, format='camera 1 chi-squared: %0.2f'
end


; main-level example program

print, 'x'
ucomp_generate_occulter_guess_coeffs, 'occulter-x.log'
print, 'y'
ucomp_generate_occulter_guess_coeffs, 'occulter-y.log'

end
