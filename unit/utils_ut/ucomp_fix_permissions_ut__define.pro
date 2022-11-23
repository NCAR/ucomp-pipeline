; docformat = 'rst'

function ucomp_fix_permissions_ut::test_basic
  compile_opt strictarr

  dir = filepath('ucomp_fix_permissions-test', /tmp)
  ucomp_mkdir, dir

  filename = filepath('test.txt', root=dir)
  openw, lun, filename, /get_lun
  free_lun, lun

  ucomp_fix_permissions, filename
  !null = file_test(filename, get_mode=current_mode)
  assert, current_mode eq '664'o, 'incorrect permissions'

  file_delete, filename
  file_delete, dir

  return, 1
end


function ucomp_fix_permissions_ut::test_fix
  compile_opt strictarr

  dir = filepath('ucomp_fix_permissions-test', /tmp)
  ucomp_mkdir, dir

  filename = filepath('test.txt', root=dir)
  openw, lun, filename, /get_lun
  free_lun, lun

  file_chmod, filename, '644'o
  ucomp_fix_permissions, filename
  !null = file_test(filename, get_mode=current_mode)
  assert, current_mode eq '664'o, 'incorrect permissions'

  file_delete, filename
  file_delete, dir

  return, 1
end


function ucomp_fix_permissions_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_fix_permissions']


  return, 1
end


pro ucomp_fix_permissions_ut__define
  compile_opt strictarr

  define = {ucomp_fix_permissions_ut, inherits UCoMPutTestCase}
end
