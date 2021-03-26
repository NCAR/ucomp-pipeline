; docformat = 'rst'

function ucomp_dn_format_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_dn_format'], $
                           /is_function

  return, 1
end


pro ucomp_dn_format_ut__define
  compile_opt strictarr

  define = {ucomp_dn_format_ut, inherits MGutTestCase}
end
