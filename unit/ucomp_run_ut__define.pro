; docformat = 'rst'

function ucomp_run_ut::test_basic
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', 'config'], $
                             root=mg_src_root())
  
  run = ucomp_run(date, 'test', config_filename)

  is_valid = obj_valid(run)
  obj_destroy, run

  assert, is_valid, 'run object not valid'

  return, 1
end


function ucomp_run_ut::test_properties
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', 'config'], $
                             root=mg_src_root())
  
  run = ucomp_run(date, 'test', config_filename)

  run->getProperty, date=date, $
                    mode=mode, $
                    logger_name=logger_name, $
                    config_contents=config_contents, $
                    all_wave_regions=all_wave_regions, $
                    resource_root=resource_root, $
                    calibration=calibration, $
                    t0=t0
  obj_destroy, run

  return, 1
end


function ucomp_run_ut::test_config
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', 'config'], $
                             root=mg_src_root())
  
  run = ucomp_run(date, 'test', config_filename)

  raw_basedir = run->config('raw/basedir')

  obj_destroy, run

  return, 1
end


function ucomp_run_ut::test_epoch
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', 'config'], $
                             root=mg_src_root())
  
  run = ucomp_run(date, 'test', config_filename)

  process = run->epoch('process', datetime='20210511.080000')

  obj_destroy, run

  assert, process, 'incorrect process value'

  return, 1
end


function ucomp_run_ut::test_line
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', 'config'], $
                             root=mg_src_root())
  
  run = ucomp_run(date, 'test', config_filename)

  lines = run->line()
  nickname = run->line('530', 'nickname')

  obj_destroy, run

  assert, nickname eq 'green line', 'wrong nickname for line'

  all_lines = ['530', '637', '656', '691', '706', '789', '1074', '1079', '1083']
  assert, array_equal(lines, all_lines), 'wrong lines'

  return, 1
end


function ucomp_run_ut::test_timing
  compile_opt strictarr

  date = '20210311'
  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, $
                             subdir=['..', 'config'], $
                             root=mg_src_root())
  
  run = ucomp_run(date, 'test', config_filename)

  x = run->start('x')
  t1 = run->stop(x)

  x = run->start('x')
  t2 = run->stop(x)

  obj_destroy, run

  return, 1
end


function ucomp_run_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_run__define', $
                            'ucomp_run::cleanup', $
                            'ucomp_run::_setup_logger', $
                            'ucomp_run::setProperty', $
                            'ucomp_run::getProperty', $
                            'ucomp_run::report', $
                            'ucomp_run::report_profiling', $
                            'ucomp_run::start_profiler', $
                            'ucomp_run::unlock', $
                            'ucomp_run::lock', $
                            'ucomp_run::make_raw_inventory']
  self->addTestingRoutine, ['ucomp_run::init', $
                            'ucomp_run::_overloadHelp', $
                            'ucomp_run::_overloadPrint', $
                            'ucomp_run::config', $
                            'ucomp_run::all_lines', $
                            'ucomp_run::line', $
                            'ucomp_run::epoch', $
                            'ucomp_run::stop', $
                            'ucomp_run::start', $
                            'ucomp_run::get_files'], $
                           /is_function

  return, 1
end


pro ucomp_run_ut__define
  compile_opt strictarr

  define = {ucomp_run_ut, inherits MGutTestCase}
end
