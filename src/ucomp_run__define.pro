; docformat = 'rst'


;= API

;+
; Create an inventory of the raw files for a run.
;-
pro ucomp_run::make_raw_inventory
  compile_opt strictarr

  raw_dir = filepath(self.date, root=self->config('raw/basedir'))
  raw_files = file_search(filepath('*.FTS', root=raw_dir), count=n_raw_files)

  mg_log, '%d raw files', n_raw_files, name='ucomp', /info
  for f = 0L, n_raw_files - 1L do begin
    file = ucomp_file(raw_files[f])

    if (~(self.files)->hasKey(file.wave_type)) then begin
      (self.files)[file.wave_type] = list()
    endif

    mg_log, '%s [%s] %s', $
            file_basename(raw_files[f]), file.wave_type, file.data_type, $
            name='ucomp', /debug
    (self.files)[file.wave_type]->add, file
  endfor
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

  is_available = ucomp_state(self.date, run=self)
  if (is_available) then begin
    !null = ucomp_state(self.date, /lock, run=self)
    mg_log, 'locked %s', self.date, name='ucomp', /info
  endif else begin
    mg_log, '%s not available, skipping', self.date, name='ucomp', /info
  endelse
end


;+
; Unlock raw directory and, if `error` is 0, mark as processed.
;
; :Params:
;   error : in, required, type=int
;     error code, 0 for no error
;-
pro ucomp_run::unlock, error
  compile_opt strictarr

  if (~ucomp_state(self.date, run=self)) then begin
    unlocked = ucomp_state(self.date, /unlock, run=self)
    mg_log, 'unlocked %s', self.date, name='ucomp', /info
    if (error eq 0) then begin
      processed = ucomp_state(self.date, /processed, run=self)
      mg_log, 'marked %s as processed', self.date, name='ucomp', /info
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

  basename = string(self.date, format='(%"%s.ucomp.profiler.csv")')
  filename = filepath(basename, $
                      subdir=ucomp_decompose_date(self.date), $
                      root=self->config('engineering/basedir'))
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

  basename = string(self.date, format='(%"%s.ucomp.perf.txt")')
  filename = filepath(basename, $
                      subdir=ucomp_decompose_date(self.date), $
                      root=self->config('engineering/basedir'))

  openw, lun, filename, /get_lun

  widths = [35, 32, 10, 10]
  printf, lun, 'routine name', 'total time', '# calls', 'secs/call', $
          format=mg_format('%*s %*s %*s %*s', widths)
  printf, lun, mg_repstr('-', widths), format='(%"%s %s %s %s")'
  foreach n_calls, self.calls, routine_name do begin
    time = (self.times)[routine_name]
    printf, lun, routine_name, ucomp_sec2str(time), n_calls, time / n_calls, $
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

  return, self.epochs->get(option_name, datetime=datetime)
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

  value = self.options->get(tokens[1], section=tokens[0])

  if (name eq 'raw/basedir' && value eq '') then begin
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
                            config_contents=config_contents, $
                            files=files, wave_type=wave_type, count=count, $
                            t0=t0
  compile_opt strictarr
  on_error, 2

  if (arg_present(date)) then date = self.date
  if (arg_present(config_contents)) then begin
    config_contents = reform(self.options->_toString(/substitute))
  endif

  if (arg_present(files) || arg_present(count)) then begin
    if (n_elements(wave_type) eq 0L) then message, 'WAVE_TYPE not given for FILES'
    if ((self.files)->hasKey(wave_type)) then begin
      files = (self.files)[wave_type]
      count = n_elements(files)
    endif else begin
      files = !null
      count = 0L
    endelse
  endif
  if (arg_present(t0)) then t0 = self.t0
end


;+
; Set properties.
;-
pro ucomp_run::setProperty, datetime=datetime, $
                            files=files, wave_type=wave_type, $
                            t0=t0
  compile_opt strictarr
  on_error, 2

  if (n_elements(datetime) gt 0L) then self.epochs->setProperty, datetime=datetime
  if (n_elements(files) gt 0L) then begin
    if (n_elements(wave_type) eq 0L) then message, 'WAVE_TYPE not given for FILES'
    (self.files)[wave_type] = files
  endif
  if (n_elements(t0) gt 0L) then self.t0 = t0
end


;= initialization

;+
; Convert a log level name to a log level code.
;
; :Returns:
;   integer log level code
;
; :Params:
;   name : in, required, type=string
;     case-insensitive name of log level, i.e., 'debug', 'info', etc.
;-
function ucomp_run::_log_level_code, name
  compile_opt strictarr

  switch strlowcase(name) of
    'debug': begin
        code = 5
        break
      end
    'info':
    'informational': begin
        code = 4
        break
      end
    'warn':
    'warning': begin
        code = 3
        break
      end
    'error': begin
        code = 2
        break
      end
    'critical': begin
        code = 1
        break
      end
    else: code = 5
  endswitch

  return, code
end


;+
; Rotate logs and use config file values to setup the logger.
;-
pro ucomp_run::_setup_logger
  compile_opt strictarr

  ; log message formats
  fmt = '%(time)s %(levelshortname)s: %(routine)s: %(message)s'
  time_fmt = '(C(CYI4, "-", CMOI2.2, "-", CDI2.2, " " CHI2.2, ":", CMI2.2, ":", CSI2.2))'

  ; get logging values from config file
  log_dir = self->config('logging/dir')
  level_name = self->config('logging/level')
  level_code = self->_log_level_code(level_name)
  max_version = self->config('logging/max_version')
  max_width = self->config('logging/max_width')

  ; setup log directory and file
  basename = string(self.date, format='(%"%s.ucomp.log")')
  filename = filepath(basename, root=log_dir)
  if (~file_test(log_dir, /directory)) then file_mkdir, log_dir

  ; rotate logs
  mg_rotate_log, filename, max_version=max_version

  ; configure logger
  mg_log, name='ucomp', logger=logger
  logger->setProperty, format=fmt, $
                       time_format=time_fmt, $
                       max_width=max_width, $
                       level=level_code, $
                       filename=filename

  ; setup performance log
  basename = string(self.date, format='(%"%s.ucomp.perf.txt")')
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(self.date), $
                     root=self->config('engineering/basedir'))
  filename = filepath(basename, root=eng_dir)
  if (~file_test(eng_dir, /directory)) then file_mkdir, eng_dir

  mg_rotate_log, filename, max_version=max_version
end


;= lifecycle methods

;+
; Free resources.
;-
pro ucomp_run::cleanup
  compile_opt strictarr

  obj_destroy, [self.options, self.epochs]

  ; performance monitoring API
  obj_destroy, [self.calls, self.times]

  foreach wave_type, self.files do begin
    foreach file, wave_type do obj_destroy, file
    obj_destroy, wave_type
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
;   config_filename : in, required, type=string
;     filename of config file specifying the run
;-
function ucomp_run::init, date, config_filename
  compile_opt strictarr

  self.date = date

  ; setup config options
  config_spec_filename = filepath('ucomp.spec.cfg', $
                                  subdir=['..', 'config'], $
                                  root=mg_src_root())

  self.options = mg_read_config(config_filename, spec=config_spec_filename)
  config_valid = self.options->is_valid(error_msg=error_msg)
  if (~config_valid) then begin
    mg_log, 'invalid configuration file', name='ucomp', /critical
    mg_log, '%s', error_msg, name='ucomp', /critical
    return, 0
  endif

  self->_setup_logger

  ; setup epoch reading
  epochs_filename = filepath('epochs.cfg', root=mg_src_root())
  epochs_spec_filename = filepath('epochs.spec.cfg', root=mg_src_root())

  self.epochs = mgffepochparser(epochs_filename, epochs_spec_filename)
  epochs_valid = self.epochs->is_valid(error_msg=error_msg)
  if (~epochs_valid) then begin
    mg_log, 'invalid epochs file', name='ucomp', /critical
    mg_log, '%s', error_msg, name='ucomp', /critical
    return, 0
  endif

  self.files = hash()   ; wave_type (string) -> list of file objects

  ; performance monitoring
  self.calls = orderedhash()   ; routine name (string) -> # of calls (long)
  self.times = hash()   ; routine name (string) -> times (float) in seconds

  return, 1
end


;+
; Define the data in the run class.
;-
pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date:    '', $
           t0:      0.0D, $
           options: obj_new(), $
           epochs:  obj_new(), $
           files:   obj_new(), $

           ; performance
           calls:   obj_new(), $
           times:   obj_new()}
end
