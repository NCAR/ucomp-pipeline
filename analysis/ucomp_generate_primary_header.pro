; docformat = 'rst'


;+
; Generate a random synthetic primary header.
;
; :Returns:
;   hash
;-
function ucomp_generate_primary_header
  compile_opt strictarr

  primary_hash = hash()

  dt_format = '(C(CYI, "-", CMoI02, "-", CDI02, "T", CHI02, ":", CMI02, ":", CSI02))'
  primary_hash['dateobs'] = string(systime(/julian), format=dt_format)
  primary_hash['dateend'] = string(systime(/julian) + 15.0/24.0/60.0/60.0, format=dt_format)

  primary_hash['wave_region'] = '1074'
  primary_hash['datatype'] = 'sci'
  primary_hash['exptime'] = 1.0e-6
  primary_hash['numsum'] = 4

  primary_hash['o1nd'] = 'out'
  primary_hash['cover'] = 'out'

  primary_hash['occulter_id'] = '000001'
  primary_hash['occulter'] = 'in'
  primary_hash['occulter_x'] = 430000
  primary_hash['occulter_y'] = 86000

  primary_hash['opal_id'] = '0000001'
  primary_hash['opal'] = 'out'

  return, primary_hash
end
