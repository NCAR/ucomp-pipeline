; docformat = 'rst'

function ucomp_l1_distortion_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l1_distortion']


  return, 1
end


pro ucomp_l1_distortion_ut__define
  compile_opt strictarr

  define = {ucomp_l1_distortion_ut, inherits UCoMPutTestCase}
end
