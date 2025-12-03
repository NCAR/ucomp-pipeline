; docformat = 'rst'

function ucomp_combine_headers_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_combine_headers'], $
                           /is_function

  return, 1
end


pro ucomp_combine_headers_ut__define
  compile_opt strictarr

  define = {ucomp_combine_headers_ut, inherits UCoMPutTestCase}
end
