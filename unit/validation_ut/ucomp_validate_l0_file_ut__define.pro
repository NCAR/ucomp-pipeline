; docformat = 'rst'

function ucomp_validate_l0_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_validate_l0_file_checkspec', $
                            'ucomp_validate_l0_file_checkheader', $
                            'ucomp_validate_l0_file_checkdata', $
                            'ucomp_validate_l0_file'], $
                           /is_function

  return, 1
end


pro ucomp_validate_l0_file_ut__define
  compile_opt strictarr

  define = {ucomp_validate_l0_file_ut, inherits UCoMPutTestCase}
end
