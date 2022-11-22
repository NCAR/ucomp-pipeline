; docformat = 'rst'

function ucomp_quality_check_time_interval_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_quality_check_time_interval'], $
                           /is_function

  return, 1
end


pro ucomp_quality_check_time_interval_ut__define
  compile_opt strictarr

  define = {ucomp_quality_check_time_interval_ut, inherits MGutTestCase}
end
