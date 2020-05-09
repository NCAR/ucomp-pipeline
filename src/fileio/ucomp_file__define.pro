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
                 self.wave_region, $
                 self.data_type, $
                 format='(%"%-15s %s  <%d exts, %s nm, %s>")')
end


;+
; Method calls via `PRINT`.
;
; :Returns:
;   `strarr` or string
;-
function ucomp_file::_overloadPrint
  compile_opt strictarr

  if (self.n_extensions lt 1) then begin
    return, 'no extensions'
  endif

  self->getProperty, n_unique_wavelengths=n_unique_wavelengths

  output = strarr(self.n_extensions + 1L)
  output[0] = string(self.wave_region, $
                     self.data_type, $
                     self.n_extensions, $
                     n_unique_wavelengths, $
                     format='(%"UCoMP file: %s nm [%s] - %d exts (%d pts)")')
  for e = 1L, self.n_extensions do begin
    output[e] = string(e, (*self.wavelengths)[e - 1], format='(%"%d: %0.2f nm")')
  endfor

  return, transpose(output)
end


;= property access

;+
; Set property values.
;
; :Keywords:
;   quality_bitmask : in, optional, type=ulong
;     set to value to `or` with current value, values are::
;
;       0 - OK
;       1 - cover in
;       2 - moving optic elements, i.e., occulter, cal optics, etc.
;-
pro ucomp_file::setProperty, quality_bitmask=quality_bitmask
  compile_opt strictarr

  if (n_elements(quality_bitmask) gt 0L) then begin
    self.quality_bitmask or= quality_bitmask
  endif
end


;+
; Get property values.
;-
pro ucomp_file::getProperty, raw_filename=raw_filename, $
                             l1_basename=l1_basename, $
                             hst_date=hst_date, $
                             hst_time=hst_time, $
                             ut_date=ut_date, $
                             ut_time=ut_time, $
                             date_obs=date_obs, $
                             date_end=date_end, $
                             carrington_rotation=carrington_rotation, $
                             wave_region=wave_region, $
                             data_type=data_type, $
                             exposure=exposure, $
                             gain_mode=gain_mode, $
                             n_extensions=n_extensions, $
                             wavelengths=wavelengths, $
                             n_unique_wavelengths=n_unique_wavelengths, $
                             unique_wavelengths=unique_wavelengths, $
                             quality_bitmask=quality_bitmask, $
                             ok=ok
  compile_opt strictarr

  ; for the file
  if (arg_present(raw_filename)) then raw_filename = self.raw_filename
  if (arg_present(l1_basename)) then begin
    ; YYYYMMDD.HHMMSS.ucomp.WAVE.N.fts
    self->getProperty, n_unique_wavelengths=n_unique_wavelengths
    l1_basename = string(self.ut_date, $
                         self.ut_time, $
                         self.wave_region, $
                         n_unique_wavelengths, $
                         format='(%"%s.%s.ucomp.%s.%d.fts")')

  endif

  if (arg_present(n_extensions)) then n_extensions = self.n_extensions

  if (arg_present(hst_date)) then hst_date = self.hst_date
  if (arg_present(hst_time)) then hst_time = self.hst_time
  if (arg_present(ut_date)) then ut_date = self.ut_date
  if (arg_present(ut_time)) then ut_time = self.ut_time

  if (arg_present(date_obs)) then date_obs = self.date_obs
  if (arg_present(date_end)) then date_end = self.date_end

  if (arg_present(carrington_rotation)) then begin
    date_parts = ucomp_decompose_date(self.ut_date)
    hours = ucomp_decompose_time(self.ut_time, /float)
    sun, date_parts[0], date_parts[1], date_parts[2], hours, $
         carrington=carrington_rotation
  endif

  if (arg_present(exposure)) then exposure = self.exposure
  if (arg_present(gain_mode)) then gain_mode = self.gain_mode

  if (arg_present(wave_region)) then wave_region = self.wave_region
  if (arg_present(data_type)) then data_type = self.data_type

  if (arg_present(quality_bitmask)) then quality_bitmask = self.quality_bitmask
  if (arg_present(ok)) then ok = self.quality_bitmask eq 0

  ; by extension
  if (arg_present(wavelengths)) then wavelengths = *self.wavelengths

  if (arg_present(n_unique_wavelengths)) then begin
    w = *self.wavelengths
    n_unique_wavelengths = n_elements(uniq(w, sort(w)))
  endif

  if (arg_present(unique_wavelengths)) then begin
    w = *self.wavelengths
    unique_wavelengths = w[uniq(w, sort(w))]
  endif
end


;= lifecycle methods

;+
; Extract datetime from raw file and convert to UT.
;-
pro ucomp_file::_extract_datetime
  compile_opt strictarr

  datetime = strmid(file_basename(self.raw_filename), 0, 15)
  self.ut_date = strmid(datetime, 0, 8)
  self.ut_time = strmid(datetime, 9, 6)
  ucomp_ut2hst, self.ut_date, self.ut_time, hst_date=hst_date, hst_time=hst_time
  self.hst_date = hst_date
  self.hst_time = hst_time
end


;+
; Inventory raw UCoMP file.
;-
pro ucomp_file::_inventory
  compile_opt strictarr
  on_error, 2

  fits_open, self.raw_filename, fcb

  self.n_extensions = fcb.nextend

  fits_read, fcb, primary_data, primary_header, exten_no=0

  ; read a representative, test extension header
  fits_read, fcb, extension_data, extension_header, exten_no=1, /header_only

  self.wave_region = strtrim(long(ucomp_getpar(primary_header, 'FILTER')), 2)
  self.data_type = ucomp_getpar(extension_header, 'DATATYPE')
  self.date_obs  = ucomp_getpar(primary_header, 'DATE-OBS')
;  self.date_end  = ucomp_getpar(primary_header, 'DATE-END')

  cover = ucomp_getpar(extension_header, 'COVER')
  self.cover_in = cover eq 'in'
  if (self.cover_in) then self->setProperty, quality_bitmask=ishft(1, 0)
  if (cover ne 'in' && cover ne 'out') then begin
    self->setProperty, quality_bitmask=ishft(1, 1)
  endif

  occulter = ucomp_getpar(extension_header, 'OCCLTR')
  self.occulter_in = occulter eq 'in'
  if (occulter ne 'in' && occulter ne 'out') then begin
    self->setProperty, quality_bitmask=ishft(1, 1)
  endif

  self.gain_mode = strlowcase(ucomp_getpar(primary_header, 'GAIN'))

  ; allocate inventory variables
  *self.wavelengths = fltarr(self.n_extensions)

  ; TODO: opal, dark shutter, polarizer, polarizer angle,
  ; retarder, etc.

  self.exposure = ucomp_getpar(extension_header, 'EXPTIME', /float)

  ; inventory extensions for things that vary by extension
  for e = 1L, self.n_extensions do begin
    fits_read, fcb, data, extension_header, exten_no=e, /header_only, $
               /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    ; TODO: check for non-in/out values for CALOPTIC, DARKSHUT, CALPOL

    (*self.wavelengths)[e - 1] = ucomp_getpar(extension_header, 'WAVELNG', /float)
  endfor

  fits_close, fcb
end


;+
; Free resources.
;-
pro ucomp_file::cleanup
  compile_opt strictarr

  ptr_free, self.wavelengths
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
           hst_date            : '', $
           hst_time            : '', $
           ut_date             : '', $
           ut_time             : '', $
           date_obs            : '', $
           date_end            : '', $
           n_extensions        : 0L, $

           wave_region         : '', $
           data_type           : '', $
           exposure            : 0.0, $
           gain_mode           : '', $
           occulter_in         : 0B, $
           cover_in            : 0B, $

           wavelengths         : ptr_new(), $

           quality_bitmask     : 0UL $
          }
end


; main-level example program

file = ucomp_file('/hao/mahidata1/Data/CoMP/raw/20180101/20180101.164431.FTS')

end
