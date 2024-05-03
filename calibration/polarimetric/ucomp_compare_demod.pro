pro ucomp_compare_demod, date, $
                         t_637, t_789, t_1074, t_1079, $
                         dmx_coeffs_637, $
                         dmx_coeffs_789, $
                         dmx_coeffs_1074, $
                         dmx_coeffs_1079, $
                         demod_matrices_filename, $
                         order
  compile_opt strictarr

  restore, demod_matrices_filename
  d_637 = reform(dmatrices[*, *, order[0]])
  d_789 = reform(dmatrices[*, *, order[1]])
  d_1074 = reform(dmatrices[*, *, order[2]])
  d_1079 = reform(dmatrices[*, *, order[3]])

  ; these are the temperature dependent model demodulation matrices
  temp_d_1074 = dmx_coeffs_1074[*, *, 0] + t_1074 * dmx_coeffs_1074[*, *, 1]
  temp_d_1079 = dmx_coeffs_1079[*, *, 0] + t_1079 * dmx_coeffs_1079[*, *, 1]
  temp_d_789 = dmx_coeffs_789[*, *, 0] + t_789 * dmx_coeffs_789[*, *, 1]
  temp_d_637 = dmx_coeffs_637[*, *, 0] + t_637 * dmx_coeffs_637[*, *, 1]

  print, date, format='Comparison for %s'

  print, '637 nm demodulation matrix'
  print, d_637
  print, '789 nm demodulation matrix'
  print, d_789
  print, '1074 nm demodulation matrix'
  print, d_1074
  print, '1079 nm demodulation matrix'
  print, d_1079

  ; percentage difference of model from measured demodulation matrices
  print, '637: percentage difference of model from measured demodulation matrices'
  print, (d_637 - temp_d_637) / d_637  * 100.0

  print, '789: percentage difference of model from measured demodulation matrices'
  print, (d_789 - temp_d_789) / d_789  * 100.0

  print, '1074: percentage difference of model from measured demodulation matrices'
  print, (d_1074 - temp_d_1074) / d_1074  * 100.0

  print, '1079: percentage difference of model from measured demodulation matrices'
  print, (d_1079 - temp_d_1079) / d_1079  * 100.0
end

; main-level example program

restore, '/home/mgalloy/projects/ucomp-pipeline/resource/demodulation/ucomp.1074.dmx-temp-coeffs.1.sav', /verbose
dmx_coeffs_1074 = dmx_coeffs

restore, '/home/mgalloy/projects/ucomp-pipeline/resource/demodulation/ucomp.1079.dmx-temp-coeffs.1.sav', /verbose
dmx_coeffs_1079 = dmx_coeffs

restore, '/home/mgalloy/projects/ucomp-pipeline/resource/demodulation/ucomp.637.dmx-temp-coeffs.1.sav', /verbose
dmx_coeffs_637 = dmx_coeffs

restore, '/home/mgalloy/projects/ucomp-pipeline/resource/demodulation/ucomp.789.dmx-temp-coeffs.1.sav', /verbose
dmx_coeffs_789 = dmx_coeffs

sav_format = '/home/mgalloy/projects/UCOMP/Integration and Testing/Polarimetric Calibration/Results.mine/%s.sav'

date = '20221002'
ucomp_compare_demod, date, $
                     32.8840, 32.7430, 32.9200, 32.8280, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221015'
ucomp_compare_demod, date, $
                     32.7500, 32.7490, 32.8210, 32.8940, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221016'
ucomp_compare_demod, date, $
                     32.7800, 32.7560, 32.7920, 32.7200, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221017'
ucomp_compare_demod, date, $
                     32.7190, 32.7830, 32.7560, 32.7990, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221018'
ucomp_compare_demod, date, $
                     32.8210, 32.7160, 32.7580, 32.7150, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221020'
ucomp_compare_demod, date, $
                     32.7270, 32.8010, 32.8140, 32.8230, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221022'
ucomp_compare_demod, date, $
                     32.8130, 32.7610, 32.7880, 32.7100, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221023'
ucomp_compare_demod, date, $
                     32.7710, 32.8230, 32.7980, 32.7550, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221024'
ucomp_compare_demod, date, $
                     32.7010, 32.8520, 32.7500, 32.7470, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221025'
ucomp_compare_demod, date, $
                     32.7030, 32.7540, 32.7240, 32.7970, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

date = '20221026'
ucomp_compare_demod, date, $
                     32.7730, 32.7350, 32.8330, 32.7040, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 2, 3, 4]

; this is the comparison for the day after the eclipse
date = '20240409'
ucomp_compare_demod, date, $
                     33.0900, 32.8480, 32.8620, 32.9660, $
                     dmx_coeffs_637, $
                     dmx_coeffs_789, $
                     dmx_coeffs_1074, $
                     dmx_coeffs_1079, $
                     string(date, format=sav_format), $
                     [0, 1, 2, 3]


end
