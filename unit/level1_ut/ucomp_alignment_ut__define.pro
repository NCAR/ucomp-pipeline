; docformat = 'rst'

function ucomp_alignment_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_alignment']
  

  return, 1
end


pro ucomp_alignment_ut__define
  compile_opt strictarr

  define = {ucomp_alignment_ut, inherits MGutTestCase}
end
