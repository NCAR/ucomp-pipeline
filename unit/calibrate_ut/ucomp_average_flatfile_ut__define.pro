; docformat = 'rst'

function ucomp_average_flatfile_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_average_flatfile']


  return, 1
end


pro ucomp_average_flatfile_ut__define
  compile_opt strictarr

  define = {ucomp_average_flatfile_ut, inherits MGutTestCase}
end
