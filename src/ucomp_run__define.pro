; docformat = 'rst'


;= API

;+
; Create an inventory of the raw files for a run.
;
; :Params:
;   raw_files : in, optional, type=strarr
;     raw files to inventory, default is all raw files in the `l0_dir`
;
; :Keywords:
;   data_types : out, optional, type=strarr
;     set to a named variable to retrieve the data types of the given files
;   wave_regions : out, optional, type=strarr
;     set to a named variable to retrieve the wave regions of the given files
;   n_extensions : out, optional, type=lonarr
;     set to a named variable to retrieve the number of extensions for each of
;     the given files
;  exptimes : out, optional, type=fltarr
;     set to a named variable to retrieve the exptime [ms] for the given files
;  gain_modes : out, optional, type=strarr
;     set to a named variable to retrieve the gain modes [high/low] for the
;     given files
;  n_points : out, optional, type=lonarr
;     set to a named variable to retrieve the number of unique wavelengths for
;     the given files
;-
pro ucomp_run::make_raw_inventory, raw_files, $
                                   n_extensions=n_extensions, $
                                   data_types=data_types, $
                                   exptimes=exptimes, $
                                   gain_modes=gain_modes, $
                                   wave_regions=wave_regions, $
                                   n_points=n_points
  compile_opt strictarr

  self->getProperty, logger_name=logger_name

  raw_dir = filepath(self.date, root=self->config('raw/basedir'))

  if (n_params() eq 0L) then begin
    _raw_files = file_search(filepath('*.fts', root=raw_dir), count=n_raw_files)
  endif else begin
    n_raw_files = n_elements(raw_files)
    if (n_raw_files gt 0L) then begin
      _raw_files = filepath(raw_files, root=raw_dir)
    endif
  endelse

  n_extensions = n_raw_files eq 0L ? !null : lonarr(n_raw_files)
  data_types   = n_raw_files eq 0L ? !null : strarr(n_raw_files)
  exptimes     = n_raw_files eq 0L ? !null : fltarr(n_raw_files)
  gain_modes   = n_raw_files eq 0L ? !null : strarr(n_raw_files)
  wave_regions = n_raw_files eq 0L ? !null : strarr(n_raw_files)
  n_points     = n_raw_files eq 0L ? !null : lonarr(n_raw_files)

  mg_log, '%d raw files', n_raw_files, name=logger_name, /info
  for f = 0L, n_raw_files - 1L do begin
    file = ucomp_file(_raw_files[f])

    mg_log, '%s.%s [%s nm] %s', $
            file.ut_date, file.ut_time, $
            file.wave_region, $
            file.data_type, $
            name=logger_name, /debug

    n_extensions[f] = file.n_extensions
    data_types[f] = file.data_type
    exptimes[f] = file.exptime
    gain_modes[f] = file.gain_mode
    wave_regions[f] = file.wave_region
    n_points[f] = file.n_unique_wavelengths

    ; store files by data type and wave type

    if (~(self.files)->hasKey(file.data_type)) then (self.files)[file.data_type] = orderedhash()
    dtype_hash = (self.files)[file.data_type]

    if (~dtype_hash->hasKey(file.wave_region)) then dtype_hash[file.wave_region] = list()
    (dtype_hash)[file.wave_region]->add, file
  endfor
end


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
pro ucomp_run::cache_darks, filename, $
                            darks=darks, $
                            times=times, $
                            exptimes=exptimes, $
                            gain_modes=gain_modes
  compile_opt strictarr

  self->getProperty, logger_name=logger_name
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
pro ucomp_run::discard_darks
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
function ucomp_run::get_dark, obsday_hours, exptime, gain_mode, $
                              found=found, $
                              extensions=extensions, $
                              coefficients=coefficients
  compile_opt strictarr

  found = 0B

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


;+
; Retrieve files after an inventory has been completed.
;
; :Returns:
;   `objarr` of `ucomp_file` objects
;
; :Keywords:
;   wave_region : in, optional, type=string
;     set to wave type of files to return: '1074', '1079', etc.; by default,
;     returns files of all wave types
;   data_type : in, optional, type=string
;     set to data type of files to return: 'sci', 'cal', etc.; by default,
;     returns files of all data_types
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of files returned
;-
function ucomp_run::get_files, wave_region=wave_region, data_type=data_type, $
                               count=count
  compile_opt strictarr

  count = 0L   ; set for all the special cases that return early

  case 1 of
    n_elements(wave_region) eq 0L && n_elements(data_type) eq 0L: begin
        files_list = list()
        foreach dtype_hash, self.files, dtype do begin
          foreach wregion_list, dtype_hash, wregion do begin
            files_list->add, wregion_list, /extract
          endforeach
        endforeach
        files = files_list->toArray()
        count = files_list->count()
        obj_destroy, files_list
      end
    n_elements(wave_region) eq 0L: begin
        if (~(self.files)->hasKey(data_type)) then return, !null

        files_list = list()
        foreach wregion_list, (self.files)[data_type], wregion do begin
          files_list->add, wregion_list, /extract
        endforeach
        files = files_list->toArray()
        count = files_list->count()
        obj_destroy, files_list
      end
    n_elements(data_type) eq 0L: begin
        files_list = list()
        foreach dtype_hash, self.files, dtype do begin
          if (~dtype_hash->hasKey(wave_region)) then continue
          files_list->add, dtype_hash[wave_region], /extract
        endforeach
        files = files_list->toArray()
        count = files_list->count()
        obj_destroy, files_list
      end
    else: begin
        if (~(self.files)->hasKey(data_type)) then return, !null
        if (~((self.files)[data_type])->hasKey(wave_region)) then return, !null

        files_list = ((self.files)[data_type])[wave_region]
        files = files_list->toArray()
        count = files_list->count()
      end
  endcase

  return, files
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
pro ucomp_run::cache_flats, filenames, $
                            flats=flats, $
                            times=times, $
                            exptimes=exptimes, $
                            wavelengths=wavelengths, $
                            gain_modes=gain_modes
  compile_opt strictarr

  self->getProperty, logger_name=logger_name
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

    i = 0L
    for f = 0L, n_elemens(filenames) - 1L do begin
      fits_open, filenames[f], fcb

      for e = 1L, fcb.nextend - 4L do begin   ; there are 4 "index" extensions at end of file
        fits_read, fcb, flat_image, flat_header, exten_no=e
        flats[0, 0, 0, 0, i + e - 1L] = flat_image
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

  mg_log, '%d flats cached', n_elements(times), name=logger_name, /info
  mg_log, '%d total flats cached', n_elements(*self.flat_times), name=logger_name, /info
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
;   found_time : out, optional, type=float
;     set to a named variable to retrieve the time (in hours into the observing
;     day) of the found flat
;-
function ucomp_run::get_flat, obsday_hours, exptime, gain_mode, wavelength, $
                              found=found, $
                              time_found=time_found, $
                              extensions=extensions
  compile_opt strictarr

  found = 0B

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

  ; find index of valid flat taken nearest specificed time
  !null = min(abs(obsday_hours - (*self.flat_times)[valid_indices]), nearest_time_index)

  ; convert nearest time index from index into valid flats to index into all flats
  nearest_time_index = valid_indices[nearest_time_index]

  time_found = (*self.flat_times)[nearest_time_index]

  return, reform((*self.flats)[*, *, *, *, nearest_time_index])
end


;+
; Lock the raw directory if required and available.
;
; :Keywords:
;   is_available : out, optional, type=boolean
;     set to a named variable to retrieve whether the raw directory was
;     available, and therefore locked
;-
pro ucomp_run::lock, is_available=is_available
  compile_opt strictarr

  self->getProperty, logger_name=logger_name

  is_available = ucomp_state(self.date, run=self)
  if (is_available) then begin
    !null = ucomp_state(self.date, /lock, run=self)
    mg_log, 'locked %s', self.date, name=logger_name, /info
  endif else begin
    mg_log, '%s not available, skipping', self.date, name=logger_name, /info
  endelse
end


;+
; Unlock raw directory and, if `MARK_PROCESSED` is set, mark as processed.
;
; :Keywords:
;   mark_processed : in, optional, type=boolean
;     set to indicate that directory should be marked as processed after
;     unlocking
;-
pro ucomp_run::unlock, mark_processed=mark_processed
  compile_opt strictarr

  self->getProperty, logger_name=logger_name

  if (~ucomp_state(self.date, run=self)) then begin
    unlocked = ucomp_state(self.date, /unlock, run=self)
    mg_log, 'unlocked %s', self.date, name=logger_name, /info
    if (keyword_set(mark_processed)) then begin
      processed = ucomp_state(self.date, /processed, run=self)
      mg_log, 'marked %s as processed', self.date, name=logger_name, /info
    endif
  endif
end


;= performance monitoring API

;+
; Start profiler.
;-
pro ucomp_run::start_profiler
  compile_opt strictarr

  if (~self->config('engineering/profile')) then return

  ; resolve all routines
  skip_files = ['mg_log_common', 'ucomp_run__define']

  subdirs = ['gen', 'lib', 'src', 'ssw']
  top_dir = filepath('', subdir=['..'], root=mg_src_root())
  for d = 0L, n_elements(subdirs) - 1L do begin
    files = file_search(filepath(subdirs[d], root=top_dir), $
                        '*.pro', $
                        count=n_files)
    routines = file_basename(files, '.pro')

    for r = 0L, n_files - 1L do begin
      !null = where(routines[r] eq skip_files, n_matched)
      if (n_matched eq 0L) then begin
        mg_resolve_routine, routines[r], $
                            /either, /compile_full_file, /no_recompile
      endif
    endfor
  endfor

  ; start profiling routines
  profiler, /system
  profiler
end


;+
; Report profiling output.
;-
pro ucomp_run::report_profiling
  compile_opt strictarr

  if (~self->config('engineering/profile')) then return

  ; quit if no place to put profile results
  engineering_basedir = self->config('engineering/basedir')
  if (n_elements(engineering_basedir) eq 0L) then begin
    mg_log, 'no engineering/basedir to save profiling', $
            name=self.logger_name, /warn
    return
  endif

  ; if needed, create engineering directory
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(self.date), $
                     root=engineering_basedir)
  if (~file_test(eng_dir, /directory)) then begin
    self->getProperty, logger_name=logger_name
    ucomp_mkdir, eng_dir, logger_name=logger_name
  endif

  basename = string(self.date, format='(%"%s.ucomp.profiler.csv")')
  filename = filepath(basename, root=eng_dir)
    
  mg_profiler_report, filename=filename, /csv
end


;+
; :Returns:
;   clock identifier structure with fields `name` (string) and `time` (double)
;
; :Params:
;   routine_name : in, required, type=string
;     name of routine being timed
;-
function ucomp_run::start, routine_name
  compile_opt strictarr

  if (self.calls->hasKey(routine_name)) then begin
    (self.calls)[routine_name] += 1
  endif else begin
    (self.calls)[routine_name] = 1
  endelse
  
  return, tic(routine_name)
end


;+
; Call to indicate the routine with the corresponding `clock_id` is done,
; returning the total time of the execution.
;
; :Returns:
;   float
;
; :Params:
;   clock_id : in, required, type=structure
;     clock identifier from `::start`
;-
function ucomp_run::stop, clock_id
  compile_opt strictarr

  time = toc(clock_id)

  if (self.times->hasKey(clock_id.name)) then begin
    (self.times)[clock_id.name] += time
  endif else begin
    (self.times)[clock_id.name] = time
  endelse

  return, time
end


;+
; Write the performance log.
;-
pro ucomp_run::report
  compile_opt strictarr

  ; if needed, create engineering directory 
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(self.date), $
                     root=self->config('engineering/basedir'))
  if (~file_test(eng_dir, /directory)) then begin
    self->getProperty, logger_name=logger_name
    ucomp_mkdir, eng_dir, logger_name=logger_name
  endif

  basename = string(self.date, format='(%"%s.ucomp.perf.txt")')
  filename = filepath(basename, root=eng_dir)

  openw, lun, filename, /get_lun

  widths = [35, 32, 10, 10]
  printf, lun, 'routine name', 'total time', '# calls', 'secs/call', $
          format=mg_format('%*s %*s %*s %*s', widths)
  printf, lun, mg_repstr('-', widths), format='(%"%s %s %s %s")'
  foreach n_calls, self.calls, routine_name do begin
    if (self.times->hasKey(routine_name)) then begin
      time = (self.times)[routine_name]
    endif else begin
      time = !values.f_nan
    endelse

    if (finite(time)) then begin
      time_str = ucomp_sec2str(time)
      mean_time = time / n_calls
    endif else begin
      mean_time = !values.f_nan
      time_str = 'NaN'
    endelse

    printf, lun, routine_name, time_str, n_calls, mean_time, $
            format=mg_format('%-*s %*s %*d %*.3f', widths)
  endforeach

  free_lun, lun
end


;= epoch values

;+
; Retrieve the epoch value for a given option name.
;
; :Returns:
;   any
;
; :Params:
;   option_name : in, required, type=string
;     name of an epoch option
;
; :Keywords:
;   datetime : in, optional, type=string
;     datetime in the form 'YYYYMMDD' or 'YYYYMMDD.HHMMSS'; defaults to the
;     value of the `DATETIME` property if this keyword is not given
;-
function ucomp_run::epoch, option_name, datetime=datetime
  compile_opt strictarr
  on_error, 2

  value = self.epochs->get(option_name, datetime=datetime)

  return, value
end


;+
; Retrieve the value for a given option name for a given line.
;
; :Returns:
;   any
;
; :Params:
;   line : in, required, type=string
;     line name, e.g., '1074'
;   option_name : in, required, type=string
;     name of an epoch option, e.g., 'center_wavelength'
;-
function ucomp_run::line, line, option_name
  compile_opt strictarr

  if (n_elements(line) eq 0L) then begin
    self.lines->getProperty, spec=spec
    return, spec->sections(count=n_sections)
  endif

  value = self.lines->get(option_name, section=line, found=found)
  return, value
end

;+
; Retrieve the names of all the lines.
;
; :Returns:
;   strarr
;-
function ucomp_run::all_lines
  compile_opt strictarr

  self.lines->getProperty, spec=spec
  return, spec->sections()
end


;= config values

;+
; Get a config file value.
;
; :Returns:
;   value of the correct type
;
; :Params:
;   name : in, required, type=string
;     section and option name in the form "section/option"
;-
function ucomp_run::config, name
  compile_opt strictarr
  on_error, 2

  tokens = strsplit(name, '/', /extract, count=n_tokens)
  if (n_tokens ne 2) then message, 'bad format for config option name'

  value = self.options->get(tokens[1], section=tokens[0], found=found)

  if (name eq 'raw/basedir' && n_elements(value) eq 0L) then begin
    routing_file = self.options->get('routing_file', section='raw')
    value = ucomp_get_route(routing_file, self.date)
  endif

  return, value
end


;= property access

;+
; Get properties.
;-
pro ucomp_run::getProperty, date=date, $
                            mode=mode, $
                            logger_name=logger_name, $
                            config_contents=config_contents, $
                            all_wave_regions=all_wave_regions, $
                            t0=t0
  compile_opt strictarr
  on_error, 2

  if (arg_present(date)) then date = self.date
  if (arg_present(mode)) then mode = self.mode

  if (arg_present(logger_name)) then begin
    logger_name = string(self.mode, format='(%"ucomp/%s")')
  endif

  if (arg_present(config_contents)) then begin
    config_contents = reform(self.options->_toString(/substitute))
  endif

  if (arg_present(all_wave_regions)) then begin
    wregion_hash = orderedhash()
    foreach dtype_hash, self.files, dtype do begin
      foreach wregion_list, dtype_hash, wregion do begin
        wregion_hash[wregion] = 1B
      endforeach
    endforeach
    all_wave_regions = (wregion_hash->keys())->toArray()
    obj_destroy, wregion_hash
  endif

  if (arg_present(t0)) then t0 = self.t0
end


;+
; Set properties.
;-
pro ucomp_run::setProperty, datetime=datetime, $
                            t0=t0
  compile_opt strictarr
  on_error, 2

  if (n_elements(datetime) gt 0L) then self.epochs->setProperty, datetime=datetime
  if (n_elements(t0) gt 0L) then self.t0 = t0
end


;= overload operators

function ucomp_run::_overloadPrint
  compile_opt strictarr

  return, transpose(['UCoMP run', $
                    '  date: ' + self.date, $
                    '  mode: ' + self.mode])
end

function ucomp_run::_overloadHelp, varname
  compile_opt strictarr

  type = 'UCoMP run'
  specs = string(self.date, format='(%"%s")')
  return, string(varname, type, specs, format='(%"%-15s %-9s = <%s>")')
end


;= initialization


;+
; Rotate logs and use config file values to setup the logger.
;-
pro ucomp_run::_setup_logger
  compile_opt strictarr
  on_error, 2

  ; log message formats

  fmt = '%(time)s %(levelshortname)s: %(routine)s: %(message)s'
  if (self->config('logging/include_pid')) then fmt = '[%(pid)s] ' + fmt
  time_fmt = '(C(CYI4, CMOI2.2, CDI2.2, "." CHI2.2, CMI2.2, CSI2.2))'

  ; get logging values from config file
  log_dir     = self->config('logging/dir')
  level_name  = self->config('logging/level')
  max_version = self->config('logging/max_version')
  max_width   = self->config('logging/max_width')

  ; setup log directory and file
  basename = string(self.date, self.mode, format='(%"%s.ucomp.%s.log")')
  filename = filepath(basename, root=log_dir)
  if (~file_test(log_dir, /directory)) then begin
    self->getProperty, logger_name=logger_name
    ucomp_mkdir, log_dir, logger_name=logger_name
  endif

  ; rotate logs
  if (self.mode ne 'realtime') then begin
    mg_rotate_log, filename, max_version=max_version
  endif

  ; configure logger
  self->getProperty, logger_name=logger_name
  mg_log, name=logger_name, logger=logger
  logger->setProperty, format=fmt, $
                       time_format=time_fmt, $
                       max_width=max_width, $
                       level=mg_log_name2level(level_name), $
                       filename=filename
end


;= lifecycle methods

;+
; Free resources.
;-
pro ucomp_run::cleanup
  compile_opt strictarr

  ptr_free, self.darks, self.dark_times, self.dark_exptimes, $
            self.dark_gain_modes
  ptr_free, self.flats, self.flat_times, self.flat_exptimes, $
            self.flat_wavelengths, self.flat_gain_modes

  obj_destroy, [self.options, self.epochs, self.lines]

  ; master dark cache
  ptr_free, self.darks, self.dark_times, self.dark_exptimes

  ; performance monitoring API
  obj_destroy, [self.calls, self.times]

  foreach wave_region, self.files do begin
    foreach file, wave_region do obj_destroy, file
    obj_destroy, wave_region
  endforeach
  obj_destroy, self.files
end


;+
; Initialize the run.
;
; :Params:
;   date : in, required, type=string
;     observing date in the form 'YYYYMMDD'; this is the local HST date of the
;     observations, i.e., it does not change at midnight UT during the middle of
;     an observing day
;   mode : in, required, type=string
;     mode, i.e., either 'realtime' or 'eod'
;   config_filename : in, required, type=string
;     filename of config file specifying the run
;
; :Keywords:
;   no_log : in, optional, type=boolean
;     set to not initialize the logs
;-
function ucomp_run::init, date, mode, config_filename, no_log=no_log
  compile_opt strictarr

  self.date = date
  self.mode = mode

  self->getProperty, logger_name=logger_name

  ; setup config options
  config_spec_filename = filepath('ucomp.spec.cfg', $
                                  subdir=['..', 'config'], $
                                  root=mg_src_root())

  self.options = mg_read_config(config_filename, spec=config_spec_filename)
  config_valid = self.options->is_valid(error_msg=error_msg)
  if (~config_valid) then begin
    mg_log, 'invalid configuration file', name=logger_name, /critical
    mg_log, '%s', error_msg, name=logger_name, /critical
    return, 0
  endif

  if (~keyword_set(no_log)) then self->_setup_logger

  ; setup epoch reading
  epochs_filename = filepath('epochs.cfg', root=mg_src_root())
  epochs_spec_filename = filepath('epochs.spec.cfg', root=mg_src_root())

  self.epochs = mgffepochparser(epochs_filename, epochs_spec_filename)
  epochs_valid = self.epochs->is_valid(error_msg=error_msg)
  if (~epochs_valid) then begin
    mg_log, 'invalid epochs file', name=logger_name, /critical
    mg_log, '%s', error_msg, name=logger_name, /critical
    return, 0
  endif

  ; setup information about lines
  lines_filename = filepath('lines.cfg', root=mg_src_root())
  lines_spec_filename = filepath('lines.spec.cfg', root=mg_src_root())

  self.lines = mg_read_config(lines_filename, spec=lines_spec_filename)
  lines_valid = self.lines->is_valid(error_msg=error_msg)
  if (~lines_valid) then begin
    mg_log, 'invalid lines file', name=logger_name, /critical
    mg_log, '%s', error_msg, name=logger_name, /critical
    return, 0
  endif

  self.files = orderedhash()   ; wave_region (string) -> list of file objects

  ; master dark cache
  self.darks            = ptr_new(/allocate_heap)
  self.dark_times       = ptr_new(/allocate_heap)
  self.dark_exptimes    = ptr_new(/allocate_heap)
  self.dark_gain_modes  = ptr_new(/allocate_heap)

  self.flats            = ptr_new(/allocate_heap)
  self.flat_times       = ptr_new(/allocate_heap)
  self.flat_exptimes    = ptr_new(/allocate_heap)
  self.flat_wavelengths = ptr_new(/allocate_heap)
  self.flat_gain_modes  = ptr_new(/allocate_heap)

  ; performance monitoring
  self.calls = orderedhash()   ; routine name (string) -> # of calls (long)
  self.times = orderedhash()   ; routine name (string) -> times (float) in seconds

  return, 1
end


;+
; Define the data in the run class.
;-
pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date:    '', $
           mode:    '', $          ; eod, realtime, cal
           t0:      0.0D, $
           options: obj_new(), $
           epochs:  obj_new(), $
           lines:   obj_new(), $
           files:   obj_new(), $

           ; master dark cache
           darks: ptr_new(), $
           dark_times: ptr_new(), $
           dark_exptimes: ptr_new(), $
           dark_gain_modes: ptr_new(), $

           ; master flat cache
           flats: ptr_new(), $
           flat_times: ptr_new(), $
           flat_exptimes: ptr_new(), $
           flat_wavelengths: ptr_new(), $
           flat_gain_modes: ptr_new(), $

           ; performance
           calls:   obj_new(), $
           times:   obj_new()}
end
