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
pro ucomp_file::setProperty, rcam_xcenter=rcam_xcenter, $
                             rcam_ycenter=rcam_ycenter, $
                             rcam_radius=rcam_radius, $
                             rcam_chisq=rcam_chisq, $
                             rcam_error=rcam_error, $
                             tcam_xcenter=tcam_xcenter, $
                             tcam_ycenter=tcam_ycenter, $
                             tcam_radius=tcam_radius, $
                             tcam_chisq=tcam_chisq, $
                             tcam_error=tcam_error, $
                             post_angle=post_angle, $
                             background=background, $
                             quality_bitmask=quality_bitmask, $
                             gbu=gbu, $
                             n_extensions=n_extensions
  compile_opt strictarr

  if (n_elements(rcam_xcenter)) then self.rcam_xcenter = rcam_xcenter
  if (n_elements(rcam_ycenter)) then self.rcam_ycenter = rcam_ycenter
  if (n_elements(rcam_radius)) then self.rcam_radius = rcam_radius
  if (n_elements(rcam_chisq)) then self.rcam_chisq = rcam_chisq
  if (n_elements(rcam_error)) then self.rcam_error = rcam_error
  if (n_elements(tcam_xcenter)) then self.tcam_xcenter = tcam_xcenter
  if (n_elements(tcam_ycenter)) then self.tcam_ycenter = tcam_ycenter
  if (n_elements(tcam_radius)) then self.tcam_radius = tcam_radius
  if (n_elements(tcam_chisq)) then self.tcam_chisq = tcam_chisq
  if (n_elements(tcam_error)) then self.tcam_error = tcam_error
  if (n_elements(post_angle)) then self.post_angle = post_angle

  if (n_elements(background)) then self.background = background

  if (n_elements(quality_bitmask) gt 0L) then begin
    self.quality_bitmask or= quality_bitmask
  endif

  if (n_elements(gbu) gt 0L) then self.gbu or= gbu
  if (n_elements(n_extensions) gt 0L) then self.n_extensions = n_extensions
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
                             obs_id=obs_id, $
                             obs_plan=obs_plan, $
                             exptime=exptime, $
                             gain_mode=gain_mode, $
                             pol_list=pol_list, $
                             focus=focus, $
                             o1focus=o1focus, $
                             nd=nd, $
                             n_extensions=n_extensions, $
                             wavelengths=wavelengths, $
                             n_unique_wavelengths=n_unique_wavelengths, $
                             unique_wavelengths=unique_wavelengths, $
                             background=background, $
                             quality_bitmask=quality_bitmask, $
                             gbu=gbu, $
                             ok=ok, $
                             occulter_in=occulter_in, $
                             occultrid=occultrid, $
                             obsswid=obsswid, $
                             cover_in=cover_in, $
                             darkshutter_in=darkshutter_in, $
                             opal_in=opal_in, $
                             caloptic_in=caloptic_in, $
                             polangle=polangle, $
                             retangle=retangle, $
                             rcam_xcenter=rcam_xcenter, $
                             rcam_ycenter=rcam_ycenter, $
                             rcam_radius=rcam_radius, $
                             rcam_chisq=rcam_chisq, $
                             rcam_error=rcam_error, $
                             tcam_xcenter=tcam_xcenter, $
                             tcam_ycenter=tcam_ycenter, $
                             tcam_radius=tcam_radius, $
                             tcam_chisq=tcam_chisq, $
                             tcam_error=tcam_error, $
                             post_angle=post_angle, $
                             t_base=t_base, $
                             t_lcvr1=t_lcvr1, $
                             t_lcvr2=t_lcvr2, $
                             t_lcvr3=t_lcvr3, $
                             t_lnb1=t_lnb1, $
                             t_mod=t_mod, $
                             t_lnb2=t_lnb2, $
                             t_lcvr4=t_lcvr4, $
                             t_lcvr5=t_lcvr5, $
                             t_rack=t_rack, $
                             tu_base=tu_base, $
                             tu_lcvr1=tu_lcvr1, $
                             tu_lcvr2=tu_lcvr2, $
                             tu_lcvr3=tu_lcvr3, $
                             tu_lnb1=tu_lnb1, $
                             tu_mod=tu_mod, $
                             tu_lnb2=tu_lnb2, $
                             tu_lcvr4=tu_lcvr4, $
                             tu_lcvr5=tu_lcvr5, $
                             tu_rack=tu_rack, $
                             t_c0arr=t_c0arr, $
                             t_c0pcb=t_c0pcb, $
                             t_c1arr=t_c1arr, $
                             t_c1pcb=t_c1pcb, $
                             numsum=numsum
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

  if (arg_present(obs_id)) then obs_id = self.obs_id
  if (arg_present(obs_plan)) then obs_plan = self.obs_plan

  if (arg_present(exptime)) then exptime = self.exptime
  if (arg_present(gain_mode)) then gain_mode = self.gain_mode
  if (arg_present(pol_list)) then pol_list = self.pol_list
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

  if (arg_present(background)) then background = self.background

  if (arg_present(quality_bitmask)) then quality_bitmask = self.quality_bitmask
  if (arg_present(gbu)) then gbu = self.gbu
  if (arg_present(ok)) then ok = self.quality_bitmask eq 0

  if (arg_present(focus)) then focus = self.focus
  if (arg_present(o1focus)) then o1focus = self.o1focus

  if (arg_present(occulter_in)) then occulter_in = self.occulter_in
  if (arg_present(occultrid)) then occultrid = self.occultrid
  if (arg_present(cover_in)) then cover_in = self.cover_in
  if (arg_present(darkshutter_in)) then darkshutter_in = self.darkshutter_in
  if (arg_present(opal_in)) then opal_in = self.opal_in
  if (arg_present(caloptic_in)) then caloptic_in = self.caloptic_in
  if (arg_present(polangle)) then polangle = self.polangle
  if (arg_present(retangle)) then retangle = self.retangle

  if (arg_present(obsswid)) then obsswid = self.obsswid

  if (arg_present(rcam_xcenter)) then rcam_xcenter = self.rcam_xcenter
  if (arg_present(rcam_ycenter)) then rcam_ycenter = self.rcam_ycenter
  if (arg_present(rcam_radius)) then rcam_radius = self.rcam_radius
  if (arg_present(rcam_chisq)) then rcam_chisq = self.rcam_chisq
  if (arg_present(rcam_error)) then rcam_error = self.rcam_error
  if (arg_present(tcam_xcenter)) then tcam_xcenter = self.tcam_xcenter
  if (arg_present(tcam_ycenter)) then tcam_ycenter = self.tcam_ycenter
  if (arg_present(tcam_radius)) then tcam_radius = self.tcam_radius
  if (arg_present(tcam_chisq)) then tcam_chisq = self.tcam_chisq
  if (arg_present(tcam_error)) then tcam_error = self.tcam_error
  if (arg_present(post_angle)) then post_angle = self.post_angle

  if (arg_present(t_base)) then t_base = self.t_base
  if (arg_present(t_lcvr1)) then t_lcvr1 = self.t_lcvr1
  if (arg_present(t_lcvr2)) then t_lcvr2 = self.t_lcvr2
  if (arg_present(t_lcvr3)) then t_lcvr3 = self.t_lcvr3
  if (arg_present(t_lnb1)) then t_lnb1 = self.t_lnb1
  if (arg_present(t_mod)) then t_mod = self.t_mod
  if (arg_present(t_lnb2)) then t_lnb2 = self.t_lnb2
  if (arg_present(t_lcvr4)) then t_lcvr4 = self.t_lcvr4
  if (arg_present(t_lcvr5)) then t_lcvr5 = self.t_lcvr5
  if (arg_present(t_rack)) then t_rack = self.t_rack
  if (arg_present(tu_base)) then tu_base = self.tu_base
  if (arg_present(tu_lcvr1)) then tu_lcvr1 = self.tu_lcvr1
  if (arg_present(tu_lcvr2)) then tu_lcvr2 = self.tu_lcvr2
  if (arg_present(tu_lcvr3)) then tu_lcvr3 = self.tu_lcvr3
  if (arg_present(tu_lnb1)) then tu_lnb1 = self.tu_lnb1
  if (arg_present(tu_mod)) then tu_mod = self.tu_mod
  if (arg_present(tu_lnb2)) then tu_lnb2 = self.tu_lnb2
  if (arg_present(tu_lcvr4)) then tu_lcvr4 = self.tu_lcvr4
  if (arg_present(tu_lcvr5)) then tu_lcvr5 = self.tu_lcvr5
  if (arg_present(tu_rack)) then tu_rack = self.tu_rack
  if (arg_present(t_c0arr)) then t_c0arr = self.t_c0arr
  if (arg_present(t_c0pcb)) then t_c0pcb = self.t_c0pcb
  if (arg_present(t_c1arr)) then t_c1arr = self.t_c1arr
  if (arg_present(t_c1pcb)) then t_c1pcb = self.t_c1pcb

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
  if (arg_present(numsum)) then numsum = self.numsum
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

  filter = ucomp_getpar(primary_header, 'FILTER', found=found)
  if (n_elements(filter) gt 0L && filter ne '') then begin
    self.wave_region = strtrim(long(filter), 2)
  endif else begin
    self.wave_region = ''
  endelse

  self.data_type = ucomp_getpar(extension_header, 'DATATYPE', found=found)
  ; darks don't have a wave_region
  if (self.data_type eq 'dark') then self.wave_region = ''

  self.date_obs  = ucomp_getpar(primary_header, 'DATE-OBS', found=found)

  self.obs_id = ucomp_getpar(primary_header, 'OBS_ID', found=found)
  self.obs_plan = ucomp_getpar(primary_header, 'OBS_PLAN', found=found)

  cover = ucomp_getpar(extension_header, 'COVER', found=found)
  self.cover_in = cover eq 'in'
  if (self.cover_in) then self->setProperty, quality_bitmask=ishft(1, 0)
  if (cover ne 'in' && cover ne 'out') then begin
    self->setProperty, quality_bitmask=ishft(1, 1)
  endif

  self.darkshutter_in = ucomp_getpar(extension_header, 'DARKSHUT', found=found) eq 'in'

  occulter = ucomp_getpar(extension_header, 'OCCLTR', found=found)
  self.occulter_in = occulter eq 'in'
  if (occulter ne 'in' && occulter ne 'out') then begin
    self->setProperty, quality_bitmask=ishft(1, 1)
  endif
  self.occultrid = ucomp_getpar(primary_header, 'OCCLTRID', found=found)

  self.opal_in = strlowcase(ucomp_getpar(extension_header, 'DIFFUSR', found=found)) eq 'in'
  self.caloptic_in = strlowcase(ucomp_getpar(extension_header, 'CALOPTIC', found=found)) eq 'in'
  self.polangle = ucomp_getpar(extension_header, 'POLANGLE', /float, found=found)
  self.retangle = ucomp_getpar(extension_header, 'RETANGLE', /float, found=found)

  self.obsswid = ucomp_getpar(primary_header, 'OBSSWID', found=found)

  self.gain_mode = strlowcase(ucomp_getpar(primary_header, 'GAIN', found=found))

  ; TODO: enter this from the headers
  self.nd = 0L
  self.pol_list = ''

  self.t_base   = ucomp_getpar(primary_header, 'T_BASE', /float, found=found)
  self.t_lcvr1  = ucomp_getpar(primary_header, 'T_LCVR1', /float, found=found)
  self.t_lcvr2  = ucomp_getpar(primary_header, 'T_LCVR2', /float, found=found)
  self.t_lcvr3  = ucomp_getpar(primary_header, 'T_LCVR3', /float, found=found)
  self.t_lnb1   = ucomp_getpar(primary_header, 'T_LNB1', /float, found=found)
  self.t_mod    = ucomp_getpar(primary_header, 'T_MOD', /float, found=found)
  self.t_lnb2   = ucomp_getpar(primary_header, 'T_LNB2', /float, found=found)
  self.t_lcvr4  = ucomp_getpar(primary_header, 'T_LCVR4', /float, found=found)
  self.t_lcvr5  = ucomp_getpar(primary_header, 'T_LCVR5', /float, found=found)
  self.t_rack   = ucomp_getpar(primary_header, 'T_RACK', /float, found=found)
  self.tu_base  = ucomp_getpar(primary_header, 'TU_BASE', /float, found=found)
  self.tu_lcvr1 = ucomp_getpar(primary_header, 'TU_LCVR1', /float, found=found)
  self.tu_lcvr2 = ucomp_getpar(primary_header, 'TU_LCVR2', /float, found=found)
  self.tu_lcvr3 = ucomp_getpar(primary_header, 'TU_LCVR3', /float, found=found)
  self.tu_lnb1  = ucomp_getpar(primary_header, 'TU_LNB1', /float, found=found)
  self.tu_mod   = ucomp_getpar(primary_header, 'TU_MOD', /float, found=found)
  self.tu_lnb2  = ucomp_getpar(primary_header, 'TU_LNB2', /float, found=found)
  self.tu_lcvr4 = ucomp_getpar(primary_header, 'TU_LCVR4', /float, found=found)
  self.tu_lcvr5 = ucomp_getpar(primary_header, 'TU_LCVR5', /float, found=found)
  self.tu_rack  = ucomp_getpar(primary_header, 'TU_RACK', /float, found=found)
  self.t_c0arr  = ucomp_getpar(primary_header, 'T_C0ARR', /float, found=found)
  self.t_c0pcb  = ucomp_getpar(primary_header, 'T_C0PCB', /float, found=found)
  self.t_c1arr  = ucomp_getpar(primary_header, 'T_C1ARR', /float, found=found)
  self.t_c1pcb  = ucomp_getpar(primary_header, 'T_C1PCB', /float, found=found)

  ; allocate inventory variables
  *self.wavelengths = fltarr(self.n_extensions)

  self.numsum = ucomp_getpar(extension_header, 'NUMSUM', found=found)

  self.exptime = ucomp_getpar(extension_header, 'EXPTIME', /float, found=found)

  self.o1focus = ucomp_getpar(extension_header, 'O1FOCUS', /float, found=found)

  ; inventory extensions for things that vary by extension
  moving_parts = 0B
  for e = 1L, self.n_extensions do begin
    fits_read, fcb, data, extension_header, exten_no=e, /header_only, $
               /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    moving_parts or= ucomp_getpar(extension_header, 'OCCLTR', found=found) eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'COVER', found=found) eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'DARKSHUT', found=found) eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'DIFFUSR', found=found) eq 'mid'
    moving_parts or= ucomp_getpar(extension_header, 'CALOPTIC', found=found) eq 'mid'

    (*self.wavelengths)[e - 1] = ucomp_getpar(extension_header, 'WAVELNG', /float, found=found)
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

  self.rcam_xcenter = !values.f_nan
  self.rcam_ycenter = !values.f_nan
  self.rcam_radius = !values.f_nan
  self.rcam_chisq = !values.f_nan
  self.rcam_error = -1L
  self.tcam_xcenter = !values.f_nan
  self.tcam_ycenter = !values.f_nan
  self.tcam_radius = !values.f_nan
  self.tcam_chisq = !values.f_nan
  self.tcam_error = -1L
  self.post_angle = !values.f_nan

  self.background = !values.f_nan

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
           obs_id              : '', $
           obs_plan            : '', $
           exptime             : 0.0, $
           gain_mode           : '', $
           pol_list            : '', $
           numsum              : 0L, $

           focus               : 0.0, $
           o1focus             : 0.0, $

           nd                  : 0L, $
           occulter_in         : 0B, $
           occultrid           : '', $
           cover_in            : 0B, $
           darkshutter_in      : 0B, $
           opal_in             : 0B, $
           caloptic_in         : 0B, $
           polangle            : 0.0, $
           retangle            : 0.0, $

           obsswid             : '', $

           rcam_xcenter        : 0.0, $
           rcam_ycenter        : 0.0, $
           rcam_radius         : 0.0, $
           rcam_chisq          : 0.0, $
           rcam_error          : 0L, $
           tcam_xcenter        : 0.0, $
           tcam_ycenter        : 0.0, $
           tcam_radius         : 0.0, $
           tcam_chisq          : 0.0, $
           tcam_error          : 0L, $
           post_angle          : 0.0, $

           t_base              : 0.0, $
           t_lcvr1             : 0.0, $
           t_lcvr2             : 0.0, $
           t_lcvr3             : 0.0, $
           t_lnb1              : 0.0, $
           t_mod               : 0.0, $
           t_lnb2              : 0.0, $
           t_lcvr4             : 0.0, $
           t_lcvr5             : 0.0, $
           t_rack              : 0.0, $
           tu_base             : 0.0, $
           tu_lcvr1            : 0.0, $
           tu_lcvr2            : 0.0, $
           tu_lcvr3            : 0.0, $
           tu_lnb1             : 0.0, $
           tu_mod              : 0.0, $
           tu_lnb2             : 0.0, $
           tu_lcvr4            : 0.0, $
           tu_lcvr5            : 0.0, $
           tu_rack             : 0.0, $
           t_c0arr             : 0.0, $
           t_c0pcb             : 0.0, $
           t_c1arr             : 0.0, $
           t_c1pcb             : 0.0, $

           wavelengths         : ptr_new(), $

           background          : 0.0, $

           quality_bitmask     : 0UL, $
           gbu                 : 0UL $
          }
end


; main-level example program

file = ucomp_file('/hao/mahidata1/Data/CoMP/raw/20180101/20180101.164431.FTS')

end
