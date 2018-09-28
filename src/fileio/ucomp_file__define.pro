; docformat = 'rst'

;= property access

pro ucomp_file::getProperty, raw_filename=raw_filename
  compile_opt strictarr

  if (arg_present(raw_filename)) then raw_filename = self.raw_filename
end


;= lifecycle methods

pro ucomp_file::_inventory
  compile_opt strictarr

  ; TODO: implement
  ; determine things like wavelengths, pol states, etc.
end


pro ucomp_file::cleanup
  compile_opt strictarr

end


function ucomp_file::init, raw_filename
  compile_opt strictarr

  self.raw_filename = raw_filename

  self->_inventory

  return, 1
end


pro ucomp_file__define
  compile_opt strictarr

  !null = {ucomp_file, inherits IDL_Object, $
           raw_filename: '' $
          }
end
