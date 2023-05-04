; docformat = 'rst'

function ucomp_circfit_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_circfit', $
                            'ucomp_circ'], $
                           /is_function

  return, 1
end


pro ucomp_circfit_ut__define
  compile_opt strictarr

  define = {ucomp_circfit_ut, inherits MGutTestCase}
end
