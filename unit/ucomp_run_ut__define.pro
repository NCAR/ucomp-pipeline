; docformat = 'rst'


function ucomp_run_ut::get_config_filename
  compile_opt strictarr

  config_basename = 'ucomp.unit.cfg'
  config_filename = filepath(config_basename, root=ucomp_unit_config_dir())
  return, config_filename
end


function ucomp_run_ut::test_basic
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  is_valid = obj_valid(run)
  obj_destroy, run

  assert, is_valid, 'run object not valid'

  return, 1
end


function ucomp_run_ut::test_properties
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
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
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  raw_basedir = run->config('raw/basedir')

  obj_destroy, run

  return, 1
end


function ucomp_run_ut::test_epoch
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  process = run->epoch('process', datetime='20210511.080000')

  obj_destroy, run

  assert, process, 'incorrect process value'

  return, 1
end


function ucomp_run_ut::test_line
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  nickname = run->line('530', 'nickname', datetime='20210311.000000')
  lines = run->all_lines()

  obj_destroy, run

  assert, nickname eq 'green line', 'wrong nickname for line'

  all_lines = ['530', '637', '656', '670', '691', '706', '761', '789', '802', $
               '991', '1074', '1079', '1083']
  assert, array_equal(lines, all_lines), 'wrong lines'

  return, 1
end


function ucomp_run_ut::test_timing
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  x = run->start('x')
  t1 = run->stop(x)

  x = run->start('x')
  t2 = run->stop(x)

  obj_destroy, run

  return, 1
end


function ucomp_run_ut::test_lock
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  run->lock, is_available=is_available1
  run->unlock, is_available=is_available2

  run->lock, is_available=is_available3
  run->unlock, /mark_processed, is_available=is_available4

  run->unlock, /reprocess, is_available=is_available5
  run->unlock, is_available=is_available6

  obj_destroy, run

  assert, is_available1 eq 1B, 'incorrect is_available1'
  assert, is_available2 eq 1B, 'incorrect is_available2'
  assert, is_available3 eq 1B, 'incorrect is_available3'
  assert, is_available4 eq 1B, 'incorrect is_available4'
  assert, is_available5 eq 1B, 'incorrect is_available5'
  assert, is_available5 eq 1B, 'incorrect is_available6'

  return, 1
end


function ucomp_run_ut::test_all_wave_regions
  compile_opt strictarr

  date = '20210311'
  config_filename = self->get_config_filename()
  run = ucomp_run(date, 'test', config_filename)

  all_lines = ['530', '637', '656', '670', '691', '706', '761', '789', '802', $
               '991', '1074', '1079', '1083']
  assert, array_equal(all_lines, run.all_wave_regions), $
          'wrong wave regions'

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
                            'ucomp_run::get_distortion', $
                            'ucomp_run::get_hot_pixels', $
                            'ucomp_run::load_badframes', $
                            'ucomp_run::log_memory', $
                            'ucomp_run::report', $
                            'ucomp_run::report_profiling', $
                            'ucomp_run::start_profiler', $
                            'ucomp_run::unlock', $
                            'ucomp_run::lock', $
                            'ucomp_run::make_raw_inventory']
  self->addTestingRoutine, ['ucomp_run::init', $
                            'ucomp_run::_overloadHelp', $
                            'ucomp_run::_overloadPrint', $
                            'ucomp_run::temperature_map_option', $
                            'ucomp_run::all_temperature_maps', $
                            'ucomp_run::can_send_alert', $
                            'ucomp_run::validate_config', $
                            'ucomp_run::config', $
                            'ucomp_run::all_lines', $
                            'ucomp_run::line_changes', $
                            'ucomp_run::line', $
                            'ucomp_run::read_distortion_file', $
                            'ucomp_run::get_dmatrix_coefficients', $
                            'ucomp_run::epoch_changes', $
                            'ucomp_run::epoch', $
                            'ucomp_run::stop', $
                            'ucomp_run::start', $
                            'ucomp_run::convert_program_name', $
                            'ucomp_run::get_files'], $
                           /is_function

  return, 1
end


pro ucomp_run_ut__define
  compile_opt strictarr

  define = {ucomp_run_ut, inherits MGutTestCase}
end
