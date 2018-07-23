; docformat = 'rst'

pro ucomp_perform_l1, wave_type, run=run
  compile_opt strictarr

  mg_log, 'L1 processing for %s nm...', wave_type, name='ucomp', /info
end
