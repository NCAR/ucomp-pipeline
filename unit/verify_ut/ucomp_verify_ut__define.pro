; docformat = 'rst'

function ucomp_verify_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_verify', $
                            'ucomp_verify_check_files', $
                            'ucomp_verify_check_permissions', $
                            'ucomp_verify_check_logs', $
                            'ucomp_verify_check_collection_server', $
                            'ucomp_verify_check_archive_server']
  self->addTestingRoutine, ['ucomp_verify_get_datetime'], /is_function


  return, 1
end


pro ucomp_verify_ut__define
  compile_opt strictarr

  define = {ucomp_verify_ut, inherits MGutTestCase}
end
