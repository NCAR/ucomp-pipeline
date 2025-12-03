; docformat = 'rst'

function ucomp_compute_platescale_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_compute_platescale'], $
                           /is_function

  return, 1
end


pro ucomp_compute_platescale_ut__define
  compile_opt strictarr

  define = {ucomp_compute_platescale_ut, inherits UCoMPutTestCase}
end
