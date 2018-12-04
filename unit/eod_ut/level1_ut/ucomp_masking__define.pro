; docformat = 'rst'

function ucomp_masking_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_masking'

  return, 1
end


pro ucomp_masking_ut__define
  compile_opt strictarr

  define = { ucomp_masking_ut, inherits UCoMPutTestCase }
end