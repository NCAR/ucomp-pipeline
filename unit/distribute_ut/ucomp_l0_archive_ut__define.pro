; docformat = 'rst'

function ucomp_l0_archive_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l0_archive']


  return, 1
end


pro ucomp_l0_archive_ut__define
  compile_opt strictarr

  define = {ucomp_l0_archive_ut, inherits UCoMPutTestCase}
end
