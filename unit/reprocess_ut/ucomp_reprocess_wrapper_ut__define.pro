; docformat = 'rst'

function ucomp_reprocess_wrapper_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_reprocess_wrapper']


  return, 1
end


pro ucomp_reprocess_wrapper_ut__define
  compile_opt strictarr

  define = {ucomp_reprocess_wrapper_ut, inherits MGutTestCase}
end
