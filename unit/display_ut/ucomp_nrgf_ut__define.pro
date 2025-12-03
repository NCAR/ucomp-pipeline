; docformat = 'rst'

function ucomp_nrgf_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_nrgf'], $
                           /is_function

  return, 1
end


pro ucomp_nrgf_ut__define
  compile_opt strictarr

  define = {ucomp_nrgf_ut, inherits UCoMPutTestCase}
end
