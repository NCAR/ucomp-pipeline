; docformat = 'rst'

function ucomp_fshift_ut::test_basic
  compile_opt strictarr

  im = dist(20)
  new_im = ucomp_fshift(im, 4.5, -1.3)

  return, 1
end


function ucomp_fshift_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_fshift'], $
                           /is_function

  return, 1
end


pro ucomp_fshift_ut__define
  compile_opt strictarr

  define = {ucomp_fshift_ut, inherits MGutTestCase}
end
