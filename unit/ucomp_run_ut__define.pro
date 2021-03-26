; docformat = 'rst'

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
