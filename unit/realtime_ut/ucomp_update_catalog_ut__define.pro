; docformat = 'rst'

function ucomp_update_catalog_ut::test_emptystart
  compile_opt strictarr

  new_files = !null
  ucomp_update_catalog, self.catalog_filename, new_files

  assert, ~file_test(self.catalog_filename, /regular), 'catalog file exists'

  return, 1
end


function ucomp_update_catalog_ut::test_start
  compile_opt strictarr

  new_files = ['a', 'b', 'c']

  n_extensions = [2, 20, 10]
  data_types = strarr(3) + 'sci'
  exposures = fltarr(3) + 80.0
  gain_modes = strarr(3) + 'high'
  wave_regions = strarr(3) + '691'
  n_points = lonarr(3) + 3L
  numsum = lonarr(3) + 14L

  ucomp_update_catalog, self.catalog_filename, new_files, $
                        n_extensions, data_types, exposures, gain_modes, $
                        wave_regions, n_points, numsum

  cat = self->read_catalog()
  assert, array_equal(new_files, cat), $
          'incorrect catalog values: %s', strjoin(cat, ' ')
  return, 1
end


function ucomp_update_catalog_ut::test_next
  compile_opt strictarr

  n_extensions = [2, 20, 10]
  data_types = strarr(3) + 'sci'
  exposures = fltarr(3) + 80.0
  gain_modes = strarr(3) + 'high'
  wave_regions = strarr(3) + '691'
  n_points = lonarr(3) + 3L
  numsum = lonarr(3) + 14L

  new_files1 = ['a', 'b', 'c']
  ucomp_update_catalog, self.catalog_filename, new_files1, $
                        n_extensions, data_types, exposures, gain_modes, $
                        wave_regions, n_points, numsum

  new_files2 = ['d', 'e', 'f']
  ucomp_update_catalog, self.catalog_filename, new_files2, $
                        n_extensions, data_types, exposures, gain_modes, $
                        wave_regions, n_points, numsum

  cat = self->read_catalog()
  assert, array_equal([new_files1, new_files2], cat), $
          'incorrect catalog values: %s', strjoin(cat, ' ')
  return, 1
end


function ucomp_update_catalog_ut::test_basename
  compile_opt strictarr

  n_extensions = [2, 20, 10]
  data_types = strarr(3) + 'sci'
  exposures = fltarr(3) + 80.0
  gain_modes = strarr(3) + 'high'
  wave_regions = strarr(3) + '691'
  n_points = lonarr(3) + 3L
  numsum = lonarr(3) + 14L

  new_files1 = ['raw/a', 'raw/b', 'raw/c']
  ucomp_update_catalog, self.catalog_filename, new_files1, $
                        n_extensions, data_types, exposures, gain_modes, $
                        wave_regions, n_points, numsum

  new_files2 = ['raw/d', 'raw/e', 'raw/f']
  ucomp_update_catalog, self.catalog_filename, new_files2, $
                        n_extensions, data_types, exposures, gain_modes, $
                        wave_regions, n_points, numsum

  cat = self->read_catalog()
  assert, array_equal(file_basename([new_files1, new_files2]), cat), $
          'incorrect catalog values: %s', strjoin(cat, ' ')
  return, 1
end


function ucomp_update_catalog_ut::read_catalog
  compile_opt strictarr

  n_lines = file_lines(self.catalog_filename)
  if (n_lines eq 0) then return, !null

  lines = strarr(n_lines)
  openr, lun, self.catalog_filename, /get_lun
  readf, lun, lines
  free_lun, lun

  for i = 0L, n_lines - 1L do begin
    lines[i] = (strsplit(lines[i], /extract))[0]
  endfor

  return, lines
end


; Need to delete catalog file between tests if it is there.
pro ucomp_update_catalog_ut::teardown
  compile_opt strictarr

  self->UCoMPutTestCase::teardown

  file_delete, file_dirname(self.catalog_filename), $
               /recursive, /allow_nonexistent
end


function ucomp_update_catalog_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_update_catalog']

  self.catalog_filename = filepath('test.txt', $
                                   root=filepath(string(mg_pid(), format='(%"ucomp-%s")'), $
                                                 /tmp))

  return, 1
end


pro ucomp_update_catalog_ut__define
  compile_opt strictarr

  define = {ucomp_update_catalog_ut, inherits UCoMPutTestCase, $
            catalog_filename: ''}
end
