; docformat = 'rst'

;+
; Returns the log messages from the `logfile` that are at the level given or
; more important.
;
; :Returns:
;   `strarr`
;
; :Params:
;   logfile : in, required, type=string
;     filename of log file
;
; :Keywords:
;   level : in, optional, type=integer
;     log level to filter by, 0 (debug), 1 (info), 2 (warn), 3 (error), 4
;     (critical)
;   debug : in, optional, type=boolean
;     return all log messages
;   informational : in, optional, type=boolean
;     return info, warn, error, and critical log messages
;   warning : in, optional, type=boolean
;     return warn, error, and critical log messages
;   error : in, optional, type=boolean
;     return error and critical log messages
;   critical : in, optional, type=boolean
;     return only critical log messages
;   n_messages : out, optional, type=long
;     set to a named variable to retrieve the number of messages returned
;-
function ucomp_log_filter, logfile, $
                           debug=debug, $
                           informational=informational, $
                           warning=warning, $
                           error=error, $
                           critical=critical, $
                           level=level, $
                           n_messages=n_messages
  compile_opt strictarr

  n_messages = 0L
  if (~file_test(logfile)) then return, !null

  case 1 of
    n_elements(level) gt 0L: _level = level
    keyword_set(critical): _level = 4
    keyword_set(error): _level = 3
    keyword_set(warning): _level = 2
    keyword_set(informational): _level = 1
    keyword_set(debug): _level = 0
    else: _level = 0
  endcase

  levels = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL']

  loglevel_re = string(strjoin(levels[_level:*], '|'), format='(%".*(%s):.*")')

  logstart_re = '[[:digit]]+: [[:digit:]]{8}.[[:digit:]]{6}'

  log_msgs = list()

  line = ''
  openr, lun, logfile, /get_lun

  while (~eof(lun)) do begin
    readf, lun, line
    if (stregex(line, loglevel_re, /boolean)) then begin
      log_msgs->add, line
      n_messages += 1
    endif
  endwhile

  free_lun, lun

  log_msg_array = log_msgs->toArray()
  obj_destroy, log_msgs
  return, log_msg_array
end
