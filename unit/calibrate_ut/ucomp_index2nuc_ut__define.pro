; docformat = 'rst'

function ucomp_index2nuc_ut::test_basic
  compile_opt strictarr

  run = self->get_run()

  nuc_values = run->epoch('nuc_values')

  nuc = ucomp_index2nuc(0, values=nuc_values)
  assert, nuc eq 'normal', 'incorrect NUC for index %d: %s', index, nuc
  nuc = ucomp_index2nuc(1, values=nuc_values)
  assert, nuc eq 'Offset + gain corrected', 'incorrect NUC for index %d: %s', index, nuc

  obj_destroy, run

  return, 1
end


function ucomp_index2nuc_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_index2nuc'], $
                           /is_function

  return, 1
end


pro ucomp_index2nuc_ut__define
  compile_opt strictarr

  define = {ucomp_index2nuc_ut, inherits UCoMPutTestCase}
end
