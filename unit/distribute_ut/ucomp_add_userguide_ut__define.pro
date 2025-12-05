; docformat = 'rst'

function ucomp_add_userguide_ut::test_found
  compile_opt strictarr

  run = self->get_run()
  files_list = list()

  ucomp_add_userguide, files_list, run=run

  assert, n_elements(files_list) eq 1, 'user guide not added'

  obj_destroy, [files_list, run]

  return, 1
end


function ucomp_add_userguide_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_add_userguide']
  

  return, 1
end


pro ucomp_add_userguide_ut__define
  compile_opt strictarr

  define = {ucomp_add_userguide_ut, inherits UCoMPutTestCase}
end
