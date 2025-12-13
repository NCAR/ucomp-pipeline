; docformat = 'rst'

function ucomp_validate_machinelog_ut::test_pass
  compile_opt strictarr

  date = '20210503'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             root=ucomp_unit_config_dir())

  run = ucomp_run(date, 'test', config_filename)
  is_valid = ucomp_validate_machinelog(run=run)
  obj_destroy, run

  assert, is_valid eq 1B, 'incorrect validity'

  return, 1
end


function ucomp_validate_machinelog_ut::test_missingfile
  compile_opt strictarr

  date = '20210326'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             root=ucomp_unit_config_dir())

  run = ucomp_run(date, 'test', config_filename)
  is_valid = ucomp_validate_machinelog(run=run)
  obj_destroy, run

  assert, is_valid eq 0B, 'incorrect validity'

  return, 1
end


function ucomp_validate_machinelog_ut::test_missinglog
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             root=ucomp_unit_config_dir())

  run = ucomp_run(date, 'test', config_filename)
  is_valid = ucomp_validate_machinelog(present=present, run=run)
  obj_destroy, run

  assert, is_valid eq 0B, 'incorrect validity'
  assert, present eq 1B, 'incorrect presence'

  return, 1
end


function ucomp_validate_machinelog_ut::test_missing
  compile_opt strictarr

  date = '20210511'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             root=ucomp_unit_config_dir())

  run = ucomp_run(date, 'test', config_filename)
  is_valid = ucomp_validate_machinelog(present=present, run=run)
  obj_destroy, run

  assert, is_valid eq 0B, 'incorrect validity'
  assert, present eq 0B, 'incorrect presence'

  return, 1
end


function ucomp_validate_machinelog_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_validate_machinelog'], $
                           /is_function

  return, 1
end


pro ucomp_validate_machinelog_ut__define
  compile_opt strictarr

  define = {ucomp_validate_machinelog_ut, inherits UCoMPutTestCase}
end
