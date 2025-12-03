; docformat = 'rst'

function ucomp_l1_polarimetric_correction_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPsutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l1_polarimetric_correction']


  return, 1
end


pro ucomp_l1_polarimetric_correction_ut__define
  compile_opt strictarr

  define = {ucomp_l1_polarimetric_correction_ut, inherits UCoMPutTestCase}
end
