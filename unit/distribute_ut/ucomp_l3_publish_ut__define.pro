; docformat = 'rst'

function ucomp_l3_publish_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l3_publish']
  

  return, 1
end


pro ucomp_l3_publish_ut__define
  compile_opt strictarr

  define = {ucomp_l3_publish_ut, inherits UCoMPutTestCase}
end
