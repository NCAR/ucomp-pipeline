; docformat = 'rst'

function ucomp_read_l1_data_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_read_l1_data']


  return, 1
end


pro ucomp_read_l1_data_ut__define
  compile_opt strictarr

  define = {ucomp_read_l1_data_ut, inherits UCoMPutTestCase}
end
