; docformat = 'rst'

function ucomp_l1_camera_linearity_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l1_camera_linearity']


  return, 1
end


pro ucomp_l1_camera_linearity_ut__define
  compile_opt strictarr

  define = {ucomp_l1_camera_linearity_ut, inherits UCoMPutTestCase}
end
