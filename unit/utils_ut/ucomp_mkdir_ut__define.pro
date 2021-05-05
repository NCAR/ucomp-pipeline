; docformat = 'rst'

function ucomp_mkdir_ut::test_basic
  compile_opt strictarr

  dir = filepath('ucomp_mkdir-test', /tmp)
  ucomp_mkdir, dir
  assert, file_test(dir, /directory), 'directory does not exist'
  !null = file_test(dir, get_mode=current_mode)
  assert, current_mode eq '775'o, 'incorrect permissions'
  file_delete, dir

  return, 1
end


function ucomp_mkdir_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_mkdir']

  return, 1
end


pro ucomp_mkdir_ut__define
  compile_opt strictarr

  define = {ucomp_mkdir_ut, inherits MGutTestCase}
end
