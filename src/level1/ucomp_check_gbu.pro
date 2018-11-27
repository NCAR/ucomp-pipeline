; docformat = 'rst'

pro ucomp_check_gbu, wave_type, run=run
  compile_opt strictarr

  mg_log, 'checking GBU for %s nm...', wave_type, name=run.logger_name, /info
end
