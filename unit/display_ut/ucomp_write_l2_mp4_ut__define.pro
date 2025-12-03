; docformat = 'rst'

function ucomp_write_l2_mp4_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_write_l2_mp4']


  return, 1
end


pro ucomp_write_l2_mp4_ut__define
  compile_opt strictarr

  define = {ucomp_write_l2_mp4_ut, inherits UCoMPutTestCase}
end
