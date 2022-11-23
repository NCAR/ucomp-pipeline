; docformat = 'rst'

function ucomp_timeline_histogram_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_timeline_histogram']


  return, 1
end


pro ucomp_timeline_histogram_ut__define
  compile_opt strictarr

  define = {ucomp_timeline_histogram_ut, inherits MGutTestCase}
end
