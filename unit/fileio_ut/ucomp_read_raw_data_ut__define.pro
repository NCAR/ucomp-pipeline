; docformat = 'rst'

function ucomp_read_raw_data_ut::test_basic
  compile_opt strictarr

  date = '20220325'
  config_filename = filepath('ucomp.production.cfg', $
                             root=ucomp_unit_config_dir())
  run = ucomp_run(date, 'test', config_filename)
  raw_basedir = run->config('raw/basedir')
  obj_destroy, run

  basename = '20220325.215353.21.ucomp.l0.fts'
  filename = filepath(basename, subdir=date, root=raw_basedir)

  ucomp_read_raw_data, filename, $
                       primary_data=primary_data, $
                       primary_header=primary_header, $
                       ext_data=ext_data, $
                       ext_headers=ext_headers, $
                       n_extensions=n_extensions, $
                       repair_routine=repair_routine

  assert, primary_data eq 0, 'incorrect primary data'
  assert, n_elements(primary_header) eq 111, $
          'incorrect number of elements in primary header (%d)', $
          n_elements(primary_header)
  assert, array_equal(size(ext_data, /dimensions), [1280, 1024, 4, 2, 10]), $
          'incorrect ext data size: [%s]', $
          strjoin(strtrim(size(ext_data, /dimensions), 2), ', ')
  assert, n_elements(ext_headers) eq 10, $
          'incorrect number of ext headers (%d)', $
          n_elements(ext_headers)
  assert, n_extensions eq 10, 'incorrect number of extensions: %d', n_extensions

  obj_destroy, ext_headers

  return, 1
end


function ucomp_read_raw_data_ut::test_repair
  compile_opt strictarr

  date = '20220325'
  config_filename = filepath('ucomp.production.cfg', $
                             root=ucomp_unit_config_dir())

  run = ucomp_run(date, 'test', config_filename)
  raw_basedir = run->config('raw/basedir')
  obj_destroy, run

  basename = '20220325.215353.21.ucomp.l0.fts'
  filename = filepath(basename, subdir=date, root=raw_basedir)

  ucomp_read_raw_data, filename, $
                       primary_data=primary_data, $
                       primary_header=primary_header, $
                       ext_data=ext_data, $
                       ext_headers=ext_headers, $
                       n_extensions=n_extensions, $
                       repair_routine='ucomp_data_default'

  return, 1
end


function ucomp_read_raw_data_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_read_raw_data'

  return, 1
end


pro ucomp_read_raw_data_ut__define
  compile_opt strictarr

  define = { ucomp_read_raw_data_ut, inherits UCoMPutTestCase }
end
