; docformat = 'rst'

;= handle darks

;+
; Cache the master dark file.
;
; :Params:
;   filename : in, optional, type=string
;     filename of master dark file, if not present, then `darks`, `times`,
;     `exptimes`, and `gain_modes` must be present
;
; :Keywords:
;   darks : in, optional, type="fltarr(..., n)"
;     dark images
;   times : in, optional, type=fltarr(n)
;     times of the darks [hours into observing day]
;   exptimes : in, optional, type=fltarr(n)
;     exposure times of the darks [ms]
;   gain_modes : in, optional, type=bytarr(n)
;     gain modes of the darks [ms]
;-
pro ucomp_calibration::cache_darks, filename, $
                                    darks=darks, $
                                    times=times, $
                                    exptimes=exptimes, $
                                    gain_modes=gain_modes
  compile_opt strictarr

  self.run->getProperty, logger_name=logger_name
  mg_log, 'caching darks...', name=logger_name, /info

  ; master dark file with extensions 1..n:
  ;   exts 1 to n - 3:   dark images
  ;   ext n - 2:         times of the dark images
  ;   ext n - 1:         exposure times of the dark images 
  ;   ext n:             gain modes of the dark images 

  if (n_elements(filename) gt 0L) then begin
    fits_open, filename, fcb

    ; read the first extension to determine the dark size and cache it
    fits_read, fcb, dark_image, dark_header, exten_no=1

    dims = size(dark_image, /dimensions)
    dark_size = product(dims, /preserve_type)

    darks = make_array(dimension=[dims, fcb.nextend - 3L], $
                       type=size(dark_image, /type))
    darks[0] = dark_image

    ; read the rest of the dark images
    for e = 2L, fcb.nextend - 3L do begin   ; there are 3 "index" extensions at end of file
      fits_read, fcb, dark_image, dark_header, exten_no=e
      darks[(e - 1) * dark_size] = dark_image
    endfor

    ; read the times and exposure times
    fits_read, fcb, times, times_header, exten_no=fcb.nextend - 2L
    fits_read, fcb, exptimes, exptimes_header, exten_no=fcb.nextend - 1L
    fits_read, fcb, gain_modes, gain_modes_header, exten_no=fcb.nextend

    fits_close, fcb
  endif

  *self.darks = darks
  *self.dark_times = times
  *self.dark_exptimes = exptimes
  *self.dark_gain_modes = gain_modes

  mg_log, '%d darks cached', n_elements(times), name=logger_name, /info
end


;+
; Discard the dark cache.
;-
pro ucomp_calibration::discard_darks
  compile_opt strictarr

  *self.darks = !null
  *self.dark_times = !null
  *self.dark_exptimes = !null
  *self.dark_mode_gains = !null
end


;+
; Retrieve a dark image for a given science image.
;
; :Returns:
;   interpolated by time dark image, `fltarr(nx, ny, nc)`
;
; :Params:
;   obsday_hours : in, required, type=float
;     time of science image in hours into the observing day
;   exptime : in, required, type=float
;     exposure time [ms] needed
;   gain_mode : in, required, type=string
;     gain mode of required dark, i.e., "high" or "low"
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether a suitable dark was found
;-
function ucomp_calibration::get_dark, obsday_hours, exptime, gain_mode, $
                                      found=found, $
                                      extensions=extensions, $
                                      coefficients=coefficients
  compile_opt strictarr

  found = 0B
  if (n_elements(*self.darks) eq 0L) then return, !null

  ; find the darks with an exposure time that is close enough to the given
  ; exptime
  exptime_threshold = 0.01   ; [ms]
  gain_index = gain_mode eq 'high'
  valid_indices = where((exptime - *self.dark_exptimes) lt exptime_threshold $
                          and (*self.dark_gain_modes eq gain_index), $
                        n_valid_darks)
  if (n_valid_darks eq 0L) then return, !null

  found = 1B

  ; find closest two darks (or closest dark if before first dark or after last
  ; dark)
  valid_darks = (*self.darks)[valid_indices]
  valid_times = (*self.dark_times)[valid_indices]
  if (obsday_hours lt valid_times[0]) then begin               ; before first dark
    interpolated_dark = valid_darks[0]

    extensions = valid_indices[0] + 1L
    coefficients = 1.0
  endif else if (obsday_hours gt valid_times[-1]) then begin   ; after last dark
    interpolated_dark = valid_darks[-1]

    extensions = valid_indices[-1] + 1L
    coefficients = 1.0
  endif else begin                                     ; between darks
    index1 = value_locate(valid_times, obsday_hours)
    index2 = index1 + 1L

    dark1 = valid_darks[index1]
    dark2 = valid_darks[index2]

    a1 = (valid_times[index2] - obsday_hours) / (valid_times[index2] - valid_times[index1])
    a2 = (obsday_hours - valid_times[index1]) / (valid_times[index2] - valid_times[index1])

    interpolated_dark = a1 * dark1 + a2 * dark2

    extensions = [index1, index2]
    coefficients = [a1, a2]
  endelse

  return, interpolated_dark
end


;= handle flats

;+
; Cache the master flat files.
;
; :Params:
;   filenames : in, optional, type=strarr
;     filename of master flat files, if not present, then `flats`, `times`,
;     `exptimes`, `wavelengths`, and `gain_modes` must be present
;
; :Keywords:
;   flats : in, optional, type="fltarr(nx, ny, n_pol_states, n_cameras, n)"
;     flat images
;   times : in, optional, type=fltarr(n)
;     times of the darks [hours into observing day]
;   exptimes : in, optional, type=fltarr(n)
;     exposure times of the darks [ms]
;   wavelengthss : in, optional, type=fltarr(n)
;     wavelengths of the darks [nm]
;   gain_modes : in, optional, type=bytarr(n)
;     gain modes of the darks [ms]
;-
pro ucomp_calibration::cache_flats, filenames, $
                                    flats=flats, $
                                    times=times, $
                                    exptimes=exptimes, $
                                    wavelengths=wavelengths, $
                                    gain_modes=gain_modes, $
                                    extensions=extensions, $
                                    raw_files=raw_files
  compile_opt strictarr

  self.run->getProperty, logger_name=logger_name
  mg_log, 'caching flats...', name=logger_name, /info

  ; master flat file with extensions 1..n:
  ;   exts 1 to n - 4:   flat images
  ;   ext n - 3:         times of the flat images
  ;   ext n - 2:         exposure times of the flat images 
  ;   ext n - 1:         wavelengths of the flat images
  ;   ext n:             gain modes of the flat images 

  if (n_elements(filenames) gt 0L) then begin
    ; determine total number of flats in all flat files
    n_flats = 0L
    for f = 0L, n_elements(filenames) - 1L do begin
      fits_open, filenames[f], fcb
      n_flats += fcb.nextend - 4L  ; not including the index extensions
      fits_close, fcb
    endfor

    flats = fltarr(nx, ny, n_pol_states, n_cameras, n_flats)
    times = fltarr(n_flats)
    exptimes = fltarr(n_flats)
    wavelengths = fltarr(n_flats)
    gain_modes = lonarr(n_flats)
    extensions = lonarr(n_flats)
    raw_files = strarr(n_flats)

    i = 0L
    for f = 0L, n_elemens(filenames) - 1L do begin
      fits_open, filenames[f], fcb

      for e = 1L, fcb.nextend - 4L do begin   ; there are 4 "index" extensions at end of file
        fits_read, fcb, flat_image, flat_header, exten_no=e
        flats[0, 0, 0, 0, i + e - 1L] = flat_image
        raw_files[e - 1L] = ucomp_getpar(flat_header, 'RAWFILE')
        extensions[e - 1] = e
      endfor

      ; read index extensions
      fits_read, fcb, flat_times, times_header, exten_no=fcb.nextend - 3L
      fits_read, fcb, flat_exptimes, exptimes_header, exten_no=fcb.nextend - 2L
      fits_read, fcb, flat_wavelengths, wavelengths_header, exten_no=fcb.nextend - 1L
      fits_read, fcb, flat_gain_modes, gain_modes_header, exten_no=fcb.nextend

      times[i] = flat_times
      exptimes[i] = flat_exptimes
      wavelengths[i] = flat_wavelengths
      gain_modes[i] = flat_gain_modes

      fits_close, fcb
    endfor
  endif

  ; concatenate over the last (5th, i.e., index 4) dimension if flats are
  ; already present
  if (n_elements(*self.flats) eq 0L) then begin
    *self.flats = flats
  endif else begin
    dims = size(*self.flats, /dimensions)
    n_existing_flats = n_elements(*self.flat_times)
    n_appending_flats = n_elements(times)

    new_dims = [dims[0:3], n_existing_flats + n_appending_flats]
    new_flats = make_array(new_dims, type=size(flats, /type))
    new_flats[0, 0, 0, 0, 0] = *self.flats
    new_flats[0, 0, 0, 0, n_existing_flats] = flats

    *self.flats = new_flats
  endelse

  *self.flat_times = n_elements(*self.flat_times) eq 0L $
                       ? times $
                       : [*self.flat_times, times]
  *self.flat_exptimes = n_elements(*self.flat_exptimes) eq 0L $
                          ? exptimes $
                          : [*self.flat_exptimes, exptimes]
  *self.flat_wavelengths = n_elements(*self.flat_wavelengths) eq 0L $
                             ? wavelengths $
                             : [*self.flat_wavelengths, wavelengths]
  *self.flat_gain_modes = n_elements(*self.flat_gain_modes) eq 0L $
                            ? gain_modes $
                            : [*self.flat_gain_modes, gain_modes]
  *self.flat_extensions = n_elements(*self.flat_extensions) eq 0L $
                            ? extensions $
                            : [*self.flat_extensions, extensions]
  *self.flat_raw_files = n_elements(*self.flat_raw_files) eq 0L $
                            ? raw_files $
                            : [*self.flat_raw_files, raw_files]

  mg_log, '%d flats cached', n_elements(times), name=logger_name, /info
  mg_log, '%d total flats cached', n_elements(*self.flat_times), name=logger_name, /info
end


;+
; Discard the flat cache.
;-
pro ucomp_calibration::discard_flats
  compile_opt strictarr

  *self.flats = !null
  *self.flat_times = !null
  *self.flat_exptimes = !null
  *self.flat_wavelengths = !null
  *self.flat_gain_modes = !null
  *self.flat_extensions = !null
  *self.flat_raw_files = !null
end


;+
; Retrieve a flat image for a given science image.
;
; :Returns:
;   flat image, `fltarr(nx, ny, np, nc)`
;
; :Params:
;   obsday_hours : in, required, type=float
;     time of science image in hours into the observing day
;   exptime : in, required, type=float
;     exposure time [ms] needed
;   gain_mode : in, required, type=string
;     gain mode of required dark, i.e., "high" or "low"
;   wavelength : in, required, type=float
;     wavelength of science image in nm
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether a suitable dark was found
;   time_found : out, optional, type=float
;     set to a named variable to retrieve the time (in hours into the observing
;     day) of the found flat
;-
function ucomp_calibration::get_flat, obsday_hours, exptime, gain_mode, wavelength, $
                                      found=found, $
                                      time_found=time_found, $
                                      extension=extension, $
                                      raw_file=raw_file
  compile_opt strictarr

  found = 0B
  if (n_elements(*self.flats) eq 0L) then return, !null

  ; find the darks with an exposure time and wavelength that is close enough to
  ; the given exptime and wavelength
  exptime_threshold = 0.01      ; [ms]
  wavelength_threshold = 0.001  ; [nm]

  gain_index = gain_mode eq 'high'
  valid_indices = where(abs(exptime - *self.flat_exptimes) lt exptime_threshold $
                          and abs(wavelength - *self.flat_wavelengths) lt wavelength_threshold $
                          and (*self.flat_gain_modes eq gain_index), $
                        n_valid_flats)
  if (n_valid_flats eq 0L) then return, !null

  found = 1B

  ; find index of valid flat taken nearest specificed time
  !null = min(abs(obsday_hours - (*self.flat_times)[valid_indices]), nearest_time_index)

  ; convert nearest time index from index into valid flats to index into all flats
  nearest_time_index = valid_indices[nearest_time_index]

  time_found = (*self.flat_times)[nearest_time_index]
  extension = (*self.flat_extensions)[nearest_time_index]
  raw_file = (*self.flat_raw_files)[nearest_time_index]

  return, reform((*self.flats)[*, *, *, *, nearest_time_index])
end


;+
; Free resources.
;-
pro ucomp_calibration::cleanup
  compile_opt strictarr

  ptr_free, self.darks, self.dark_times, self.dark_exptimes, $
            self.dark_gain_modes
  ptr_free, self.flats, self.flat_times, self.flat_exptimes, $
            self.flat_wavelengths, self.flat_gain_modes, $
            self.flat_extensions, self.flat_raw_files

end


;+
; Initialize the calibration object.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_calibration::init, run=run
  compile_opt strictarr

  self.run = run

  ; master dark cache
  self.darks            = ptr_new(/allocate_heap)
  self.dark_times       = ptr_new(/allocate_heap)
  self.dark_exptimes    = ptr_new(/allocate_heap)
  self.dark_gain_modes  = ptr_new(/allocate_heap)

  ; master flat cache
  self.flats            = ptr_new(/allocate_heap)
  self.flat_times       = ptr_new(/allocate_heap)
  self.flat_exptimes    = ptr_new(/allocate_heap)
  self.flat_wavelengths = ptr_new(/allocate_heap)
  self.flat_gain_modes  = ptr_new(/allocate_heap)
  self.flat_extensions  = ptr_new(/allocate_heap)
  self.flat_raw_files   = ptr_new(/allocate_heap)

  return, 1
end


;+
; Define the fields of a calibration object.
;-
pro ucomp_calibration__define
  compile_opt strictarr

  !null = {ucomp_calibration, inherits IDL_Object, $
           run : obj_new(), $

           ; master dark cache
           darks: ptr_new(), $
           dark_times: ptr_new(), $
           dark_exptimes: ptr_new(), $
           dark_gain_modes: ptr_new(), $
   
           ; master flat cache 
           flats: ptr_new(), $             ; fltarr(nx, ny, 4, 2, n_flats)
           flat_times: ptr_new(), $        ; obsday hours
           flat_exptimes: ptr_new(), $     ; [ms] exposure time
           flat_wavelengths: ptr_new(), $  ; [nm] wavelengths
           flat_gain_modes: ptr_new(), $   ; 'high' or 'low'
           flat_extensions: ptr_new(), $   ; extension into flat file
           flat_raw_files: ptr_new() $     ; basename of raw file containing flat

           ; TODO: demodulation matrices
  }
end
