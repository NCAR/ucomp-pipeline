; docformat = 'rst'

function ucomp_reprocess_cleanup_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_reprocess_cleanup']


  return, 1
end


pro ucomp_reprocess_cleanup_ut__define
  compile_opt strictarr

  define = {ucomp_reprocess_cleanup_ut, inherits UCoMPutTestCase}
end
