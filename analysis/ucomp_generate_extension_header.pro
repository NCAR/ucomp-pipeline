; docformat = 'rst'

;+
; Generate a random synthetic extension header.
;
; :Returns:
;   hash
;-
function ucomp_generate_extension_header
  compile_opt strictarr

  h = hash()

  dt_format = '(C(CYI, "-", CMoI02, "-", CDI02, "T", CHI02, ":", CMI02, ":", CSI02))'
  h['datebeg'] = string(systime(/julian), format=dt_format)
  h['dateend'] = string(systime(/julian) + 15.0/24.0/60.0/60.0, format=dt_format)

  h['wavelength'] = 1074.62
  h['caloptic'] = 'out'
  h['darkshut'] = 'out'

  h['polangle'] = 0.0
  h['retangle'] = 0.0

  h['v_lcvr1'] = 10.0 * (randomu(seed, 1))[0]
  h['v_lcvr2'] = 10.0 * (randomu(seed, 1))[0]
  h['v_lcvr3'] = 10.0 * (randomu(seed, 1))[0]
  h['v_lcvr4'] = 10.0 * (randomu(seed, 1))[0]
  h['v_lcvr5'] = 10.0 * (randomu(seed, 1))[0]

  h['lcvr1tmp'] = 100.0 * (randomu(seed, 1))[0]
  h['lcvr2tmp'] = 100.0 * (randomu(seed, 1))[0]
  h['lcvr3tmp'] = 100.0 * (randomu(seed, 1))[0]
  h['lcvr4tmp'] = 100.0 * (randomu(seed, 1))[0]
  h['lcvr5tmp'] = 100.0 * (randomu(seed, 1))[0]
  h['lcvr6tmp'] = 100.0 * (randomu(seed, 1))[0]

  h['bodytemp'] = 100.0 * (randomu(seed, 1))[0]
  h['basetemp'] = 100.0 * (randomu(seed, 1))[0]
  h['racktemp'] = 100.0 * (randomu(seed, 1))[0]
  h['optrtemp'] = 100.0 * (randomu(seed, 1))[0]

  h['sgsdimv'] = (randomu(seed, 1))[0]
  h['sgsdims'] = (randomu(seed, 1))[0]
  h['sgssumv'] = (randomu(seed, 1))[0]
  h['sgssums'] = (randomu(seed, 1))[0]
  h['sgsrav'] = (randomu(seed, 1))[0]
  h['sgsras'] = (randomu(seed, 1))[0]
  h['sgsdecv'] = (randomu(seed, 1))[0]
  h['sgsdecs'] = (randomu(seed, 1))[0]
  h['sgsscint'] = (randomu(seed, 1))[0]
  h['sgsrazr'] = (randomu(seed, 1))[0]
  h['sgsdeczr'] = (randomu(seed, 1))[0]
  h['sgsloop'] = 1

  return, h
end
