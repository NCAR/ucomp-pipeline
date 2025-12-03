; docformat = 'rst'

function ucomp_geometry_ut::test_basic
  compile_opt strictarr

  geometry = {ucomp_geometry}

  return, 1
end


function ucomp_geometry_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_geometry__define']


  return, 1
end


pro ucomp_geometry_ut__define
  compile_opt strictarr

  define = {ucomp_geometry_ut, inherits UCoMPutTestCase}
end
