; docformat = 'rst'

function ucomp_compute_density_files_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_compute_density_files', $
                            'ucomp_compute_density_files_update_peak_intensity_header']
  

  return, 1
end


pro ucomp_compute_density_files_ut__define
  compile_opt strictarr

  define = {ucomp_compute_density_files_ut, inherits MGutTestCase}
end
