; docformat = 'rst'

function ucomp_assert_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_assert']


  return, 1
end


pro ucomp_assert_ut__define
  compile_opt strictarr

  define = {ucomp_assert_ut, inherits UCoMPutTestCase}
end
