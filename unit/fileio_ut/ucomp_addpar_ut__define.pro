; docformat = 'rst'

function ucomp_addpar_ut::test_basic
  compile_opt strictarr

  mkhdr, header, 2, [1280, 1024, 4, 2]

  ucomp_addpar, header, 'PI', !pi, comment='value of Pi', format='(%"%0.6f")'
  pi = ucomp_getpar(header, 'PI', comment=comment)

  assert, abs(pi - 3.141593) lt 1e-6, 'wrong value for PI: %f', pi
  assert, comment eq 'value of Pi', 'wrong comment value: %s', comment

  ucomp_addpar, header, 'DPI', !dpi, comment=' value of Pi', format='(%"%0.8f")'
  dpi = ucomp_getpar(header, 'DPI', comment=comment)

  assert, abs(dpi - 3.14159265d) lt 1d-8, 'wrong value for DPI: %f', dpi
  assert, comment eq 'value of Pi', 'wrong comment value: %s', comment

  return, 1
end


function ucomp_addpar_ut::test_null
  compile_opt strictarr

  mkhdr, header, 2, [1280, 1024, 4, 2]

  ucomp_addpar, header, 'TEST', !null, comment='null value'

  value = ucomp_getpar(header, 'TEST', comment=comment)
  assert, n_elements(value) eq 0, 'non-null value'
  assert, comment eq 'null value', 'wrong comment'

  return, 1
end


function ucomp_addpar_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_addpar']

  return, 1
end


pro ucomp_addpar_ut__define
  compile_opt strictarr

  define = {ucomp_addpar_ut, inherits UCoMPutTestCase}
end
