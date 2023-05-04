; docformat = 'rst'

function ucomp_gbu_median_diff_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_gbu_median_diff'], $
                           /is_function

  return, 1
end


pro ucomp_gbu_median_diff_ut__define
  compile_opt strictarr

  define = {ucomp_gbu_median_diff_ut, inherits MGutTestCase}
end
