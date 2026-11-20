; docformat = 'rst'

function ucomp_v2arcsec_ut::test_basic
  compile_opt strictarr

  dt = '2024-04-09T18:07:48.30'
  dimv = 8.22400
  rav = 0.00020
  decv = -0.00070

  tokens = long(strsplit(dt, '-T:.', /extract))
  hours = (tokens[3] + (tokens[4] + tokens[5] / 60.0) / 60.0) / 24.0

  sun, tokens[0], tokens[1], tokens[2], hours, sd=r_sun

  tolerance = 0.001

  value = ucomp_v2arcsec(rav, dimv, r_sun)
  standard = 0.018300513
  assert, abs(value - standard) lt tolerance, $
          'value (%0.5f) not within tolerance of standard (%0.5f)', $
          value, standard

  value = ucomp_v2arcsec(decv, dimv, r_sun)
  standard = -0.064051794
  assert, abs(value - standard) lt tolerance, $
          'value (%0.5f) not within tolerance of standard (%0.5f)', $
          value, standard

  return, 1
end


function ucomp_v2arcsec_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_v2arcsec'], $
                           /is_function

  return, 1
end


pro ucomp_v2arcsec_ut__define
  compile_opt strictarr

  define = {ucomp_v2arcsec_ut, inherits UCoMPutTestCase}
end
