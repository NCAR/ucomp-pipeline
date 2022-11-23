; docformat = 'rst'

function ucomp_verify_check_remote_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_verify_check_remote_file'], $
                           /is_function

  return, 1
end


pro ucomp_verify_check_remote_file_ut__define
  compile_opt strictarr

  define = {ucomp_verify_check_remote_file_ut, inherits MGutTestCase}
end
