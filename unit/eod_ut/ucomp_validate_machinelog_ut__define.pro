; docformat = 'rst'

function ucomp_validate_machinelog_ut::test_basic
  compile_opt strictarr

  date = '20210326'
  config_basename = 'ucomp.production.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', '..', 'config'], $
                             root=mg_src_root())

  run = ucomp_run(date, 'test', config_filename)
  is_valid = ucomp_validate_machinelog(run=run)
  obj_destroy, run

  return, is_valid
end


function ucomp_validate_machinelog_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_validate_machinelog'], $
                           /is_function

  return, 1
end


pro ucomp_validate_machinelog_ut__define
  compile_opt strictarr

  define = {ucomp_validate_machinelog_ut, inherits MGutTestCase}
end
