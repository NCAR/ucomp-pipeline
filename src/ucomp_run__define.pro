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
;   n_extensions : out, optional, type=lonarr
;     set to a named variable to retrieve the number of extensions for each of
;     the given files
;   data_types : out, optional, type=strarr
;     set to a named variable to retrieve the data types of the given files
;   exptimes : out, optional, type=fltarr
;     set to a named variable to retrieve the exptime [ms] for the given files
;   gain_modes : out, optional, type=strarr
;     set to a named variable to retrieve the gain modes [high/low] for the
;     given files
;   wave_regions : out, optional, type=strarr
;     set to a named variable to retrieve the wave regions of the given files
;   n_points : out, optional, type=lonarr
;     set to a named variable to retrieve the number of unique wavelengths for
;     the given files
;   numsum : out, optional, type=lonarr
;     set to a named variable to retrieve the NUMSUM for the given files
;-
pro ucomp_run::make_raw_inventory, raw_files, $
                                   n_extensions=n_extensions, $
                                   data_types=data_types, $
                                   exptimes=exptimes, $
                                   gain_modes=gain_modes, $
                                   wave_regions=wave_regions, $
                                   n_points=n_points, $
                                   numsum=numsum
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
  numsum       = n_raw_files eq 0L ? !null : lonarr(n_raw_files)

  mg_log, '%d raw files', n_raw_files, name=logger_name, /info
  n_digits = floor(alog10(n_raw_files)) + 1L
  for f = 0L, n_raw_files - 1L do begin
    basename = file_basename(_raw_files[f])
    dt = strmid(basename, 0, 15)
    if (~self->epoch('process', datetime=dt)) then begin
      mg_log, 'skipping %s', dt, name=logger_name, /debug
      continue
    endif

    file = ucomp_file(_raw_files[f], run=self)

    mg_log, '%s/%d: %s.%s [%s] %s', $
            string(f + 1L, format=mg_format('%*d', n_digits)), $
            n_raw_files, $
            file.ut_date, $
            file.ut_time, $
            file.wave_region eq '' ? '-------' : string(file.wave_region, format='(%"%4s nm")'), $
            file.data_type, $
            name=logger_name, /debug

    n_extensions[f] = file.n_extensions
    data_types[f] = file.data_type
    exptimes[f] = file.exptime
    gain_modes[f] = file.gain_mode
    wave_regions[f] = file.wave_region
    n_points[f] = file.n_unique_wavelengths
    numsum[f] = file.numsum

    ; store files by data type and wave type

    if (~(self.files)->hasKey(file.data_type)) then (self.files)[file.data_type] = orderedhash()
    dtype_hash = (self.files)[file.data_type]

    if (~dtype_hash->hasKey(file.wave_region)) then dtype_hash[file.wave_region] = list()
    (dtype_hash)[file.wave_region]->add, file
  endfor
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
;   program_name : in, optional, type=string
;     set to program name of files to return
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of files returned
;-
function ucomp_run::get_files, wave_region=wave_region, $
                               data_type=data_type, $
                               program_name=program_name, $
                               count=count
  compile_opt strictarr
  on_error, 2

  count = 0L   ; set for all the special cases that return early

  case 1 of
    n_elements(program_name) gt 0L: begin
      if (n_elements(wave_region) eq 0L) then message, 'WAVE_REGION not provided'
      if (~(self.files)->hasKey('sci')) then return, !null

      files_list = ((self.files)['sci'])[wave_region]
      files = files_list->toArray()
      n_files = n_elements(files)

      program_names = strarr(n_files)
      ok = bytarr(n_files)
      for f = 0L, n_files - 1L do begin
        program_names[f] = files[f].program_name
        ok[f] = files[f].ok
      endfor
      matching_indices = where(program_names eq program_name and ok, $
                               n_matching, /null)

      count = n_matching
      return, files[matching_indices]
    end
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


;+
; Get the program names for a given wave region.
;
; :Returns:
;   `strarr`
;
; :Params:
;   wave_region : in, optional, type=string
;     set to specific wave region to retrieve program names for that wave
;     region, returns programs from all wave regions if not set
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of program names returned
;-
function ucomp_run::get_programs, wave_region, count=count
  compile_opt strictarr

  count = 0L
  if (~self->line(wave_region, 'create_average')) then return, !null

  files = self->get_files(wave_region=wave_region, data_type='sci', $
                          count=n_files)
  if (n_files eq 0L) then return, !null

  program_names = strarr(n_files)
  for f = 0L, n_files - 1L do program_names[f] = files[f].program_name

  ; remove empty program names
  nonempty_program_indices = where(program_names ne '', n_nonempty_programs)
  if (n_nonempty_programs eq 0L) then begin
    count = 0L
    return, !null
  endif
  program_names = program_names[nonempty_program_indices]

  ; keep only unique program names
  unique_program_indices = uniq(program_names, sort(program_names))
  count = n_elements(unique_program_indices)
  return, program_names[unique_program_indices]
end


;+
; Convert an internal program name a name suitable for data users.
;
; :Returns:
;   string
;
; :Params:
;   program_name : in, required, type=string
;     internal program name
;-
function ucomp_run::convert_program_name, program_name
  compile_opt strictarr

  return, self.program_names->get(program_name, section='DEFAULT', default=program_name)
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
  basedir = self->config('processing/basedir')
  is_available = ucomp_state(self.date, $
                             basedir=basedir, $
                             logger_name=logger_name)
  if (is_available) then begin
    !null = ucomp_state(self.date, /lock, $
                        basedir=basedir, $
                        logger_name=logger_name)
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
;   reprocess : in, optional, type=boolean
;     set to remove the mark indicating directory was processed
;   is_available : out, optional, type=boolean
;     set to a named variable to retrieve the state of unlock after this
;     command runs -- if /REPROCESS is set, it will not necessarily be
;     unlocked
;-
pro ucomp_run::unlock, mark_processed=mark_processed, $
                       reprocess=reprocess, $
                       is_available=is_available
  compile_opt strictarr

  self->getProperty, logger_name=logger_name
  basedir = self->config('processing/basedir')
  if (ucomp_state(self.date, basedir=basedir, logger_name=logger_name)) then begin
    is_available = 1B
  endif else begin
    if (keyword_set(reprocess)) then begin
      is_available = ucomp_state(self.date, /reprocess, $
                                 basedir=basedir, $
                                 logger_name=logger_name)
    endif else begin
      is_available = ucomp_state(self.date, /unlock, $
                                 basedir=basedir, $
                                 logger_name=logger_name)
      mg_log, 'unlocked %s', self.date, name=logger_name, /info
      if (keyword_set(mark_processed)) then begin
        is_available = ucomp_state(self.date, /processed, $
                                   basedir=basedir, $
                                   logger_name=logger_name)
        mg_log, 'marked %s as processed', self.date, name=logger_name, /info
      endif
    endelse
  endelse
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
; Start a timer for the given routine.
;
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
          format=mg_format('%-*s %*s %*s %*s', widths)
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


;+
; Report memory usage.
;
; :Params:
;   routine_name : in, required, type=string
;     name of routine to log memory usage form
;-
pro ucomp_run::log_memory, routine_name
  compile_opt strictarr

  mg_log, strjoin(strtrim(memory(/l64), 2), ', '), $
          name=self.memory_logger_name, $
          from=routine_name
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
;   datetime : in, optional, type=string/strarr
;     datetime in the form 'YYYYMMDD' or 'YYYYMMDD.HHMMSS'; defaults to the
;     value of the `DATETIME` property if this keyword is not given; set to a
;     2-element `strarr` to set `CHANGED` if the value of the option changes in
;     the given range
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether `option_name` was found, if
;     `FOUND` is present, errors will not be generated
;   changed : out, optional, type=boolean
;     set to a named variable to retrieve whether the option changed in the
;     date/time range given by `DATETIME` (only useful if `DATETIME` is set to
;     a 2-element array)
;-
function ucomp_run::epoch, option_name, $
                           datetime=datetime, $
                           found=found, $
                           changed=changed
  compile_opt strictarr
  on_error, 2

  return, self.epochs->get(option_name, datetime=datetime, found=found, changed=changed)
end


;+
; Load the bad frames if a bad frames directory was set in the config file and
; if there is a file for the day to be processed.
;-
pro ucomp_run::load_badframes
  compile_opt strictarr

  badframes_dir = self->config('averaging/badframes_dir')
  if (n_elements(badframes_dir) ne 0L && (badframes_dir ne '')) then begin
    basename = string(self.date, format='%s.ucomp.badframes.csv')
    filename = filepath(basename, root=badframes_dir)
    if (file_test(filename, /regular)) then begin
      *self.badframes = ucomp_read_badframes(filename)
    endif
  endif
end


;+
; Get hot pixel information for camera and gain.
;
; :Params:
;   gain_mode : in, required, type=string
;     gain mode, i.e., "high" or "low"
;   camera_index : in, required, type=integer
;     camera 0 (RCAM) or 1 (TCAM)
;
; :Keywords:
;   hot : out, optional, type="lonarr(n)"
;     set to a named variable to retrieve a list of hot pixels
;   adjacent : out, optional, type="lonarr(n, 4)"
;     set to a named variable to retrieve a list of hot pixels
;-
pro ucomp_run::get_hot_pixels, gain_mode, camera_index, $
                               hot=hot, $
                               adjacent=adjacent
  compile_opt strictarr

  if (size(gain_mode, /type) eq 7) then begin
    gain_index = gain_mode eq 'high'
  endif else begin
    gain_index = gain_mode
  endelse

  if (n_elements(*self.hot_pixels[gain_index, camera_index]) eq 0L) then begin
    hot_pixels_option_name = string((['low', 'high'])[gain_index], $
                                    format='%s_hot_pixel_basename')
    hot_pixels_basename = self->epoch(hot_pixels_option_name)
    hot_pixels_filename = filepath(hot_pixels_basename, $
                                   subdir='cameras', $
                                   root=self.resource_root)
    restore, filename=hot_pixels_filename

    *self.hot_pixels[gain_index, 0] = hot_0
    *self.hot_pixels[gain_index, 1] = hot_1
    *self.adjacent_pixels[gain_index, 0] = n_elements(adjacent_0) eq 0L ? !null : adjacent_0
    *self.adjacent_pixels[gain_index, 1] = n_elements(adjacent_1) eq 0L ? !null : adjacent_1
  endif

  hot      = *self.hot_pixels[gain_index, camera_index]
  adjacent = *self.adjacent_pixels[gain_index, camera_index]
end


;+
; Get full demodulation matrix for all wave regions.
;
; :Returns:
;    `fltarr(4, 4, 9, 2)`
;
; :Params:
;   wave_region : in, required, type=string
;     wave region
;
; :Keywords:
;   datetime : in, required, type=string
;     date/time in the format "YYYYMMDD_HHMMSS"
;   info : out, optional, type=structure
;     IDL savefile info structure
;-
function ucomp_run::get_dmatrix_coefficients, wave_region, datetime=datetime, info=info
  compile_opt strictarr

  if (~self.dmatrix_coefficients->hasKey(wave_region)) then begin
    version = self->epoch('demodulation_coeffs_version', datetime=datetime)
    demodulation_coeffs_basename = string(wave_region, version, $
                                          format='ucomp.%s.dmx-temp-coeffs.%d.sav')
    demodulation_coeffs_filename = filepath(demodulation_coeffs_basename, $
                                            subdir='demodulation', $
                                            root=self.resource_root)

    f = idl_savefile(demodulation_coeffs_filename)
    info = f->contents()
    obj_destroy, f

    ; defines dmx_coeffs variable
    restore, filename=demodulation_coeffs_filename
    (self.dmatrix_coefficients)[wave_region] = dmx_coeffs
    *self.demod_info = info
  endif

  info = *self.demod_info
  return, (self.dmatrix_coefficients)[wave_region]
end


;+
; Retrieve the distortion coefficients for the epoch in the given date/time.
;
; :Keywords:
;   datetime : in, required, type=string
;     date/time in the format "YYYYMMDD_HHMMSS"
;   dx0_c : out, optional, type="fltarr(3, 3)"
;     set to a named variable to retrieve the RCAM x distortion coefficients
;   dy0_c : out, optional, type="fltarr(3, 3)"
;     set to a named variable to retrieve the RCAM y distortion coefficients
;   dx1_c : out, optional, type="fltarr(3, 3)"
;     set to a named variable to retrieve the TCAM x distortion coefficients
;   dy1_c : out, optional, type="fltarr(3, 3)"
;     set to a named variable to retrieve the TCAM y distortion coefficients
;-
pro ucomp_run::get_distortion, datetime=datetime, $
                               dx0_c=dx0_c, $
                               dy0_c=dy0_c, $
                               dx1_c=dx1_c, $
                               dy1_c=dy1_c
  compile_opt strictarr

  distortion_basename = self->epoch('distortion_basename', datetime=datetime)
  if (self.distortion_basename eq distortion_basename) then begin
    coeffs = *self.distortion_coefficients
    dx0_c = coeffs.dx0_c
    dy0_c = coeffs.dy0_c
    dx1_c = coeffs.dx1_c
    dy1_c = coeffs.dy1_c
  endif else begin
    distortion_dir = self->config('cameras/distortion_dir')
    ; look in the repo if the distortion_dir option is not found; new
    ; distortion files are too large to place in the repo
    if (n_elements(distortion_dir) eq 0L) then begin
      self->getProperty, resource_root=resource_root
      distortion_dir = filepath('', subdir='distortion', root=resource_root)
    endif

    distortion_filename = filepath(distortion_basename, $
                                   root=distortion_dir)
    restore, filename=distortion_filename
    self.distortion_basename = distortion_basename

    if (n_elements(dx0_c) eq 16L) then begin
      nx = self->epoch('nx', datetime=datetime)
      ny = self->epoch('ny', datetime=datetime)

      x = dindgen(nx, ny) mod nx
      y = transpose(dindgen(ny, nx) mod ny)

      dx0_c = x + ucomp_eval_surf(dx0_c, dindgen(nx), dindgen(ny))
      dy0_c = y + ucomp_eval_surf(dy0_c, dindgen(nx), dindgen(ny))
      dx1_c = x + ucomp_eval_surf(dx1_c, dindgen(nx), dindgen(ny))
      dy1_c = y + ucomp_eval_surf(dy1_c, dindgen(nx), dindgen(ny))
    endif

    *self.distortion_coefficients = {dx0_c: dx0_c, $
                                     dy0_c: dy0_c, $
                                     dx1_c: dx1_c, $
                                     dy1_c: dy1_c}
  endelse
end


;+
; Retrieve the value for a given option name for a given line.
;
; :Returns:
;   any
;
; :Params:
;   wave_region : in, required, type=string
;     wave region name, e.g., '1074'
;   option_name : in, required, type=string
;     name of an epoch option, e.g., 'center_wavelength'
;
; :Keywords:
;   datetime : in, optional, type=string/strarr
;     datetime in the form 'YYYYMMDD' or 'YYYYMMDD.HHMMSS'; defaults to the
;     value of the `DATETIME` property if this keyword is not given; set to a
;     2-element `strarr` to set `CHANGED` if the value of the option changes in
;     the given range
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether `option_name` was found, if
;     `FOUND` is present, errors will not be generated
;   changed : out, optional, type=boolean
;     set to a named variable to retrieve whether the option changed in the
;     date/time range given by `DATETIME` (only useful if `DATETIME` is set to
;     a 2-element array)
;-
function ucomp_run::line, wave_region, option_name, datetime=datetime, $
                          found=found, changed=changed
  compile_opt strictarr

  self->getProperty, logger_name=logger_name

  options = self.lines[wave_region]
  return, options->get(option_name, datetime=datetime, found=found, changed=changed)
end


;+
; Retrieve the names of all the lines.
;
; :Returns:
;   strarr
;-
function ucomp_run::all_lines
  compile_opt strictarr

  return, ['530', '637', '656', '670', '691', '706', '761', '789', '802', $
           '991', '1074', '1079', '1083']
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
    value = ucomp_get_route(routing_file, self.date, 'raw')
  endif

  if (name eq 'processing/basedir' && n_elements(value) eq 0L) then begin
    routing_file = self.options->get('routing_file', section='processing')
    value = ucomp_get_route(routing_file, self.date, 'process')
  endif

  return, value
end


;+
; Query whether a given alert should be send. Alerts are a type of notification
; send *during* the running of the near-realtime pipeline to warn the observers
; about some non-optimal functioning of the instrument.
;
; :Returns:
;   1B if the alert should be send, 0B otherwise
;
; :Params:
;   type : in, required, type=string
;     alert type, e.g., "BAD_FITS_KEYWORD"
;   msg : in, required, type=string/strarr
;     message to be sent in the alert, not including the filename that is
;     causing the alert
;-
function ucomp_run::can_send_alert, type, msg
  compile_opt strictarr

  dt_format = '(C(CYI4.4, CMOI2.2, CDI2.2, ".", CHI2.2, CMI2.2, CSI2.2))'
  alerts_filename = filepath('alerts.log', $
                            subdir=self.date, $
                            root=self->config('processing/basedir'))

  n_alerts = file_test(alerts_filename, /regular) ? file_lines(alerts_filename) : 0L

  if (n_alerts eq 0L) then begin
    openw, lun, alerts_filename, /get_lun
  endif else begin
    openu, lun, alerts_filename, /get_lun
    ; if haven't called this method before, need to check for an alerts.log file
    ; and read it if present
    if (n_elements(self.alerts) lt n_alerts) then begin
      alerts = strarr(n_alerts)
      readf, lun, alerts
      for a = 0L, n_alerts - 1L do begin
        tokens = strsplit(alerts[a], /extract)
        self.alerts->add, {datetime: tokens[0], type: tokens[1], msg_hash: tokens[2]}
      endfor
    endif
  endelse

  ; determine if alert can be sent
  msg_hash = mg_sha1(strjoin(msg))
  foreach a, self.alerts do begin
    if (a.type eq type && a.msg_hash eq msg_hash) then begin
      last_match_datetime = a.datetime
    endif
  endforeach

  if (n_elements(last_match_datetime) eq 0L) then begin
    can_send = 1B
  endif else begin
    alert_timeout = self->config('alerts/' + type)
    case 1B of
      alert_timeout lt 0: can_send = 0B
      alert_timeout eq 0: can_send = 1B
      else: begin
          delta = mg_timeinterval(minutes=alert_timeout)
          last_dt = mg_datetime(last_match_datetime, format='%Y%m%d.%H%M%S')
          now = mg_datetime()
          if (now gt last_time + delta) then begin
            can_send = 1B
          endif else can_send = 0B
          obj_destroy, [now, last_dt, delta]
        end
      endcase
  endelse

  ; if alert can be sent, add alert info to the alerts.log and cache
  if (can_send) then begin
    now = string(systime(/seconds, /julian), format=dt_format)
    printf, lun, now, type, msg_hash, format='(%"%-16s %-30s %s")'
    self.alerts->add, {datetime: now, type: type, msg_hash: msg_hash}
  endif

  free_lun, lun

  return, can_send
end


;+
; Get the names of all the temperature maps.
;
; :Returns:
;   `strarr`
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of temperature maps
;-
function ucomp_run::all_temperature_maps, count=count
  compile_opt strictarr

  return, self.temperature_maps->sections(count=count)
end


;+
; Retrieve an option for a given temperature map.
;
; :Returns:
;   value
;
; :Params:
;   map : in, required, type=string
;     name of temperature map
;   option : in, required, type=string
;     name of option of the given temperature
;-
function ucomp_run::temperature_map_option, map, option
  compile_opt strictarr

  value = self.temperature_maps->get(option, section=map, found=found)
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
                            config_flag=config_flag, $
                            all_wave_regions=all_wave_regions, $
                            resource_root=resource_root, $
                            calibration=calibration, $
                            badframes=badframes, $
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

  if (arg_present(config_flag)) then begin
    config_basename = file_basename(self.config_filename)
    dot_pos = strpos(config_basename, '.')
    config_flag = strmid(config_basename, $
                         dot_pos + 1, $
                         strpos(config_basename, '.', /reverse_search) - dot_pos - 1)
  endif

  if (arg_present(all_wave_regions)) then all_wave_regions = self->all_lines()

  if (arg_present(resource_root)) then resource_root = self.resource_root

  if (arg_present(calibration)) then calibration = self.calibration

  if (arg_present(badframes)) then badframes = *self.badframes

  if (arg_present(t0)) then t0 = self.t0
end


;+
; Set properties.
;-
pro ucomp_run::setProperty, datetime=datetime, $
                            t0=t0
  compile_opt strictarr
  on_error, 2

  if (n_elements(datetime) gt 0L) then begin
    self.epochs->setProperty, datetime=datetime
    foreach wave_region_options, self.lines do begin
      wave_region_options->setProperty, datetime=datetime
    endforeach
  endif
  if (n_elements(t0) gt 0L) then self.t0 = t0
end


;= overload operators

;+
; Returns basic information about the run; used when `PRINT`-ing a run object.
;
; :Returns:
;   string
;-
function ucomp_run::_overloadPrint
  compile_opt strictarr

  return, transpose(['UCoMP run', $
                    '  date: ' + self.date, $
                    '  mode: ' + self.mode])
end


;+
; Retrieve info used when `HELP`-ing on the run object.
;
; :Returns:
;   string
;
; :Params:
;   varname : in, required, type=string
;     variable name of the run used in the `HELP` output
;-
function ucomp_run::_overloadHelp, varname
  compile_opt strictarr

  type = 'UCoMP run'
  specs = string(self.date, format='(%"%s")')
  return, string(varname, type, specs, format='(%"%-15s %-9s = <%s>")')
end


;= initialization


;+
; Use config file values to setup the logger.
;
; :Keywords:
;   reprocess : in, optional, type=boolean
;     set to indicate this is a reprocessing, so rotate the logs
;-
pro ucomp_run::_setup_logger, reprocess=reprocess
  compile_opt strictarr
  on_error, 2

  ; get logging values from config file
  log_dir     = self->config('logging/dir')
  level_name  = self->config('logging/level')
  max_version = self->config('logging/max_version')
  max_width   = self->config('logging/max_width')
  include_pid = self->config('logging/include_pid')

  ; log message formats
  fmt = '%(time)s %(levelshortname)s: %(routine)s: %(message)s'
  if (include_pid) then fmt = '[%(pid)s] ' + fmt
  time_fmt = '(C(CYI4, CMOI2.2, CDI2.2, "." CHI2.2, CMI2.2, CSI2.2))'

  ; setup log directory and file
  basename = string(self.date, self.mode, format='(%"%s.ucomp.%s.log")')
  filename = filepath(basename, root=log_dir)
  if (~file_test(log_dir, /directory)) then begin
    self->getProperty, logger_name=logger_name
    ucomp_mkdir, log_dir, logger_name=logger_name
  endif

  ; rotate logs if reprocessing
  if (keyword_set(reprocess)) then begin
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

  ; configure memory logger
  self.memory_logger_name = 'ucomp/memory'
  memory_basename = string(self.date, format='(%"%s.ucomp.memory.log")')
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(self.date), $
                     root=self->config('engineering/basedir'))
  if (~file_test(eng_dir, /directory)) then begin
    ucomp_mkdir, eng_dir, logger_name=logger_name
  endif
  memory_filename = filepath(memory_basename, root=eng_dir)

  if (keyword_set(reprocess)) then begin
    file_delete, memory_filename, /allow_nonexistent
  endif

  mg_log, name=self.memory_logger_name, logger=memory_logger
  memory_logger->setProperty, format='%(time)s, %(routine)s, %(message)s', $
                              time_format=time_fmt, $
                              filename=memory_filename
end


;= lifecycle methods

;+
; Free resources.
;-
pro ucomp_run::cleanup
  compile_opt strictarr

  foreach options, self.lines do obj_destroy, options
  obj_destroy, [self.options, self.epochs, self.lines, self.temperature_maps, $
                self.program_names]

  ptr_free, self.badframes

  ptr_free, self.hot_pixels[0], $
            self.hot_pixels[1], $
            self.hot_pixels[2], $
            self.hot_pixels[3]
  ptr_free, self.adjacent_pixels[0], $
            self.adjacent_pixels[1], $
            self.adjacent_pixels[2], $
            self.adjacent_pixels[3]

  ptr_free, self.distortion_coefficients
  obj_destroy, self.dmatrix_coefficients
  ptr_free, self.demod_info

  ; performance monitoring API
  obj_destroy, [self.calls, self.times]

  foreach wave_region, self.files do begin
    foreach file, wave_region do obj_destroy, file
    obj_destroy, wave_region
  endforeach
  obj_destroy, self.files

  obj_destroy, self.alerts
end


;+
; Initialize the run.
;
; :Returns:
;   1 for success, 0 otherwise
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
;   reprocess : in, optional, type=boolean
;     set if this is a reprocessing run
;-
function ucomp_run::init, date, mode, config_filename, $
                          no_log=no_log, reprocess=reprocess
  compile_opt strictarr

  self.date = date
  self.mode = mode

  self->getProperty, logger_name=logger_name

  self.resource_root = file_expand_path(filepath('resource', $
                                                 subdir='..', $
                                                 root=mg_src_root()))

  ; setup config options
  config_spec_filename = filepath('ucomp.spec.cfg', $
                                  subdir=['..', 'config'], $
                                  root=mg_src_root())

  self.config_filename = config_filename
  self.options = ucomp_read_config(self.config_filename, spec=config_spec_filename)
  config_valid = self.options->is_valid(error_msg=error_msg)
  if (~config_valid) then begin
    mg_log, 'invalid configuration file', name=logger_name, /critical
    mg_log, '%s', error_msg, name=logger_name, /critical
    return, 0
  endif

  if (~keyword_set(no_log)) then self->_setup_logger, reprocess=reprocess

  ; setup epoch reading
  epochs_filename = filepath('ucomp.epochs.cfg', root=self.resource_root)
  epochs_spec_filename = filepath('ucomp.epochs.spec.cfg', root=self.resource_root)

  self.epochs = mgffepochparser(epochs_filename, epochs_spec_filename)
  epochs_valid = self.epochs->is_valid(error_msg=error_msg)
  if (~epochs_valid) then begin
    mg_log, 'invalid epochs file', name=logger_name, /critical
    mg_log, '%s', error_msg, name=logger_name, /critical
    return, 0
  endif

  ; setup information about each wave region
  self.lines = hash()
  wave_regions = self->all_lines()
  for w = 0L, n_elements(wave_regions) - 1L do begin
    lines_filename = filepath(string(wave_regions[w], $
                                     format='(%"ucomp.%s.cfg")'), $
                              subdir=['wave_regions'], $
                              root=self.resource_root)
    lines_spec_filename = filepath(string(wave_regions[w], $
                                          format='(%"ucomp.%s.spec.cfg")'), $
                                   subdir=['wave_regions'], $
                                   root=self.resource_root)
    wave_region_options = mgffepochparser(lines_filename, lines_spec_filename)
    lines_valid = wave_region_options->is_valid(error_msg=error_msg)
    if (~lines_valid) then begin
      mg_log, 'invalid wave region options file: %s', file_basename(lines_filename), $
              name=logger_name, /critical
      mg_log, '%s', error_msg, name=logger_name, /critical
      return, 0
    endif
    self.lines[wave_regions[w]] = wave_region_options
  endfor

  temperature_maps_filename = filepath('false-color-images.cfg', $
                                       subdir=['temperature'], $
                                       root=self.resource_root)
  self.temperature_maps = mg_read_config(temperature_maps_filename)

  program_names_filename = filepath('program_names.cfg', root=self.resource_root)
  self.program_names = mg_read_config(program_names_filename)

  self.badframes = ptr_new(/allocate_heap)
  self->load_badframes

  for i = 0L, 3L do begin
    self.hot_pixels[i] = ptr_new(/allocate_heap)
    self.adjacent_pixels[i] = ptr_new(/allocate_heap)
  endfor

  self.dmatrix_coefficients    = hash()
  self.demod_info              = ptr_new(/allocate_heap)
  self.distortion_coefficients = ptr_new(/allocate_heap)

  self.files = orderedhash()   ; wave_region (string) -> list of file objects

  ; list of structures of the form:
  ;   {datetime: '', type: '', msg_hash: ''}
  self.alerts = list()

  self.calibration = ucomp_calibration(run=self)

  ; performance monitoring
  self.calls = orderedhash()   ; routine name (string) -> # of calls (long)
  self.times = orderedhash()   ; routine name (string) -> times (float) in seconds

  self->setProperty, datetime=self.date

  return, 1
end


;+
; Define the data in the run class.
;-
pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date                    : '', $
           mode                    : '', $   ; eod, realtime, cal
           t0                      : 0.0D, $

           config_filename         : '', $
           options                 : obj_new(), $

           epochs                  : obj_new(), $
           lines                   : obj_new(), $
           temperature_maps        : obj_new(), $
           program_names           : obj_new(), $

           badframes               : ptr_new(), $

           hot_pixels              : ptrarr(2, 2), $   ; gain, camera
           adjacent_pixels         : ptrarr(2, 2), $   ; gain, camera

           dmatrix_coefficients    : obj_new(), $
           demod_info              : ptr_new(), $

           distortion_basename     : '', $
           distortion_coefficients : ptr_new(), $


           files                   : obj_new(), $

           alerts                  : obj_new(), $

           resource_root           : '', $

           calibration             : obj_new(), $

           ; performance
           calls                   : obj_new(), $
           times                   : obj_new(), $
           memory_logger_name      : ''}
end


; main-level example program

date = '20210726'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)
repair_routine = run->epoch('raw_data_repair_routine')
help, repair_routine
print, repair_routine
obj_destroy, run

end
