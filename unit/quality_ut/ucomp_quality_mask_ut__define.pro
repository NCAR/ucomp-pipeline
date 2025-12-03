; docformat = 'rst'

function ucomp_quality_mask_ut::test_cal
  compile_opt strictarr

  run = self->get_run()

  result = ucomp_quality_mask('datatype|contin', /calibration, run=run)
  standard = [1B, 0B, 1B, 1B, 1B, 1B, 0B]
  assert, array_equal(result, standard), 'incorrect result'

  obj_destroy, run

  return, 1
end


function ucomp_quality_mask_ut::test_sci
  compile_opt strictarr

  run = self->get_run()
  
  result = ucomp_quality_mask('datatype|contin', run=run)
  standard = [1B, 1B, 0B, 1B, 1B, 1B, 1B, 1B, 1B, 1B, 0B]
  assert, array_equal(result, standard), 'incorrect result'

  obj_destroy, run
  
  return, 1
end


function ucomp_quality_mask_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_quality_mask'], $
                           /is_function

  return, 1
end


pro ucomp_quality_mask_ut__define
  compile_opt strictarr

  define = {ucomp_quality_mask_ut, inherits UCoMPutTestCase}
end
