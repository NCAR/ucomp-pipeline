; docformat = 'rst'


;= IDL_Object overloading operator implementations

;+
; Method called via `HELP`.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     variable name
;-
function ucomp_file::_overloadHelp, varname
  compile_opt strictarr

  return, string(varname, $
                 'UCoMP', $
                 self.n_extensions, $
                 self.wave_type, $
                 self.data_type, $
                 format='(%"%-15s %s  <%d exts, %s nm, %s>")')
end


;= property access

;+
; Get property values.
;-
pro ucomp_file::getProperty, raw_filename=raw_filename, $
                             ut_date=ut_date, $
                             ut_time=ut_time, $
                             wave_type=wave_type, $
                             data_type=data_type, $
                             n_extensions=n_extensions, $
                             polarization_states=polarization_states, $
                             wavelengths=wavelengths

  compile_opt strictarr

  ; for the file
  if (arg_present(raw_filename)) then raw_filename = self.raw_filename
  if (arg_present(n_extensions)) then n_extensions = self.n_extensions
  if (arg_present(ut_date)) then ut_date = self.ut_date
  if (arg_present(ut_time)) then ut_time = self.ut_time

  if (arg_present(wave_type)) then wave_type = self.wave_type
  if (arg_present(data_type)) then data_type = self.data_type

  ; by extension
  if (arg_present(polarization_states)) then begin
    polarization_states = *self.polarization_states
  endif
  if (arg_present(wavelengths)) then wavelengths = *self.wavelengths
end


;= lifecycle methods

;+
; Extract datetime from raw file and convert to UT.
;-
pro ucomp_file::_extract_datetime
  compile_opt strictarr

  datetime = strmid(file_basename(self.raw_filename), 0, 15)
  date = strmid(datetime, 0, 8)
  time = strmid(datetime, 9, 6)
  ucomp_hst2ut, date, time, ut_date=ut_date, ut_time=ut_time
  self.ut_date = ut_date
  self.ut_time = ut_time
end


;+
; Inventory raw UCoMP file.
;-
pro ucomp_file::_inventory
  compile_opt strictarr
  on_error, 2

  fits_open, self.raw_filename, fcb

  self.n_extensions = fcb.nextend

  ; allocate inventory variables
  *self.wavelengths         = fltarr(self.n_extensions)
  *self.polarization_states = strarr(self.n_extensions)

  ; TODO: exposure, data type, opal, dark shutter, polarizer, polarizer angle,
  ; retarder, etc.

  ; inventory extensions
  for e = 1L, self.n_extensions do begin
    fits_read, fcb, data, extension_header, exten_no=e, /header_only, $
               /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    (*self.wavelengths)[e - 1]         = sxpar(extension_header, 'WAVELENG')
    (*self.polarization_states)[e - 1] = sxpar(extension_header, 'POLSTATE')
  endfor

  self.wave_type = ucomp_wave_type(*self.wavelengths)

  ; TODO: determine data_type

  fits_close, fcb
end


;+
; Free resources.
;-
pro ucomp_file::cleanup
  compile_opt strictarr

  ptr_free, self.polarization_states, self.wavelengths
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

  self->_extract_datetime

  self.data_type = 'unk'

  ; allocate inventory variables for extensions
  self.polarization_states = ptr_new(/allocate_heap)
  self.wavelengths         = ptr_new(/allocate_heap)

  self->_inventory

  return, 1
end


;+
; Define instance variables.
;-
pro ucomp_file__define
  compile_opt strictarr

  !null = {ucomp_file, inherits IDL_Object, $
           raw_filename        : '', $
           ut_date             : '', $
           ut_time             : '', $
           n_extensions        : 0L, $
           wave_type           : '', $
           data_type           : '', $
           polarization_states : ptr_new(), $
           wavelengths         : ptr_new() $
          }
end


; main-level example program

file = ucomp_file('/hao/mahidata1/Data/CoMP/raw/20180101/20180101.164431.FTS')

end
