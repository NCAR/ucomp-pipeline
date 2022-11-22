; docformat = 'rst'

function ucomp_find_post_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_find_post'], $
                           /is_function

  return, 1
end


pro ucomp_find_post_ut__define
  compile_opt strictarr

  define = {ucomp_find_post_ut, inherits MGutTestCase}
end
