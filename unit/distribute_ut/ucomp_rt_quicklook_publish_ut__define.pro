; docformat = 'rst'

function ucomp_rt_quicklook_publish_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_rt_quicklook_distribute']
  

  return, 1
end


pro ucomp_rt_quicklook_publish_ut__define
  compile_opt strictarr

  define = {ucomp_rt_quicklook_publish_ut, inherits UCoMPutTestCase}
end
