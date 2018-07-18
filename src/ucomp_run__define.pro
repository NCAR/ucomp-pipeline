; docformat = 'rst'


;= epoch values

function ucomp_run::epoch, name
  compile_opt strictarr

  ; TODO: implement
end


;= config values

function ucomp_run::config, name
  compile_opt strictarr

end


;= property access

pro ucomp_run::getProperty, date=date
  compile_opt strictarr

  if (arg_present(date)) then date = self.date
end


;= lifecycle methods

pro ucomp_run::cleanup
  compile_opt strictarr

end


function ucomp_run::init, date, config_filename
  compile_opt strictarr

  self.date = date

  config_spec = filepath('config_spec.cfg', $
                         subdir=['..', 'resource'], $
                         root=mg_src_root()
  self.options = mg_read_config(config_filename)

  epochs_spec = filepath('epochs_spec.cfg', $
                         subdir=['..', 'resource'], $
                         root=mg_src_root()
  return, 1
end


pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date: '', $
           options: obj_new()}
end
