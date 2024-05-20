; main-level example

quality_bitmask = '10101'b
wave_region = '1074'
date = '20221101'
mode = 'test'
config_basename = 'ucomp.latest.cfg'

config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, mode, config_filename)
conditions = ucomp_quality_conditions(wave_region, run=run)
bad_condition_indices = where(quality_bitmask and conditions.mask, /null)
bad_conditions = strjoin(strmid(conditions[bad_condition_indices].checker, 14), '|')
print, bad_conditions, format='bad conditions: %s'
obj_destroy, run

end
