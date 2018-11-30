; docformat = 'rst'

pro ucomp_make_darks, wave_type, run=run
  compile_opt strictarr

  mg_log, 'making darks for %s nm...', wave_type, name=run.logger_name, /info
end
