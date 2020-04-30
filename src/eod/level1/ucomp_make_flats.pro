; docformat = 'rst'

pro ucomp_make_flats, wave_region, run=run
  compile_opt strictarr

  mg_log, 'making flats for %s nm...', wave_region, name=run.logger_name, /info
end
