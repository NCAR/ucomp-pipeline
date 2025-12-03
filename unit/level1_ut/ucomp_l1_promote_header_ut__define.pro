; docformat = 'rst'

function ucomp_l1_promote_header_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l1_promote_header']


  return, 1
end


pro ucomp_l1_promote_header_ut__define
  compile_opt strictarr

  define = {ucomp_l1_promote_header_ut, inherits UCoMPutTestCase}
end
