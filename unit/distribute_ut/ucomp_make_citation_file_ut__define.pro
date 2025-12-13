; docformat = 'rst'

function ucomp_make_citation_file_ut::test_basic
  compile_opt strictarr

  run = self->get_run()

  citation_template_filename = filepath('UCOMP_CITATION.txt.in', $
                                        subdir='docs', $
                                        root=run.resource_root)
  citation_filename = filepath('UCOMP_CITATION.txt', root='.')

  ucomp_make_citation_file, citation_template_filename, citation_filename

  assert, file_test(citation_filename, /regular), 'citation file not created'

  n_citation_lines = file_lines(citation_filename)
  citation_lines = strarr(n_citation_lines)
  openr, lun, citation_filename, /get_lun
  readf, lun, citation_lines
  free_lun, lun

  date_fmt = '(C(CDI, " ", CMoa, " ", CYI4))'
  date = string(systime(/julian), format=date_fmt)
  standard = string(date, format='https://doi.org/10.26024/G8P7-WY42. Processed %s.')
  assert, citation_lines[5] eq standard, 'invalid date line: %s', citation_lines[5]

  file_delete, citation_filename
  obj_destroy, run

  return, 1
end


function ucomp_make_citation_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_make_citation_file']

  return, 1
end


pro ucomp_make_citation_file_ut__define
  compile_opt strictarr

  define = {ucomp_make_citation_file_ut, inherits UCoMPutTestCase}
end
