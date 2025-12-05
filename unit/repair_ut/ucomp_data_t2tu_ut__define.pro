; docformat = 'rst'

function ucomp_data_t2tu_ut::test_basic
  compile_opt strictarr

  mkhdr, primary_header, dist(1280, 1024), /extend, /image
  after = 'GCOUNT'
  ucomp_addpar, primary_header, 'T_C0ARR', 4.992, $
                comment='[C] Camera 0 Sensor array temp', after=after
  ucomp_addpar, primary_header, 'T_C0PCB', 34.000, $
                comment='[C] Camera 0 PCB board temp', after=after
  ucomp_addpar, primary_header, 'T_C1ARR', 5.025, $
                comment='[C] Camera 1 Sensor array temp', after=after
  ucomp_addpar, primary_header, 'T_C1PCB', 33.500, $
                comment='[C] Camera 1 PCB board temp', after=after

  ucomp_data_t2tu, primary_header, ext_data, ext_headers

  names = ['T_C0ARR', 'T_C0PCB', 'T_C1ARR', 'T_C1PCB']
  for n = 0L, n_elements(names) - 1L do begin
    !null = ucomp_getpar(primary_header, names[n], found=found)
    assert, found eq 0, '%s still present', names[n]
  endfor

  names = 'TU_' + strmid(names, 2)
  values = [4.992, 34.000, 5.025, 33.500]
  for n = 0L, n_elements(names) - 1L do begin
    value = ucomp_getpar(primary_header, names[n], found=found)
    assert, found eq 1, '%s not present', names[n]
    assert, abs(value - values[n]) lt 0.01, 'bad value for %s: %0.3f', names[n], value
  endfor

  return, 1
end


function ucomp_data_t2tu_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_t2tu']
  

  return, 1
end


pro ucomp_data_t2tu_ut__define
  compile_opt strictarr

  define = {ucomp_data_t2tu_ut, inherits UCoMPutTestCase}
end
