; docformat = 'rst'

function ucomp_demodulation_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_demodulation'

  return, 1
end


pro ucomp_demodulation_ut__define
  compile_opt strictarr

  define = { ucomp_demodulation_ut, inherits UCoMPutTestCase }
end