; docformat = 'rst'

function ucomp_make_raw_inventory_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_make_raw_inventory']


  return, 1
end


pro ucomp_make_raw_inventory_ut__define
  compile_opt strictarr

  define = {ucomp_make_raw_inventory_ut, inherits MGutTestCase}
end
