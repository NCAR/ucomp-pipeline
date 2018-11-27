; docformat = 'rst'

pro ucomp_check_quality, wave_type, run=run
  compile_opt strictarr

  mg_log, 'checking quality for %s nm...', wave_type, $
          name=run.logger_name, /info
end
