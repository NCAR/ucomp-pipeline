; docformat = 'rst'


;= epoch values

function ucomp_run::epoch, name
  compile_opt strictarr

  ; TODO: implement
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

pro ucomp_run::getProperty, date=date
  compile_opt strictarr

  if (arg_present(date)) then date = self.date
end


;= initialization

;+
; Convert a log level name to a log level code.
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


pro ucomp_run::setup_logger
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

pro ucomp_run::cleanup
  compile_opt strictarr

  obj_destroy, [self.options, self.epochs]
end


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

  ; setup logger
  self->setup_logger

  ; setup epoch reading
  epochs_filename = filepath('epochs.cfg', $
                             root=mg_src_root())
  epochs_spec_filename = filepath('epochs_spec.cfg', $
                                  subdir=['..', 'resource'], $
                                  root=mg_src_root())

  self.epochs = mgffepochparser(epochs_filename, epochs_spec_filename)

  return, 1
end


pro ucomp_run__define
  compile_opt strictarr

  !null = {ucomp_run, inherits IDL_Object, $
           date: '', $
           options: obj_new(), $
           epochs: obj_new()}
end
