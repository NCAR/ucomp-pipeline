; docformat = 'rst'

function ucomp_quality_nuc_ut::make_header, rcamnuc, tcamnuc
  compile_opt strictarr

  mkhdr, primary_header, dist(1280, 1024), /extend, /image

  ucomp_addpar, primary_header, 'RCAMNUC', rcamnuc
  ucomp_addpar, primary_header, 'TCAMNUC', tcamnuc

  return, primary_header
end


function ucomp_quality_nuc_ut::test_good
  compile_opt strictarr

  run = self->get_run()
  primary_header = self->make_header('normal', 'normal')

  quality = ucomp_quality_nuc(file, $
                              primary_header, $
                              ext_data, $
                              ext_headers, $
                              run=run)
  assert, quality eq 0, 'consistent NUCs failed'

  obj_destroy, run

  return, 1
end


function ucomp_quality_nuc_ut::test_oddvalue
  compile_opt strictarr

  run = self->get_run()
  nuc = 'A new strange value'
  primary_header = self->make_header(nuc, nuc)

  quality = ucomp_quality_nuc(file, $
                              primary_header, $
                              ext_data, $
                              ext_headers, $
                              run=run)
  assert, quality eq 1, 'strange NUCs passed'

  obj_destroy, run

  return, 1
end


function ucomp_quality_nuc_ut::test_different
  compile_opt strictarr

  run = self->get_run()
  primary_header = self->make_header('normal', 'Offset + gain corrected')

  quality = ucomp_quality_nuc(file, $
                              primary_header, $
                              ext_data, $
                              ext_headers, $
                              run=run)
  assert, quality eq 1, 'different NUCs passed'

  obj_destroy, run

  return, 1
end


function ucomp_quality_nuc_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_quality_nuc'], $
                           /is_function

  return, 1
end


pro ucomp_quality_nuc_ut__define
  compile_opt strictarr

  define = {ucomp_quality_nuc_ut, inherits UCoMPutTestCase}
end
