; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_process_file, file, run=run
  compile_opt strictarr


  ucomp_read_raw_data, self.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine')

  ucomp_l1_step, 'ucomp_camera_correction', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_average_data', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_apply_dark', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_stray_light', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_apply_gain', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_continuum_correction', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_alignment', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_demodulation', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_combine_beams', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_rotate_north_up', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_masking', file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_polarimetric_correction', file, primary_header, data, headers, run=run

  l1_filename = string(file.ut_date, $
                       file.ut_time, $
                       file.wave_type, $
                       file.polarization_string, $
                       file.n_unique_wavelengths, $
                       format='(%"%s.%s.ucomp.%s.%s.%d.fts")')
  ucomp_write_l1_file, l1_filename, primary_header, data, headers
  obj_destroy, ext_headers
end
