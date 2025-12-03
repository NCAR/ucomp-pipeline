; docformat = 'rst'

function ucomp_average_darkfile_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_average_flatfile']


  return, 1
end


pro ucomp_average_darkfile_ut__define
  compile_opt strictarr

  define = {ucomp_average_darkfile_ut, inherits UCoMPutTestCase}
end
