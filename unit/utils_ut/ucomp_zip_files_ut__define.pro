; docformat = 'rst'

function ucomp_zip_files_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_zip_files']


  return, 1
end


pro ucomp_zip_files_ut__define
  compile_opt strictarr

  define = {ucomp_zip_files_ut, inherits MGutTestCase}
end
