; docformat = 'rst'

function ucomp_gbu_max_background_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_gbu_max_background'], $
                           /is_function

  return, 1
end


pro ucomp_gbu_max_background_ut__define
  compile_opt strictarr

  define = {ucomp_gbu_max_background_ut, inherits UCoMPutTestCase}
end
