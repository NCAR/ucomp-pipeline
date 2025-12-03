; docformat = 'rst'

function ucomp_roughness_ut::test_basic
  compile_opt strictarr

  n = 100
  im1 = randomu(seed, n, n)
  s1 = ucomp_roughness(im1)

  im2 = smooth(im1, 3, /edge_truncate)
  s2 = ucomp_roughness(im2)

  assert, s2 lt s1, 'smoothness metric did not improve after smoothing'

  return, 1
end


function ucomp_roughness_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_roughness'], $
                           /is_function

  return, 1
end


pro ucomp_roughness_ut__define
  compile_opt strictarr

  define = {ucomp_roughness_ut, inherits UCoMPutTestCase}
end
