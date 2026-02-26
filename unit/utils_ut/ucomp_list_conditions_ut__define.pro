; docformat = 'rst'

function ucomp_list_conditions_ut::test_basic
  compile_opt strictarr

  gbu = ucomp_gbu_conditions()
  conditions_expression = ucomp_list_conditions('0101'B, gbu)

  assert, conditions_expression eq 'sgsloop|max_background', 'incorrect conditions'

  return, 1
end


function ucomp_list_conditions_ut::test_all
  compile_opt strictarr

  gbu = ucomp_gbu_conditions()
  conditions_expression = ucomp_list_conditions('111111111'B, gbu)

  standard = 'sgsloop|sgsdimv|max_background|min_background|vcrosstalk|fit_chisq|median_diff|missingwavelengths|background_diff'
  assert, conditions_expression eq standard, 'incorrect conditions'

  return, 1
end


function ucomp_list_conditions_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_list_conditions'], $
                           /is_function

  return, 1
end


pro ucomp_list_conditions_ut__define
  compile_opt strictarr

  define = {ucomp_list_conditions_ut, inherits UCoMPutTestCase}
end
