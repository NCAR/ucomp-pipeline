; docformat = 'rst'

function ucomp_db_update_mlso_numfiles_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_db_update_mlso_numfiles']
  

  return, 1
end


pro ucomp_db_update_mlso_numfiles_ut__define
  compile_opt strictarr

  define = {ucomp_db_update_mlso_numfiles_ut, inherits UCoMPutTestCase}
end
