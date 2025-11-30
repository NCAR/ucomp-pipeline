; docformat = 'rst'

function ucomp_file_ut::test_basic
  compile_opt strictarr

  date = '20210810'
  config_filename = filepath('ucomp.production.cfg', $
                             root=ucomp_unit_config_dir())
  run = ucomp_run(date, 'test', config_filename)
  raw_basedir = run->config('raw/basedir')
  basenames = ['20210810.175229.68.ucomp.637.l0.fts', $
               '20210810.180219.11.ucomp.1074.l0.fts']

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
                       obs_id_name=obs_id_name, $
                       obs_id_version=obs_id_version, $
                       obs_plan_name=obs_plan_name, $
                       obs_plan_version=obs_plan_version, $
                       exptime=exptime, $
                       gain_mode=gain_mode, $
                       pol_list=pol_list, $
                       focus=focus, $
                       o1focus=o1focus, $
                       nd=nd, $
                       n_extensions=n_extensions, $
                       wavelengths=wavelengths, $
                       n_unique_wavelengths=n_unique_wavelengths, $
                       unique_wavelengths=unique_wavelengths, $
                       median_background=median_background, $
                       quality_bitmask=quality_bitmask, $
                       ok=ok, $
                       occulter_in=occulter_in, $
                       occultrid=occultrid, $
                       obsswid=obsswid, $
                       cover_in=cover_in, $
                       darkshutter_in=darkshutter_in, $
                       opal_in=opal_in, $
                       caloptic_in=caloptic_in, $
                       polangle=polangle, $
                       retangle=retangle, $
                       rcam_geometry=rcam_geometry, $
                       tcam_geometry=tcam_geometry, $
                       t_base=t_base, $
                       t_lcvr1=t_lcvr1, $
                       t_lcvr2=t_lcvr2, $
                       t_lcvr3=t_lcvr3, $
                       t_lnb1=t_lnb1, $
                       t_mod=t_mod, $
                       t_lnb2=t_lnb2, $
                       t_lcvr4=t_lcvr4, $
                       t_lcvr5=t_lcvr5, $
                       t_rack=t_rack, $
                       tu_base=tu_base, $
                       tu_lcvr1=tu_lcvr1, $
                       tu_lcvr2=tu_lcvr2, $
                       tu_lcvr3=tu_lcvr3, $
                       tu_lnb1=tu_lnb1, $
                       tu_mod=tu_mod, $
                       tu_lnb2=tu_lnb2, $
                       tu_lcvr4=tu_lcvr4, $
                       tu_lcvr5=tu_lcvr5, $
                       tu_rack=tu_rack, $
                       tu_c0arr=tu_c0arr, $
                       tu_c0pcb=tu_c0pcb, $
                       tu_c1arr=tu_c1arr, $
                       tu_c1pcb=tu_c1pcb
                  compile_opt strictarr

    obj_destroy, file
  endfor

  obj_destroy, run

  return, 1
end


function ucomp_file_ut::test_dark
  compile_opt strictarr

  date = '20210810'
  config_filename = filepath('ucomp.production.cfg', $
                             root=ucomp_unit_config_dir())
  run = ucomp_run(date, 'test', config_filename)
  raw_basedir = run->config('raw/basedir')
  basename = '20210810.170156.99.ucomp.l0.fts'
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
                     obs_id_name=obs_id_name, $
                     obs_id_version=obs_id_version, $
                     obs_plan_name=obs_plan_name, $
                     obs_plan_version=obs_plan_version, $
                     exptime=exptime, $
                     gain_mode=gain_mode, $
                     pol_list=pol_list, $
                     focus=focus, $
                     o1focus=o1focus, $
                     nd=nd, $
                     n_extensions=n_extensions, $
                     wavelengths=wavelengths, $
                     n_unique_wavelengths=n_unique_wavelengths, $
                     unique_wavelengths=unique_wavelengths, $
                     median_background=median_background, $
                     quality_bitmask=quality_bitmask, $
                     ok=ok, $
                     occulter_in=occulter_in, $
                     occultrid=occultrid, $
                     obsswid=obsswid, $
                     cover_in=cover_in, $
                     darkshutter_in=darkshutter_in, $
                     opal_in=opal_in, $
                     caloptic_in=caloptic_in, $
                     polangle=polangle, $
                     retangle=retangle, $
                     rcam_geometry=rcam_geometry, $
                     tcam_geometry=tcam_geometry, $
                     t_base=t_base, $
                     t_lcvr1=t_lcvr1, $
                     t_lcvr2=t_lcvr2, $
                     t_lcvr3=t_lcvr3, $
                     t_lnb1=t_lnb1, $
                     t_mod=t_mod, $
                     t_lnb2=t_lnb2, $
                     t_lcvr4=t_lcvr4, $
                     t_lcvr5=t_lcvr5, $
                     t_rack=t_rack, $
                     tu_base=tu_base, $
                     tu_lcvr1=tu_lcvr1, $
                     tu_lcvr2=tu_lcvr2, $
                     tu_lcvr3=tu_lcvr3, $
                     tu_lnb1=tu_lnb1, $
                     tu_mod=tu_mod, $
                     tu_lnb2=tu_lnb2, $
                     tu_lcvr4=tu_lcvr4, $
                     tu_lcvr5=tu_lcvr5, $
                     tu_rack=tu_rack, $
                     tu_c0arr=tu_c0arr, $
                     tu_c0pcb=tu_c0pcb, $
                     tu_c1arr=tu_c1arr, $
                     tu_c1pcb=tu_c1pcb
compile_opt strictarr

  obj_destroy, file
  obj_destroy, run

  return, 1
end


function ucomp_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_file__define', $
                            'ucomp_file::setProperty', $
                            'ucomp_file::getProperty', $
                            'ucomp_file::_extract_datetime', $
                            'ucomp_file::_inventory', $
                            'ucomp_file::cleanup']
  self->addTestingRoutine, ['ucomp_file::init', $
                            'ucomp_file::_overloadHelp', $
                            'ucomp_file::_overloadPrint'], $
                           /is_function

  return, 1
end


pro ucomp_file_ut__define
  compile_opt strictarr

  define = { ucomp_file_ut, inherits UCoMPutTestCase }
end
