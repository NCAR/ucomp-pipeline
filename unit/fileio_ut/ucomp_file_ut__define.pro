; docformat = 'rst'

function ucomp_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_file__define', $
                            'ucomp_file::getProperty', $
                            'ucomp_file::_extract_datetime', $
                            'ucomp_file::_inventory', $
                            'ucomp_file::cleanup']
  self->addTestingRoutine, ['ucomp_file::init', 'ucomp_file::_overloadHelp'], $
                           /is_function

  return, 1
end


pro ucomp_file_ut__define
  compile_opt strictarr

  define = { ucomp_file_ut, inherits UCoMPutTestCase }
end