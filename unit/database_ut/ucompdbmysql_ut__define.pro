; docformat = 'rst'

function ucompdbmysql_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucompdbmysql__define', $
                            'ucompdbmysql::cleanup', $
                            'ucompdbmysql::getProperty', $
                            'ucompdbmysql::setProperty', $
                            'ucompdbmysql::report_statement', $
                            'ucompdbmysql::report_warnings', $
                            'ucompdbmysql::report_error']
  self->addTestingRoutine, ['ucompdbmysql::init'], $
                           /is_function

  return, 1
end


pro ucompdbmysql_ut__define
  compile_opt strictarr

  define = {ucompdbmysql_ut, inherits MGutTestCase}
end
