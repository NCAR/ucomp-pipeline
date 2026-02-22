; docformat = 'rst'

function ucomp_integrate_ut::test_basic
  compile_opt strictarr

  data = findgen(10, 10, 3)
  integrated = ucomp_integrate(data)
  standard = 0.5 * total(data, 3, /preserve_type)

  assert, array_equal(integrated, standard), 'incorrect value'

  return, 1
end


function ucomp_integrate_ut::test_center_index
  compile_opt strictarr

  data = findgen(10, 10, 5)
  integrated = ucomp_integrate(data, indices=[0, 1, 2])
  standard = 0.5 * total(data[*, *, 0:2], 3, /preserve_type)

  assert, array_equal(integrated, standard), 'incorrect value'

  return, 1
end


function ucomp_integrate_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_integrate'], $
                           /is_function

  return, 1
end


pro ucomp_integrate_ut__define
  compile_opt strictarr

  define = {ucomp_integrate_ut, inherits UCoMPutTestCase}
end
