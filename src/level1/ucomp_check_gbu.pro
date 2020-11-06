; docformat = 'rst'

pro ucomp_check_gbu, wave_region, run=run
  compile_opt strictarr

  mg_log, 'checking GBU for %s nm...', wave_region, name=run.logger_name, /info
end
