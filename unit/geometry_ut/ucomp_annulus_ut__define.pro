; docformat = 'rst'

function ucomp_annulus_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_annulus'], $
                           /is_function

  return, 1
end


pro ucomp_annulus_ut__define
  compile_opt strictarr

  define = {ucomp_annulus_ut, inherits MGutTestCase}
end
