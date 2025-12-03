; docformat = 'rst'

function ucomp_centering_metric_ut::test_trivial
  compile_opt strictarr

  tolerance = 0.001
  
  rcam = bytscl(dist(1280, 1024)) / 255.0 * 100.0
  tcam = bytscl(dist(1280, 1024)) / 255.0 * 100.0
  occulter_radius = 300.0

  correlation = ucomp_centering_metric(rcam, tcam, occulter_radius, $
                                       difference_median=difference_median, $
                                       tcam_median=tcam_median, $
                                       rcam_median=rcam_median)

  assert, abs(correlation - 1.0) lt tolerance, $
          'correlation %0.3f is not 1.0', correlation
  assert, abs(difference_median - 0.0) lt tolerance, $
          'differene median %0.3f is not 0.0', difference_median
  
  return, 1
end


function ucomp_centering_metric_ut::test_nan
  compile_opt strictarr

  rcam = fltarr(1280, 1024)
  tcam = fltarr(1280, 1024)
  occulter_radius = 300.0
  
  correlation = ucomp_centering_metric(rcam, tcam, occulter_radius)
  assert, finite(correlation) eq 0, 'correlation is finite'

  return, 1
end


function ucomp_centering_metric_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_centering_metric'], $
                           /is_function

  return, 1
end


pro ucomp_centering_metric_ut__define
  compile_opt strictarr

  define = {ucomp_centering_metric_ut, inherits UCoMPutTestCase}
end
