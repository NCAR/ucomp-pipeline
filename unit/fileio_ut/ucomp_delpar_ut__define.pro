; docformat = 'rst'

function ucomp_delpar_read_header
  compile_opt strictarr

  header_basename = 'example_l2_primary_header.txt'
  header_filename = filepath(header_basename, root=mg_src_root())
  n_lines = file_lines(header_filename)
  header = strarr(n_lines)
  openr, lun, header_filename, /get_lun
  readf, lun, header
  free_lun, lun

  return, header
end


function ucomp_delpar_ut::test_basic
  compile_opt strictarr

  header = *self.header

  t_rack = ucomp_getpar(header, 'T_RACK', found=found)
  assert, found, 'T_RACK not found before deleting'

  ucomp_delpar, header, 'T_RACK'

  t_rack = ucomp_getpar(header, 'T_RACK', found=found)
  assert, ~found, 'T_RACK found after deleting'

  return, 1
end

function ucomp_delpar_ut::test_section
  compile_opt strictarr

  header = *self.header
  n_original_lines = n_elements(header)

  assert, n_original_lines eq 201, '%d original lines incorrect', n_original_lines
  numnl0o = ucomp_getpar(header, 'NUMNL0O')
  assert, numnl0o eq 41, 'incorrect numnl0o value: %d', numnl0o

  ucomp_delpar, header, 'Quality metrics', /section
  n_lines = n_elements(header)

  !null = ucomp_getpar(header, 'NUMNL0O', found=found)
  assert, ~found, 'NUMNL0O found after deleting section'
  n_deleted_lines = n_original_lines - n_lines
  assert, n_deleted_lines eq 11, 'wrong number of deleted lines: %d', n_deleted_lines

  return, 1
end


function ucomp_delpar_ut::test_sections
  compile_opt strictarr

  sections = ['Weather info', 'Observing info']

  header = *self.header
  n_original_lines = n_elements(header)

  assert, n_original_lines eq 201, '%d original lines incorrect', n_original_lines

  ucomp_delpar, header, sections, /section
  n_lines = n_elements(header)

  n_deleted_lines = n_original_lines - n_lines
  assert, n_deleted_lines eq 10 + 3, 'wrong number of deleted lines: %d', n_deleted_lines

  return, 1
end


function ucomp_delpar_ut::test_lastsection
  compile_opt strictarr

  header = *self.header
  n_original_lines = n_elements(header)

  assert, n_original_lines eq 201, '%d original lines incorrect', n_original_lines

  ucomp_delpar, header, 'Occulter centering info', /section
  n_lines = n_elements(header)

  n_deleted_lines = n_original_lines - n_lines
  assert, n_deleted_lines eq 32, 'wrong number of deleted lines: %d', n_deleted_lines

  return, 1
end


function ucomp_delpar_ut::test_history
  compile_opt strictarr

  header = *self.header
  n_original_lines = n_elements(header)
  assert, n_original_lines eq 201, '%d original lines incorrect', n_original_lines

  ucomp_delpar, header, /history
  n_lines = n_elements(header)

  n_deleted_lines = n_original_lines - n_lines
  assert, n_deleted_lines eq 17, 'wrong number of deleted lines: %d', n_deleted_lines

  return, 1
end


pro ucomp_delpar_ut::cleanup
  compile_opt strictarr

  ptr_free, self.header
end


function ucomp_delpar_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_delpar']

  self.header = ptr_new(ucomp_delpar_read_header())

  return, 1
end


pro ucomp_delpar_ut__define
  compile_opt strictarr

  define = {ucomp_delpar_ut, inherits UCoMPutTestCase, header: ptr_new()}
end
