; main-level example program

date = '20210725'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

raw_basename = '20210725.232140.72.ucomp.1074.l0.fts'
raw_filename = filepath(raw_basename, $
                        subdir=[date], $
                        root=run->config('raw/basedir'))
ucomp_read_raw_data, raw_filename, $
                     primary_header=primary_header, $
                     ext_data=data, $
                     ext_headers=headers, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     badframes=run.badframes, $
                     all_zero=all_zero, $
                     logger=run.logger_name

sgs_indices = where(stregex(headers[0], '^SGS.*', /boolean), /null)
print, (headers[0])[sgs_indices]
; SGSSCINT=              4.31800 / [arcsec] SGS scintillation seeing estimate
; SGSDIMV =              6.21800 / [V] SGS Dim Mean
; SGSDIMS =            0.0140000 / [V] SGS Dim Std
; SGSSUMV =              6.22000 / [V] SGS Sum Mean
; SGSSUMS =           0.00500000 / [V] SGS Sum Std
; SGSRAV  =             -0.00000 / [V] SGS RA Mean
; SGSRAS  =            0.0120000 / [V] SGS RA Std
; SGSDECV =             -0.00000 / [V] SGS DEC Mean
; SGSDECS =            0.0130000 / [V] SGS DEC Std
; SGSLOOP =              1.00000 / SGS Loop Fraction
; SGSRAZR =       -157.000000000 / [V] SGS RA zero point
; SGSDECZR=                      / [V] SGS DEC zero point

obj_destroy, run

end
