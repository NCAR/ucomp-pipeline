; docformat = 'rst'

pro ucomp_generate_centering_info, start_date, end_date, $
                                   axis, axis_sign, conversion_factor, $
                                   run=run
  compile_opt strictarr

  axis_name = (['x', 'y'])[axis]
  axis_sign_name = (['neg', 'pos'])[0.5 * (axis_sign + 1)]
  indent = '  '
  wave_region = '1074'
  cutoff_hour = 20

  print, axis_sign gt 0L ? '+' : '-', axis_name, conversion_factor, $
         format='centering %s%s conversion factor: %d'

  filename = string(axis_sign_name, axis_name, conversion_factor, $
                    format='centering-%s-%s-%0.1f.log')
  openw, output_lun, filename, /get_lun

  offset_list = list()

  date = start_date
  repeat begin
    raw_files = file_search(filepath(string(wave_region, format='*.%s.l0.fts'), $
                                     subdir=date, $
                                     root=run->config('raw/basedir')), $
                            count=n_raw_files)
    if (n_raw_files eq 0L) then goto, next

    centering_log = filepath(string(date, format='%s.ucomp.centering.log'), $
                             subdir=ucomp_decompose_date(date), $
                             root=run->config('engineering/basedir'))
    if (~file_test(centering_log, /regular)) then goto, next
    n_lines = file_lines(centering_log)
    if (n_lines eq 0L) then goto, next
    centering_info = strarr(n_lines)
    openr, lun, centering_log, /get_lun
    readf, lun, centering_info
    free_lun, lun

    for f = 0L, n_raw_files - 1L do begin
      raw_basename = file_basename(raw_files[f])
      file_date = strmid(raw_basename, 0, 8)
      hour = long(strmid(raw_basename, 9, 2))
      if (file_date ne date || hour ge cutoff_hour) then continue

      matches = strmatch(centering_info, strmid(raw_basename, 0, 15) + '*')
      match_indices = where(matches, n_matches)
      if (n_matches eq 0L) then continue

      fits_open, raw_files[f], fcb
      fits_read, fcb, data, primary_header, exten_no=0, /header_only
      fits_read, fcb, data, ext_header, exten_no=1, /header_only
      fits_close, fcb

      datatype = ucomp_getpar(ext_header, 'DATATYPE')
      if (datatype ne 'sci') then continue

      occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
      occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')
      sgsrazr = ucomp_getpar(ext_header, 'SGSRAZR')
      sgsdeczr = ucomp_getpar(ext_header, 'SGSDECZR')

      tokens = strsplit(centering_info[match_indices[0]], /extract)
      computed = float(tokens[1:*])
      computed = computed[5L * axis: 5L * axis + 4L]
      if (computed[4] eq 0L and computed[3] lt 3.0) then begin
        case axis of
          0: offset = computed[0] - axis_sign * occulter_x * conversion_factor
          1: offset = computed[0] - axis_sign * occulter_y * conversion_factor
        endcase
        offset_list->add, offset
        printf, output_lun, $
                raw_basename, occulter_x, occulter_y, sgsrazr, sgsdeczr, $
                computed[[0, 1, 3]], offset, $
                format='%s, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.3f, %0.2f'
      endif
    endfor

    next:
    date = ucomp_increment_date(date)
  endrep until (date eq end_date)

  offset_array = offset_list->toArray()
  print, mean(offset_array), stddev(offset_array), format='mean: %0.2f, std dev: %0.3f'

  free_lun, output_lun
  obj_destroy, offset_list
end


; main-level program

start_date = '20210805'
end_date = '20210830'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, subdir=['..', 'config'], root=mg_src_root())

run = ucomp_run(start_date, 'analysis', config_filename)
axis = [0, 1]
axis_sign = [1, -1]
conversion_factor = [100.0, 101.0, 102.0]
for a = 0L, n_elements(axis) - 1L do begin
  for s = 0L, n_elements(axis_sign) - 1L do begin
    for f = 0L, n_elements(conversion_factor) - 1L do begin
      ucomp_generate_centering_info, start_date, end_date, $
                                     axis[a], axis_sign[s], $
                                     conversion_factor[f], $
                                     run=run
    endfor
  endfor
endfor

obj_destroy, run

; centering +x conversion factor: 100
; mean: -5508.92, std dev: 29.437
; centering +x conversion factor: 101
; mean: -5570.36, std dev: 29.660
; centering +x conversion factor: 102
; mean: -5631.80, std dev: 29.882

; centering -x conversion factor: 100
; mean: 6778.95, std dev: 15.130
; centering -x conversion factor: 101
; mean: 6840.39, std dev: 15.352
; centering -x conversion factor: 102
; mean: 6901.83, std dev: 15.573

; centering +y conversion factor: 100
; mean: -622.83, std dev: 63.553
; centering +y conversion factor: 101
; mean: -635.57, std dev: 64.122
; centering +y conversion factor: 102
; mean: -648.31, std dev: 64.691

; centering -y conversion factor: 100
; mean: 1924.49, std dev: 50.697
; centering -y conversion factor: 101
; mean: 1937.23, std dev: 51.265
; centering -y conversion factor: 102
; mean: 1949.97, std dev: 51.833

; Using the following to find the offset:
;
;   center = - conversion_factor * occulter_{x,y} + offset
end
