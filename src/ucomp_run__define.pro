; docformat = 'rst'


;= API

;+
; Create an inventory of the raw files for a run.
;-
pro ucomp_run::make_raw_inventory
  compile_opt strictarr

  raw_dir = filepath(self.date, root=run->config('raw_basedir'))
  raw_files = file_search(filepath('*.FTS', root=raw_dir), count=n_raw_files)

  for f = 0L, n_raw_files - 1L do begin
    file = kcor_file(raw_files[f])

    if ((self.files)->hasKey(file.wave_type)) then begin
      (self.files)[file.wave_type] = list()
    endif

    (self.files)[file.wave_type]->add, file
  endfor
end


;+
; Lock the raw directory if required and available.
;
; :Keywords:
;   is_available : out, optional, type=boolean
;     set to a named variable to retrieve whether the raw directory was
;     available, and therefor locked
;-
pro ucomp_run::lock, is_available=is_available
  compile_opt strictarr

  if (self->config('raw/lock')) then begin
    is_available = ucomp_state(self.date, run=run)
    if (is_available) then begin
      !null = ucomp_state(self.date, /lock, run=run)
      mg_log, 'locked %s', self.date, name='ucomp', /info
    endif else begin
      mg_log, '%s not available, skipping', self.date, name='ucomp', /info
    endelse
  endif
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

  if (run->config('raw/lock')) then begin
    if (~ucomp_state(self.date)) then begin
      unlocked = ucomp_state(self.date, /unlock, run=run)
      mg_log, 'unlocked %s', self.date, name='ucomp', /info
      if (error eq 0) then begin
        processed = ucomp_state(self.date, /processed, run=run)
        mg_log, 'marked %s as processed', self.date, name='ucomp', /info
      endif
    endif
  endif
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

  return, value
end


;= property access

;+
; Get properties.
;-
pro ucomp_run::getProperty, date=date, $
                            files=files, wave_type=wave_type, count=count, $
                            t0=t0
  compile_opt strictarr
  on_error, 2

  if (arg_present(date)) then date = self.date

  if (arg_present(files) || arg_present(count)) then begin
    if (n_elements(wave_type) eq 0L) then message, 'WAVE_TYPE not given for FILES'
    files = (self.files)[wave_type]
    count = n_elements(files)
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

  if (n_elements(date) gt 0L) then self.epochs->setProperty, datetime=datetime
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
  dir = self->config('logging/dir')
  level_name = self->config('logging/level')
  level_code = self->_log_level_code(level_name)
  max_version = self->config('logging/max_version')
  max_width = self->config('logging/max_width')

  ; setup log directory and file
  basename = string(self.date, format='(%"%s.ucomp.log")')
  filename = filepath(basename, root=dir)
  if (~file_test(dir, /directory)) then file_mkdir, dir

  ; rotate logs
  mg_rotate_log, filename, max_version=max_version

  ; configure logger
  mg_log, name='ucomp', logger=logger
  logger->setProperty, format=fmt, $
                       time_format=time_fmt, $
                       max_width=max_width, $
                       level=level_code, $
                       filename=filename
end


;= lifecycle methods

;+
; Free resources.
;-
pro ucomp_run::cleanup
  compile_opt strictarr

  obj_destroy, [self.options, self.epochs]

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
  epochs_filename = filepath('epochs.cfg', $
                             root=mg_src_root())
  epochs_spec_filename = filepath('epochs_spec.cfg', $
                                  subdir=['..', 'resource'], $
                                  root=mg_src_root())

  self.epochs = mgffepochparser(epochs_filename, epochs_spec_filename)
  epochs_valid = self.epochs->is_valid(error_msg=error_msg)
  if (~epochs_valid) then begin
    mg_log, 'invalid epochs file', name='ucomp', /critical
    mg_log, '%s', error_msg, name='ucomp', /critical
    return, 0
  endif

  ; hash of wave_type -> list of file objects
  self.files = hash()

  return, 1
end


;+
; Define the data in the run class.
;-
pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date: '', $
           t0: 0.0D, $
           options: obj_new(), $
           epochs: obj_new(), $
           files: obj_new()}
end
