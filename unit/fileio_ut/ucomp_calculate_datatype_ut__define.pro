; docformat = 'rst'

function ucomp_calculate_datatype_ut::make_header, occulter=occulter, $
                                                   caloptic=caloptic, $
                                                   cover=cover, $
                                                   diffuser=diffuser, $
                                                   dark_shutter=dark_shutter, $
                                                   o1nd=o1nd, $
                                                   grid=grid
  compile_opt strictarr

  mkhdr, header, fltarr(1280, 1024, 4, 2)

  ucomp_addpar, header, 'OCCLTR', mg_default(occulter, 'out')
  ucomp_addpar, header, 'CALOPTIC', mg_default(caloptic, 'out')
  ucomp_addpar, header, 'COVER', mg_default(cover, 'out')
  ucomp_addpar, header, 'DIFFUSR', mg_default(diffuser, 'out')
  ucomp_addpar, header, 'DARKSHUT', mg_default(dark_shutter, 'out')

  if (n_elements(o1nd) gt 0L) then begin
    ucomp_addpar, header, 'O1ND', mg_default(o1nd, 'out')
  endif
  if (n_elements(grid) gt 0L) then begin
    ucomp_addpar, header, 'GRID', mg_default(grid, 'out')
  endif

  return, header
end


function ucomp_calculate_datatype_ut::test_invalid
  compile_opt strictarr

  standard = 'invalid'

  header = self->make_header(occulter='mid')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  header = self->make_header(grid='mid')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  return, 1
end


function ucomp_calculate_datatype_ut::test_dark
  compile_opt strictarr

  standard = 'dark'

  header = self->make_header(dark_shutter='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  return, 1
end


function ucomp_calculate_datatype_ut::test_cal
  compile_opt strictarr

  standard = 'cal'

  header = self->make_header(caloptic='in', diffuser='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  return, 1
end


function ucomp_calculate_datatype_ut::test_flat
  compile_opt strictarr

  standard = 'flat'

  header = self->make_header(diffuser='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  return, 1
end


function ucomp_calculate_datatype_ut::test_sci
  compile_opt strictarr

  standard = 'sci'

  header = self->make_header(occulter='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  return, 1
end


function ucomp_calculate_datatype_ut::test_eng
  compile_opt strictarr

  standard = 'eng'

  header = self->make_header(cover='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  header = self->make_header(grid='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  header = self->make_header(o1nd='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  header = self->make_header(caloptic='in')
  datatype = ucomp_calculate_datatype(header)
  assert, datatype eq standard, '%s not %s', datatype, standard

  return, 1
end


function ucomp_calculate_datatype_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_calculate_datatype'], $
                           /is_function

  return, 1
end


pro ucomp_calculate_datatype_ut__define
  compile_opt strictarr

  define = {ucomp_calculate_datatype_ut, inherits UCoMPutTestCase}
end
