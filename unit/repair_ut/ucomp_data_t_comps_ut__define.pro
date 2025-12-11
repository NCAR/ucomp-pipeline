; docformat = 'rst'

function ucomp_data_t_comps_ut::make_header
  compile_opt strictarr

  mkhdr, primary_header, dist(1280, 1024), /extend, /image

  ucomp_addpar, primary_header, 'T_COMPS', boolean(0)

  return, primary_header
end


function ucomp_data_t_comps_ut::test_basic
  compile_opt strictarr

  primary_header = self->make_header()

  ucomp_data_t_comps, primary_header, ext_data, ext_headers

  t_comps = ucomp_getpar(primary_header, 'T_COMPS')
  assert, t_comps, 'T_COMPS not set'

  return, 1
end


function ucomp_data_t_comps_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_t_comps']
  

  return, 1
end


pro ucomp_data_t_comps_ut__define
  compile_opt strictarr

  define = {ucomp_data_t_comps_ut, inherits UCoMPutTestCase}
end
