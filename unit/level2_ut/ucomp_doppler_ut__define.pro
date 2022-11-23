; docformat = 'rst'

function ucomp_doppler_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_doppler'], $
                           /is_function

  return, 1
end


pro ucomp_doppler_ut__define
  compile_opt strictarr

  define = {ucomp_doppler_ut, inherits MGutTestCase}
end
