; docformat = 'rst'

function ucomp_rolling_synoptic_map_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_rolling_synoptic_map']


  return, 1
end


pro ucomp_rolling_synoptic_map_ut__define
  compile_opt strictarr

  define = {ucomp_rolling_synoptic_map_ut, inherits UCoMPutTestCase}
end
