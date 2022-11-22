; docformat = 'rst'

function ucomp_eval_surf_ut::test_empty
  compile_opt strictarr

  result = ucomp_eval_surf(fltarr(5, 5), dindgen(5), dindgen(5))
  assert, array_equal(result, fltarr(5, 5)), 'incorrect result'

  return, 1
end

function ucomp_eval_surf_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_eval_surf'], $
                           /is_function

  return, 1
end


function ucomp_eval_surf_ut::test_one
  compile_opt strictarr

  x = fltarr(5, 5)
  x[0, 0] = 1.0

  result = ucomp_eval_surf(x, dindgen(5), dindgen(5))
  assert, array_equal(result, fltarr(5, 5) + 1.0), 'incorrect result'

  return, 1
end


pro ucomp_eval_surf_ut__define
  compile_opt strictarr

  define = {ucomp_eval_surf_ut, inherits MGutTestCase}
end
