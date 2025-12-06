; docformat = 'rst'

function ucomp_nuc2index_ut::test_basic
  compile_opt strictarr

  run = self->get_run()

  nuc_values = run->epoch('nuc_values')

  index = ucomp_nuc2index('normal', values=nuc_values)
  assert, index eq 0, 'incorrect index for normal: %d', index

  index = ucomp_nuc2index('Offset + gain corrected', values=nuc_values)
  assert, index eq 1, 'incorrect index for Offset + gain corrected: %d', index

  index = ucomp_nuc2index('An unexpected value', values=nuc_values)
  assert, index eq 2, 'incorrect index for An unexpected value: %d', index

  obj_destroy, run

  return, 1
end


function ucomp_nuc2index_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_nuc2index'], $
                           /is_function

  return, 1
end


pro ucomp_nuc2index_ut__define
  compile_opt strictarr

  define = {ucomp_nuc2index_ut, inherits UCoMPutTestCase}
end
