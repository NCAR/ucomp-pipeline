; docformat = 'rst'

function ucomp_data_type_histogram_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_type_histogram']


  return, 1
end


pro ucomp_data_type_histogram_ut__define
  compile_opt strictarr

  define = {ucomp_data_type_histogram_ut, inherits UCoMPutTestCase}
end
