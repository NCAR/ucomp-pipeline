; docformat = 'rst'

function ucomp_loadct_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_loadct']
  

  return, 1
end


pro ucomp_loadct_ut__define
  compile_opt strictarr

  define = {ucomp_loadct_ut, inherits MGutTestCase}
end
