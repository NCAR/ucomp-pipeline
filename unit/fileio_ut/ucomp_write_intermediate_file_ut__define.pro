; docformat = 'rst'

function ucomp_write_intermediate_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_write_intermediate_file']


  return, 1
end


pro ucomp_write_intermediate_file_ut__define
  compile_opt strictarr

  define = {ucomp_write_intermediate_file_ut, inherits UCoMPutTestCase}
end
