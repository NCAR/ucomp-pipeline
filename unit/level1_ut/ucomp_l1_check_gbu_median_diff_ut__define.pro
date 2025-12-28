; docformat = 'rst'

function ucomp_l1_check_gbu_median_diff_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l1_check_gbu_median_diff']
  

  return, 1
end


pro ucomp_l1_check_gbu_median_diff_ut__define
  compile_opt strictarr

  define = {ucomp_l1_check_gbu_median_diff_ut, inherits UCoMPutTestCase}
end
