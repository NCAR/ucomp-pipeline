; docformat = 'rst'

function ucomp_geometry_ut::test_basic
  compile_opt strictarr

  geometry = {ucomp_geometry, $
              occulter_x: 640.0, $
              occulter_y: 512.0, $
              occulter_r: 350.0, $
              post_angle: 90.0}

  return, 1
end


function ucomp_geometry_ut::test_call
  compile_opt strictarr

  ucomp_geometry__define
  geometry = {ucomp_geometry, $
              occulter_x: 640.0, $
              occulter_y: 512.0, $
              occulter_r: 350.0, $
              post_angle: 90.0}

  return, 1
end


function ucomp_geometry_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_geometry__define']
  

  return, 1
end


pro ucomp_geometry_ut__define
  compile_opt strictarr

  define = {ucomp_geometry_ut, inherits MGutTestCase}
end
