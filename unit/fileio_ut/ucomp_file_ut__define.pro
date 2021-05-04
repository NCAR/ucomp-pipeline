; docformat = 'rst'

function ucomp_file_ut::test_basic
  compile_opt strictarr

  date = '20210326'
  config_filename = filepath('ucomp.production.cfg', $
                             subdir=['..', 'config'], $
                             root=self.root)
  run = ucomp_run(date, 'test', config_filename)
  raw_basedir = run->config('raw/basedir')
  basenames = ['20210326.172953.92.ucomp.l0.fts', '20210326.173105.54.ucomp.530.l0.fts']

  for b = 0L, n_elements(basenames) - 1L do begin
    filename = filepath(basenames[b], subdir=date, root=raw_basedir)
    file = ucomp_file(filename, run=run)
    assert, obj_valid(file), 'file not valid'

    help, file, output=output
    assert, n_elements(output) eq 1, 'invalid help'

    file->getProperty, raw_filename=raw_filename, $
                       l1_basename=l1_basename, $
                       intermediate_name=intermediate_name, $
                       hst_date=hst_date, $
                       hst_time=hst_time, $
                       ut_date=ut_date, $
                       ut_time=ut_time, $
                       obsday_hours=obsday_hours, $
                       date_obs=date_obs, $
                       carrington_rotation=carrington_rotation, $
                       wave_region=wave_region, $
                       center_wavelength=center_wavelength, $
                       data_type=data_type, $
                       exptime=exptime, $
                       gain_mode=gain_mode, $
                       n_extensions=n_extensions, $
                       wavelengths=wavelengths, $
                       n_unique_wavelengths=n_unique_wavelengths, $
                       unique_wavelengths=unique_wavelengths, $
                       quality_bitmask=quality_bitmask, $
                       ok=ok, $
                       cam0_arr_temp=cam0_arr_temp, $
                       cam0_pcb_temp=cam0_pcb_temp, $
                       cam1_arr_temp=cam1_arr_temp, $
                       cam1_pcb_temp=cam1_pcb_temp
  
    obj_destroy, file
  endfor

  obj_destroy, run

  return, 1
end


function ucomp_file_ut::test_dark
  compile_opt strictarr

  date = '20210326'
  config_filename = filepath('ucomp.production.cfg', $
                             subdir=['..', 'config'], $
                             root=self.root)
  run = ucomp_run(date, 'test', config_filename)
  raw_basedir = run->config('raw/basedir')
  basename = '20210326.172953.92.ucomp.l0.fts'
  filename = filepath(basename, subdir=date, root=raw_basedir)

  file = ucomp_file(filename, run=run)
  assert, obj_valid(file), 'file not valid'

  help, file, output=output
  assert, n_elements(output) eq 1, 'invalid help'

  file->getProperty, raw_filename=raw_filename, $
                     l1_basename=l1_basename, $
                     intermediate_name=intermediate_name, $
                     hst_date=hst_date, $
                     hst_time=hst_time, $
                     ut_date=ut_date, $
                     ut_time=ut_time, $
                     obsday_hours=obsday_hours, $
                     date_obs=date_obs, $
                     carrington_rotation=carrington_rotation, $
                     wave_region=wave_region, $
                     center_wavelength=center_wavelength, $
                     data_type=data_type, $
                     exptime=exptime, $
                     gain_mode=gain_mode, $
                     n_extensions=n_extensions, $
                     wavelengths=wavelengths, $
                     n_unique_wavelengths=n_unique_wavelengths, $
                     unique_wavelengths=unique_wavelengths, $
                     quality_bitmask=quality_bitmask, $
                     ok=ok, $
                     cam0_arr_temp=cam0_arr_temp, $
                     cam0_pcb_temp=cam0_pcb_temp, $
                     cam1_arr_temp=cam1_arr_temp, $
                     cam1_pcb_temp=cam1_pcb_temp

  obj_destroy, file
  obj_destroy, run

  return, 1
end


function ucomp_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_file__define', $
                            'ucomp_file::getProperty', $
                            'ucomp_file::_extract_datetime', $
                            'ucomp_file::_inventory', $
                            'ucomp_file::cleanup']
  self->addTestingRoutine, ['ucomp_file::init', 'ucomp_file::_overloadHelp'], $
                           /is_function

  return, 1
end


pro ucomp_file_ut__define
  compile_opt strictarr

  define = { ucomp_file_ut, inherits UCoMPutTestCase }
end