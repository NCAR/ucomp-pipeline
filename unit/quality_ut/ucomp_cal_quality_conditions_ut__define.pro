; docformat = 'rst'

function ucomp_cal_quality_conditions_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_cal_quality_conditions'], $
                           /is_function

  return, 1
end


pro ucomp_cal_quality_conditions_ut__define
  compile_opt strictarr

  define = {ucomp_cal_quality_conditions_ut, inherits MGutTestCase}
end
