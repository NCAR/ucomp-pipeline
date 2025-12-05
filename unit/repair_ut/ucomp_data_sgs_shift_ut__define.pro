; docformat = 'rst'

function ucomp_data_sgs_shift_ut::test_basic
  compile_opt strictarr

  mkhdr, header, dist(1280, 1024), /extend, /image
  after = 'GCOUNT'

  ucomp_addpar, header, 'SGSDIMV', 4.318, after=after
  ucomp_addpar, header, 'SGSDIMS', 6.218, after=after
  ucomp_addpar, header, 'SGSSUMV', 0.014, after=after
  ucomp_addpar, header, 'SGSSUMS', 6.220, after=after
  ucomp_addpar, header, 'SGSRAV', 0.005, after=after
  ucomp_addpar, header, 'SGSRAS', -0.000, after=after
  ucomp_addpar, header, 'SGSDECV', 0.012, after=after
  ucomp_addpar, header, 'SGSDECS', -0.000, after=after
  ucomp_addpar, header, 'SGSLOOP', 0.013, after=after
  ucomp_addpar, header, 'SGSRAZR', 1.000, after=after
  ucomp_addpar, header, 'SGSDECZR', -157.000, after=after

  ext_headers = list()
  ext_headers->add, header

  ucomp_data_sgs_shift, primary_header, ext_data, ext_headers

  header = ext_headers[0]

  sgsscint = ucomp_getpar(header, 'SGSSCINT')
  assert, sgsscint eq 4.318, 'SGSSCINT incorrect'

  sgsdimv = ucomp_getpar(header, 'SGSDIMV')
  assert, sgsdimv eq 6.218, 'SGSDIMV incorrect'

  sgsdims = ucomp_getpar(header, 'SGSDIMS')
  assert, sgsdims eq 0.014, 'SGSDIMS incorrect'

  sgssumv = ucomp_getpar(header, 'SGSSUMV')
  assert, sgssumv eq 6.220, 'SGSSUMV incorrect'

  sgssums = ucomp_getpar(header, 'SGSSUMS')
  assert, sgssums eq 0.005, 'SGSSUMS incorrect'

  sgsrav = ucomp_getpar(header, 'SGSRAV')
  assert, sgsrav eq -0.000, 'SGSRAV incorrect'

  sgsras = ucomp_getpar(header, 'SGSRAS')
  assert, sgsras eq 0.012, 'SGSRAS incorrect'

  sgsdecv = ucomp_getpar(header, 'SGSDECV')
  assert, sgsdecv eq -0.000, 'SGSDECV incorrect'

  sgsdecs = ucomp_getpar(header, 'SGSDECS')
  assert, sgsdecs eq 0.013, 'SGSDECS incorrect'

  sgsloop = ucomp_getpar(header, 'SGSLOOP')
  assert, sgsloop eq 1.000, 'SGSLOOP incorrect'

  sgsrazr = ucomp_getpar(header, 'SGSRAZR', found=sgsrazr_found)
  assert, sgsrazr eq -157.000, 'SGSRAZR incorrect'

  sgsdeczr = ucomp_getpar(header, 'SGSDECZR')
  assert, n_elements(sgsdeczr) eq 0, 'SGSDECZR incorrect'

  obj_destroy, ext_headers

  return, 1
end


function ucomp_data_sgs_shift_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_sgs_shift']
  

  return, 1
end


pro ucomp_data_sgs_shift_ut__define
  compile_opt strictarr

  define = {ucomp_data_sgs_shift_ut, inherits UCoMPutTestCase}
end
