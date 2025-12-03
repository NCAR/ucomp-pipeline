; docformat = 'rst'

function ucomp_fits_write_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_fits_write']


  return, 1
end


pro ucomp_fits_write_ut__define
  compile_opt strictarr

  define = {ucomp_fits_write_ut, inherits UCoMPutTestCase}
end
