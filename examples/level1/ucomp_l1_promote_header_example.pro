; main-level example program

date = '20220901'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

basename = '20220901.174648.65.ucomp.1074.l0.fts'
filename = filepath(basename, $
                    subdir=date, $
                    root=run->config('raw/basedir'))

file = ucomp_file(filename, run=run)

ucomp_read_raw_data, file.raw_filename, $
                     primary_header=primary_header, $
                     ext_data=data, $
                     ext_headers=headers, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     all_zero=all_zero

data = reform(data[*, *, *, 0, *])
backgrounds = reform(data[*, *, 0, *])

; ucomp_addpar, primary_header, 'LIN_CRCT', boolean(file.linearity_corrected), $
;               comment='camera linearity corrected', after='OBJECT'

datetime = strmid(file_basename(file.raw_filename), 0, 15)
dmatrix_coefficients = run->get_dmatrix_coefficients(datetime=datetime, info=demod_info)
demod_basename = run->epoch('demodulation_coeffs_basename', datetime=datetime)
ucomp_addpar, primary_header, 'DEMOD_C', demod_basename, $
              comment=string(ucomp_idlsave2dateobs(demod_info.date), $
                             format='demod coeffs created %s'), $
              after='DEMODV'

; cameras = 'both'
; ucomp_addpar, primary_header, 'CAMERAS', cameras, $
;               comment=string(cameras eq 'both' ? 's' : '', $
;                              format='(%"camera%s used in processing")'), $
;               after='DEMOD_C'

ucomp_addpar, primary_header, 'RADIUS', $
              333.195, $
              comment='[px] occulter average radius', $
              format='(F0.3)'

ucomp_l1_promote_header, file, $
                         primary_header, data, headers, backgrounds, $
                         run=run, status=status

obj_destroy, [file, run]

end
