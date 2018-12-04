; docformat = 'rst'

function ucomp_db_sw_insert_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_db_sw_insert'], $
                           /is_function

  return, 1
end


pro ucomp_db_sw_insert_ut__define
  compile_opt strictarr

  define = {ucomp_db_sw_insert_ut, inherits MGutTestCase}
end
