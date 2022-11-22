; docformat = 'rst'

function ucomp_make_flats_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_make_flats']


  return, 1
end


pro ucomp_make_flats_ut__define
  compile_opt strictarr

  define = {ucomp_make_flats_ut, inherits MGutTestCase}
end
