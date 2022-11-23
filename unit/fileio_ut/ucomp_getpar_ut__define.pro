; docformat = 'rst'

function ucomp_getpar_ut::test_basic
  compile_opt strictarr

  mkhdr, header, 2, [1280, 1024, 4, 2]

  assert, ucomp_getpar(header, 'NAXIS1') eq 1280, 'incorrect NAXIS1'
  assert, ucomp_getpar(header, 'NAXIS2') eq 1024, 'incorrect NAXIS2'
  assert, ucomp_getpar(header, 'NAXIS3') eq 4, 'incorrect NAXIS3'
  assert, ucomp_getpar(header, 'NAXIS4') eq 2, 'incorrect NAXIS4'

  return, 1
end


function ucomp_getpar_ut::test_nan
  compile_opt strictarr

  mkhdr, header, 2, [1280, 1024, 4, 2]
  fxaddpar, header, 'T_AIR', 'NaN', ' Instrument Temp AIR'

  value = ucomp_getpar(header, 'T_AIR', found=found, /float, comment=comment)

  assert, finite(value) eq 0, 'non-NaN value'
  assert, comment eq 'Instrument Temp AIR', 'incorrect comment'

  return, 1
end


function ucomp_getpar_ut::test_float
  compile_opt strictarr

  header = ['SGSDIMM = ''1.000'' / SGS Dim Mean [V]', $
            'SGSDIMS = 2.000 / SGS Dim Std [V]']

  sgsdimm = ucomp_getpar(header, 'SGSDIMM', /float)
  assert, size(sgsdimm, /type) eq 4, 'wrong type for SGSDIMM'
  assert, sgsdimm eq 1.0, 'wrong value for SGSDIMM: %f', sgsdimm

  sgsdims = ucomp_getpar(header, 'SGSDIMS', /float)
  assert, size(sgsdims, /type) eq 4, 'wrong type for SGSDIMS'
  assert, sgsdims eq 2.0, 'wrong value for SGSDIMS: %f', sgsdims

  return, 1
end


function ucomp_getpar_ut::test_missing
  compile_opt strictarr
  @error_is_pass

  header = ['SGSDIMM = ''1.000'' / SGS Dim Mean [V]', $
            'SGSDIMS = 2.000 / SGS Dim Std [V]']
  sgsdimm = ucomp_getpar(header, 'SGSDIMX', /float)

  return, 0
end


function ucomp_getpar_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_getpar'], $
                           /is_function

  return, 1
end


pro ucomp_getpar_ut__define
  compile_opt strictarr

  define = {ucomp_getpar_ut, inherits UCoMPutTestCase}
end
