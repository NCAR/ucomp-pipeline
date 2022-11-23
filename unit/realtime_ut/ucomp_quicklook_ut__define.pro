; docformat = 'rst'

function ucomp_quicklook_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_quicklook']


  return, 1
end


pro ucomp_quicklook_ut__define
  compile_opt strictarr

  define = {ucomp_quicklook_ut, inherits MGutTestCase}
end
