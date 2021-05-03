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
                             intermediate_name=intermediate_name, $
                             hst_date=hst_date, $
                             hst_time=hst_time, $
                             ut_date=ut_date, $
                             ut_time=ut_time, $
                             obsday_hours=obsday_hours, $
                             date_obs=date_obs, $
                             carrington_rotation=carrington_rotation, $
                             wave_region=wave_region, $
                             center_wavelength=center_wavelength, $
                             data_type=data_type, $
                             exptime=exptime, $
                             gain_mode=gain_mode, $
                             nd=nd, $
                             n_extensions=n_extensions, $
                             wavelengths=wavelengths, $
                             n_unique_wavelengths=n_unique_wavelengths, $
                             unique_wavelengths=unique_wavelengths, $
                             quality_bitmask=quality_bitmask, $
                             ok=ok, $
                             occulter_in=occulter_in, $
                             occultrid=occultrid, $
                             cover_in=cover_in, $
                             darkshutter_in=darkshutter_in, $
                             opal_in=opal_in, $
                             caloptic_in=caloptic_in, $
                             polangle=polangle, $
                             retangle=retangle, $
                             cam0_arr_temp=cam0_arr_temp, $
                             cam0_pcb_temp=cam0_pcb_temp, $
                             cam1_arr_temp=cam1_arr_temp, $
                             cam1_pcb_temp=cam1_pcb_temp
  compile_opt strictarr

  ; for the file
  if (arg_present(raw_filename)) then raw_filename = self.raw_filename
  if (arg_present(l1_basename)) then begin
    name = n_elements(intermediate_name) eq 0L ? 'l1' : intermediate_name
    ; YYYYMMDD.HHMMSS.ucomp.WAVE.NAME.N.fts
    self->getProperty, n_unique_wavelengths=n_unique_wavelengths
    l1_basename = string(self.ut_date, $
                         self.ut_time, $
                         self.wave_region, $
                         name, $
                         n_unique_wavelengths, $
                         format='(%"%s.%s.ucomp.%s.%s.%d.fts")')

  endif

  if (arg_present(n_extensions)) then n_extensions = self.n_extensions

  if (arg_present(hst_date)) then hst_date = self.hst_date
  if (arg_present(hst_time)) then hst_time = self.hst_time
  if (arg_present(ut_date)) then ut_date = self.ut_date
  if (arg_present(ut_time)) then ut_time = self.ut_time
  if (arg_present(obsday_hours)) then obsday_hours = self.obsday_hours

  if (arg_present(date_obs)) then date_obs = self.date_obs

  if (arg_present(carrington_rotation)) then begin
    date_parts = ucomp_decompose_date(self.ut_date)
    hours = ucomp_decompose_time(self.ut_time, /float)
    sun, date_parts[0], date_parts[1], date_parts[2], hours, $
         carrington=carrington_rotation
  endif

  if (arg_present(exptime)) then exptime = self.exptime
  if (arg_present(gain_mode)) then gain_mode = self.gain_mode
  if (arg_present(nd)) then nd = self.nd

  if (arg_present(wave_region)) then wave_region = self.wave_region
  if (arg_present(center_wavelength)) then begin
    if (self.wave_region eq '') then begin
      center_wavelength = 0.0
    endif else begin
      center_wavelength = self.run->line(self.wave_region, 'center_wavelength')
    endelse
  endif

  if (arg_present(data_type)) then data_type = self.data_type

  if (arg_present(quality_bitmask)) then quality_bitmask = self.quality_bitmask
  if (arg_present(ok)) then ok = self.quality_bitmask eq 0

  if (arg_present(occulter_in)) then occulter_in = self.occulter_in
  if (arg_present(occultrid)) then occultrid = self.occultrid
  if (arg_present(cover_in)) then cover_in = self.cover_in
  if (arg_present(darkshutter_in)) then darkshutter_in = self.darkshutter_in
  if (arg_present(opal_in)) then opal_in = self.opal_in
  if (arg_present(caloptic_in)) then caloptic_in = self.caloptic_in
  if (arg_present(polangle)) then polangle = self.polangle
  if (arg_present(retangle)) then retangle = self.retangle

  if (arg_present(cam0_arr_temp)) then cam0_arr_temp = self.cam0_arr_temp
  if (arg_present(cam0_pcb_temp)) then cam0_pcb_temp = self.cam0_pcb_temp
  if (arg_present(cam1_arr_temp)) then cam1_arr_temp = self.cam1_arr_temp
  if (arg_present(cam1_pcb_temp)) then cam1_pcb_temp = self.cam1_pcb_temp

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
  hrs = [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0]
  self.obsday_hours = total(float(ucomp_decompose_time(hst_time)) * hrs)
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

  filter = ucomp_getpar(primary_header, 'FILTER')
  if (n_elements(filter) gt 0L && filter ne '') then begin
    self.wave_region = strtrim(long(filter), 2)
  endif else begin
    self.wave_region = ''
  endelse

  self.data_type = ucomp_getpar(extension_header, 'DATATYPE')
  self.date_obs  = ucomp_getpar(primary_header, 'DATE-OBS')

  cover = ucomp_getpar(extension_header, 'COVER')
  self.cover_in = cover eq 'in'
  if (self.cover_in) then self->setProperty, quality_bitmask=ishft(1, 0)
  if (cover ne 'in' && cover ne 'out') then begin
    self->setProperty, quality_bitmask=ishft(1, 1)
  endif

  self.darkshutter_in = ucomp_getpar(extension_header, 'DARKSHUT') eq 'in'

  occulter = ucomp_getpar(extension_header, 'OCCLTR')
  self.occulter_in = occulter eq 'in'
  if (occulter ne 'in' && occulter ne 'out') then begin
    self->setProperty, quality_bitmask=ishft(1, 1)
  endif
  self.occultrid = ucomp_getpar(primary_header, 'OCCLTRID')

  self.opal_in = strlowcase(ucomp_getpar(extension_header, 'DIFFUSR')) eq 'in'
  self.caloptic_in = strlowcase(ucomp_getpar(extension_header, 'CALOPTIC')) eq 'in'
  self.polangle = ucomp_getpar(extension_header, 'POLANGLE')
  self.retangle = ucomp_getpar(extension_header, 'RETANGLE')

  self.gain_mode = strlowcase(ucomp_getpar(primary_header, 'GAIN'))

  ; TODO: enter this from the headers
  self.nd = 0L

  self.cam0_arr_temp = ucomp_getpar(primary_header, 'T_C0ARR')
  self.cam0_pcb_temp = ucomp_getpar(primary_header, 'T_C0PCB')
  self.cam1_arr_temp = ucomp_getpar(primary_header, 'T_C1ARR')
  self.cam1_pcb_temp = ucomp_getpar(primary_header, 'T_C1PCB')

  ; allocate inventory variables
  *self.wavelengths = fltarr(self.n_extensions)

  self.exptime = ucomp_getpar(extension_header, 'EXPTIME', /float)

  ; inventory extensions for things that vary by extension
  moving_parts = 0B
  for e = 1L, self.n_extensions do begin
    fits_read, fcb, data, extension_header, exten_no=e, /header_only, $
               /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    moving_parts or= ucomp_getpar(extension_header, 'OCCLTR') eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'COVER') eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'DARKSHUT') eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'DIFFUSR') eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'CALOPTIC') eq 'mid'

    (*self.wavelengths)[e - 1] = ucomp_getpar(extension_header, 'WAVELNG', /float)
  endfor
  if (moving_parts) then self->setProperty, quality_bitmask=ishft(1, 1)

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
function ucomp_file::init, raw_filename, run=run
  compile_opt strictarr

  self.raw_filename = raw_filename
  self.run = run

  self->_extract_datetime

  self.data_type = 'unk'

  ; allocate inventory variables for extensions
  self.wavelengths = ptr_new(/allocate_heap)

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
           run                 : obj_new(), $
           hst_date            : '', $
           hst_time            : '', $
           ut_date             : '', $
           ut_time             : '', $
           obsday_hours        : 0.0, $
           date_obs            : '', $
           n_extensions        : 0L, $

           wave_region         : '', $
           data_type           : '', $
           exptime             : 0.0, $
           gain_mode           : '', $
           nd                  : 0L, $
           occulter_in         : 0B, $
           occultrid           : '', $
           cover_in            : 0B, $
           darkshutter_in      : 0B, $
           opal_in             : 0B, $
           caloptic_in         : 0B, $
           polangle            : 0.0, $
           retangle            : 0.0, $

           cam0_arr_temp       : 0.0, $
           cam0_pcb_temp       : 0.0, $
           cam1_arr_temp       : 0.0, $
           cam1_pcb_temp       : 0.0, $

           wavelengths         : ptr_new(), $

           quality_bitmask     : 0UL $
          }
end


; main-level example program

file = ucomp_file('/hao/mahidata1/Data/CoMP/raw/20180101/20180101.164431.FTS')

end
