; 20220113.230203.43.ucomp.l0.fts
;   - 10 ms
;   - normal
;   - 4069.8376465
;
; 20220113.215511.02.ucomp.l0.fts
;   - 80 ms
;   - normal
;   - 547.3812866

f = '20220112.212031.77.ucomp.l0.fts'
print, f
fits_open, f, fcb
fits_read, fcb, data, primary_header, exten_no=0
print, sxpar(primary_header, 'GAIN'), format='GAIN mode: %s'
print, sxpar(primary_header, 'RCAMNUC'), format='RCAMNUC: %s'
print, sxpar(primary_header, 'TCAMNUC'), format='TCAMNUC: %s'
field_mask = ucomp_field_mask(1280, 1024, 750.0)
field_mask_indices = where(field_mask, /null)
for e = 1, fcb.nextend do begin
    fits_read, fcb, data, header, exten_no=e
    print, e, format='Extension: %d'
    data = mean(data, dimension=3)
    rcam_image = data[*, *, 0]
    tcam_image = data[*, *, 1]
    print, sxpar(header, 'NUMSUM'), format='  NUMSUM: %d'
    print, median(rcam_image[field_mask_indices]), format='  RCAM MEDIAN: %0.1f'
    print, median(tcam_image[field_mask_indices]), format='  TCAM MEDIAN: %0.1f'
    print, sxpar(header, 'EXPTIME'), format='  EXPTIME: %0.1f'
endfor
fits_close, fcb

f = '20220113.230203.43.ucomp.l0.fts'
print, f
fits_open, f, fcb
fits_read, fcb, data, primary_header, exten_no=0
print, sxpar(primary_header, 'GAIN'), format='GAIN mode: %s'
print, sxpar(primary_header, 'RCAMNUC'), format='RCAMNUC: %s'
print, sxpar(primary_header, 'TCAMNUC'), format='TCAMNUC: %s'
field_mask = ucomp_field_mask(1280, 1024, 750.0)
field_mask_indices = where(field_mask, /null)
for e = 1, fcb.nextend do begin
    fits_read, fcb, data, header, exten_no=e
    print, e, format='Extension: %d'
    data = mean(data, dimension=3)
    rcam_image = data[*, *, 0]
    tcam_image = data[*, *, 1]
    print, sxpar(header, 'NUMSUM'), format='  NUMSUM: %d'
    print, median(rcam_image[field_mask_indices]), format='  RCAM MEDIAN: %0.1f'
    print, median(tcam_image[field_mask_indices]), format='  TCAM MEDIAN: %0.1f'
    print, sxpar(header, 'EXPTIME'), format='  EXPTIME: %0.1f'
endfor
fits_close, fcb

f = '20220113.215511.02.ucomp.l0.fts'
print, f
fits_open, f, fcb
fits_read, fcb, data, primary_header, exten_no=0
print, sxpar(primary_header, 'GAIN'), format='GAIN mode: %s'
print, sxpar(primary_header, 'RCAMNUC'), format='RCAMNUC: %s'
print, sxpar(primary_header, 'TCAMNUC'), format='TCAMNUC: %s'
field_mask = ucomp_field_mask(1280, 1024, 750.0)
field_mask_indices = where(field_mask, /null)
for e = 1, fcb.nextend do begin
    fits_read, fcb, data, header, exten_no=e
    print, e, format='Extension: %d'
    data = mean(data, dimension=3)
    rcam_image = data[*, *, 0]
    tcam_image = data[*, *, 1]
    print, sxpar(header, 'NUMSUM'), format='  NUMSUM: %d'
    print, median(rcam_image[field_mask_indices]), format='  RCAM MEDIAN: %0.1f'
    print, median(tcam_image[field_mask_indices]), format='  TCAM MEDIAN: %0.1f'
    print, sxpar(header, 'EXPTIME'), format='  EXPTIME: %0.1f'
endfor
fits_close, fcb

end
