; docformat = 'rst'

function ucomp_new_files_ut::test_basic
  compile_opt strictarr

  catalog_filename = filepath('new_files.log', root=mg_src_root())
  new_files = ucomp_new_files(mg_src_root(), catalog_filename, $
                              count=count, error=error)

  assert, count eq 1, 'wrong number of new files: %d', count
  assert, array_equal(new_files, ['20181120.144215.ucomp.fts.gz']), $
          'wrong new files'
  assert, error eq 0, 'there was an error'

  return, 1
end


function ucomp_new_files_ut::test_error
  compile_opt strictarr

  catalog_filename = filepath('does_not_exist.log', root=mg_src_root())
  new_files = ucomp_new_files(mg_src_root(), catalog_filename, $
                              count=count, error=error)

  assert, error ne 0, 'error not set'

  return, 1
end


function ucomp_new_files_ut::test_empty
  compile_opt strictarr

  catalog_filename = filepath('empty_files.log', root=mg_src_root())
  new_files = ucomp_new_files(mg_src_root(), catalog_filename, $
                              count=count, error=error)

  assert, count eq 2, 'wrong number of new files: %d', count
  assert, array_equal(new_files, $
                      ['20181120.144200.ucomp.fts.gz', $
                       '20181120.144215.ucomp.fts.gz']), $
          'wrong new files'
  assert, error eq 0, 'there was an error'

  return, 1
end


function ucomp_new_files_ut::test_remove
  compile_opt strictarr

  catalog_filename = filepath('new_files.log', root=mg_src_root())
  new_files = ucomp_new_files(filepath('..', root=mg_src_root()), catalog_filename, $
                              count=count, error=error)

  assert, error eq 0, 'error not set'

  return, 1
end


function ucomp_new_files_ut::test_no_new_files
  compile_opt strictarr

  catalog_filename = filepath('no_new_files.log', root=mg_src_root())
  new_files = ucomp_new_files(mg_src_root(), catalog_filename, $
                              count=count, error=error)

  assert, count eq 0, 'wrong number of new files: %d', count
  assert, n_elements(new_files) eq 0, 'wrong new files'
  assert, error eq 0, 'there was an error'

  return, 1
end


function ucomp_new_files_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_new_files', /is_function

  return, 1
end


pro ucomp_new_files_ut__define
  compile_opt strictarr

  define = { ucomp_new_files_ut, inherits UCoMPutTestCase }
end
