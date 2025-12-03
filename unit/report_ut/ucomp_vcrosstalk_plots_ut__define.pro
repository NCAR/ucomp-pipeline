; docformat = 'rst'

function ucomp_vcrosstalk_plots_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_vcrosstalk_plots', $
                            'ucomp_vcrosstalk_plots_wave_region']


  return, 1
end


pro ucomp_vcrosstalk_plots_ut__define
  compile_opt strictarr

  define = {ucomp_vcrosstalk_plots_ut, inherits UCoMPutTestCase}
end
