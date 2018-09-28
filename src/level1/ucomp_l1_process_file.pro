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

  ucomp_l1_step, 'ucomp_camera_correction', file, run=run
  ucomp_l1_step, 'ucomp_average_data', file, run=run
  ucomp_l1_step, 'ucomp_apply_dark', file, run=run
  ucomp_l1_step, 'ucomp_stray_light', file, run=run
  ucomp_l1_step, 'ucomp_apply_gain', file, run=run
  ucomp_l1_step, 'ucomp_continuum_correction', file, run=run
  ucomp_l1_step, 'ucomp_alignment', file, run=run
  ucomp_l1_step, 'ucomp_demodulation', file, run=run
  ucomp_l1_step, 'ucomp_combine_beams', file, run=run
  ucomp_l1_step, 'ucomp_rotate_north_up', file, run=run
  ucomp_l1_step, 'ucomp_masking', file, run=run
  ucomp_l1_step, 'ucomp_polarimetric_correction', file, run=run
end
