; docformat = 'rst'

function ucomp_state_ut::test_lock
  compile_opt strictarr

  date = '20210510'
  basedir = filepath('ucomp_state-test', /tmp)

  date_dir =  filepath(date, root=basedir)
  file_mkdir, date_dir

  is_available = ucomp_state(date, /lock, basedir=basedir)
  assert, is_available eq 1B, 'failed lock'

  is_available = ucomp_state(date, /unlock, basedir=basedir)
  assert, is_available eq 1B, 'failed unlock'

  file_delete, basedir, /recursive

  return, 1
end


function ucomp_state_ut::test_processed
  compile_opt strictarr

  date = '20210510'
  basedir = filepath('ucomp_state-test', /tmp)
  date_dir =  filepath(date, root=basedir)
  file_mkdir, date_dir

  is_available = ucomp_state(date, /processed, basedir=basedir)
  assert, is_available eq 1B, 'failed processed lock'

  is_available = ucomp_state(date, /reprocess, basedir=basedir)
  assert, is_available eq 1B, 'failed reprocess unlock'

  file_delete, basedir, /recursive

  return, 1
end


function ucomp_state_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_state', /is_function

  return, 1
end


pro ucomp_state_ut__define
  compile_opt strictarr

  define = { ucomp_state_ut, inherits UCoMPutTestCase }
end
