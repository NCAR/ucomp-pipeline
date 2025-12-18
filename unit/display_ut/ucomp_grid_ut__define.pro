; docformat = 'rst'

function ucomp_grid_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_grid']
  

  return, 1
end


pro ucomp_grid_ut__define
  compile_opt strictarr

  define = {ucomp_grid_ut, inherits UCoMPutTestCase}
end
