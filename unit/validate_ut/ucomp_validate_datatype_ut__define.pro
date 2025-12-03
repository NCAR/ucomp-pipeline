; docformat = 'rst'

function ucomp_validate_datatype_ut::create_header, datatype, $
                                                    cover=cover, $
                                                    darkshutter=darkshutter, $
                                                    caloptic=caloptic, $
                                                    diffuser=diffuser
  compile_opt strictarr

  mkhdr, header, 2, [1280, 1024, 4, 2], /image
  ucomp_addpar, header, 'DATATYPE', datatype

  ucomp_addpar, header, 'COVER', keyword_set(cover) ? 'in' : 'out'
  ucomp_addpar, header, 'DARKSHUT', keyword_set(darkshutter) ? 'in' : 'out'
  ucomp_addpar, header, 'CALOPTIC', keyword_set(caloptic) ? 'in' : 'out'
  ucomp_addpar, header, 'DIFFUSR', keyword_set(diffuser) ? 'in' : 'out'

  return, header
end


function ucomp_validate_datatype_ut::test_dark
  compile_opt strictarr

  header1 = self->create_header('dark', /darkshutter)
  assert, ucomp_validate_datatype(header1), 'dark not found'

  header2 = self->create_header('dark', /cover)
  assert, ucomp_validate_datatype(header2), 'dark not found'

  return, 1B
end


function ucomp_validate_datatype_ut::test_cal
  compile_opt strictarr

  header1 = self->create_header('cal', /caloptic)
  assert, ucomp_validate_datatype(header1), 'cal not found'

  return, 1B
end


function ucomp_validate_datatype_ut::test_flat
  compile_opt strictarr

  header1 = self->create_header('flat', /diffuser)
  assert, ucomp_validate_datatype(header1), 'flat not found'

  return, 1B
end


function ucomp_validate_datatype_ut::test_sci
  compile_opt strictarr

  header1 = self->create_header('sci')
  assert, ucomp_validate_datatype(header1), 'sci not found'

  return, 1B
end


function ucomp_validate_datatype_ut::test_unknown
  compile_opt strictarr

  header1 = self->create_header('unknown')
  assert, ~ucomp_validate_datatype(header1), 'validated an invalid header'

  return, 1B
end


function ucomp_validate_datatype_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_validate_datatype'], $
                           /is_function

  return, 1
end


pro ucomp_validate_datatype_ut__define
  compile_opt strictarr

  define = {ucomp_validate_datatype_ut, inherits UCoMPutTestCase}
end
