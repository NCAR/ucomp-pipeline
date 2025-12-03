; docformat = 'rst'

function ucomp_gbu_mask_ut::test_basic
  compile_opt strictarr

  result = ucomp_gbu_mask('vcrosstalk|median_diff')
  standard = [1B, 1B, 1B, 1B, 0B, 1B, 0B]
  assert, array_equal(result, standard), 'incorrect result'

  return, 1
end


function ucomp_gbu_mask_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_gbu_mask'], $
                           /is_function

  return, 1
end


pro ucomp_gbu_mask_ut__define
  compile_opt strictarr

  define = {ucomp_gbu_mask_ut, inherits MGutTestCase}
end
