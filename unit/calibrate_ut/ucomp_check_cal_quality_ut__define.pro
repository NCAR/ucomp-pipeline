; docformat = 'rst'

function ucomp_check_cal_quality_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_check_cal_quality'

  return, 1
end


pro ucomp_check_cal_quality_ut__define
  compile_opt strictarr

  define = {ucomp_check_cal_quality_ut, inherits UCoMPutTestCase}
end
