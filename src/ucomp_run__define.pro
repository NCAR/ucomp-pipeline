; docformat = 'rst'

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

  return, 1
end


pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date: ''}
end
