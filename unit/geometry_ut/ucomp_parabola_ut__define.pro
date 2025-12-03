; docformat = 'rst'

function ucomp_parabola_ut::test_basic
  compile_opt strictarr

  coeffs = randomu(seed, 3, /double)
  x = randomu(seed, 3)
  x = x[sort(x)]
  y = coeffs[0] + x * (coeffs[1] + x * coeffs[2])

  xmin = ucomp_parabola(x, y)
  xmin_standard = - coeffs[1] / (2.0 * coeffs[2])

  threshold = 0.001
  assert, abs(xmin - xmin_standard) lt threshold, $
          'difference in mins too large (%0.4f)', xmin - xmin_standard

  return, 1
end


function ucomp_parabola_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_parabola'], $
                           /is_function

  return, 1
end


pro ucomp_parabola_ut__define
  compile_opt strictarr

  define = {ucomp_parabola_ut, inherits UCoMPutTestCase}
end
