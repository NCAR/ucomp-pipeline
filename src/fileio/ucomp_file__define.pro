; docformat = 'rst'

;= property access

;+
; Get property values.
;-
pro ucomp_file::getProperty, raw_filename=raw_filename, wave_type=wave_type
  compile_opt strictarr

  if (arg_present(raw_filename)) then raw_filename = self.raw_filename
  if (arg_present(wave_type)) then wave_type = self.wave_type
end


;= lifecycle methods

;+
; Inventory raw UCoMP file.
;-
pro ucomp_file::_inventory
  compile_opt strictarr

  ; TODO: implement
  ; determine things like wave_type, wavelengths, pol states, etc.
  fits_open, raw_filename, fcb
  fits_close, fcb
end


;+
; Free resources.
;-
pro ucomp_file::cleanup
  compile_opt strictarr

end


;+
; :Returns:
;   1 for success, 0 otherwise
;
; :Params:
;   raw_filename : in, required, type=str
;     filename of raw UCoMP file
;-
function ucomp_file::init, raw_filename
  compile_opt strictarr

  self.raw_filename = raw_filename

  self->_inventory

  return, 1
end


;+
; Define instance variables.
;-
pro ucomp_file__define
  compile_opt strictarr

  !null = {ucomp_file, inherits IDL_Object, $
           raw_filename: '', $
           wave_type: '' $
          }
end
