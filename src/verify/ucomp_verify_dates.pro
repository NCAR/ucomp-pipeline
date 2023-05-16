; docformat = 'rst'


;+
; Print the contents of the given log file to stdout.
;
; :Params:
;   log_filename : in, required, type=string
;     log filename to print
;-
pro ucomp_verify_dates_display_log, log_filename
  compile_opt strictarr

  n_lines = file_lines(log_filename)
  if (n_lines eq 0L) then return

  openr, lun, log_filename, /get_lun
  log_lines = strarr(n_lines)
  readf, lun, log_lines
  free_lun, lun

  for i = 0L, n_lines - 1L do print, log_lines[i]
end


;+
; Expand a date range into an array of dates where the the start date is
; inclusive and the end date is exclusive, i.e., 20200101-20200107 expands to
; 20200101, 20200102, 20200103, 20200104, 20200105, and 20200106.
;
; :Returns:
;   `strarr(n_days)`
;
; :Params:
;   start_date : in, required, type=string
;     start date
;   end_date : in, required, type=string
;     end of the range, not included in the range
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of days returned
;-
function ucomp_verify_dates_expandrange, start_date, end_date, count=n_days
  compile_opt strictarr

  start_parts = ucomp_decompose_date(start_date)
  start_jd = julday(start_parts[1], start_parts[2], start_parts[0], 0, 0, 0.0D)
  end_parts = ucomp_decompose_date(end_date)
  end_jd = julday(end_parts[1], end_parts[2], end_parts[0], 0, 0, 0.0D)

  n_days = long(end_jd - start_jd)
  days = strarr(n_days)

  for d = 0L, n_days - 1L do begin
    caldat, start_jd + d, month, day, year
    days[d] = string(year, month, day, format='(%"%04d%02d%02d")')
  endfor

  return, days
end


;+
; Verify a date or date expression.
;
; :Params:
;   date_expression : in, required, type=string
;     string representing a date, a date range with two dates separated by a
;     hyphen, or list of date expressions separated by commas
;   config_filename : in, required, type=string
;     full path to a configuration file
;-
pro ucomp_verify_dates, date_expression, config_filename
  compile_opt strictarr
  on_error, 2

  console_logger = 'ucomp/console'
  ranges = strsplit(date_expression, ',', /extract, count=n_ranges)
  mg_log, name=console_logger, logger=logger
  time_fmt = '(C(CYI4, CMOI2.2, CDI2.2, "." CHI2.2, CMI2.2, CSI2.2))'
  logger->setProperty, time_format=time_fmt

  failed_days = list()

  divider = string(bytarr(35) + (byte('-'))[0])

  for r = 0L, n_ranges - 1L do begin
    endpts = strsplit(ranges[r], '-', /extract, count=n_endpts)
    case n_endpts of
      0: ; missing range expression, just skip
      1: begin
          ucomp_verify, endpts[0], config_filename, $
                        status=status, $
                        log_filename=log_filename
          if (status ne 0L) then failed_days->add, endpts[0]
          ucomp_verify_dates_display_log, log_filename
          mg_log, divider, name=console_logger, /info
        end
      2: begin
          dates = ucomp_verify_dates_expandrange(endpts[0], endpts[1], $
                                                 count=n_dates)
          for d = 0L, n_dates - 1L do begin
            ucomp_verify, dates[d], config_filename, $
                          status=status, $
                          log_filename=log_filename
            if (status ne 0L) then failed_days->add, dates[d]
            ucomp_verify_dates_display_log, log_filename
            mg_log, divider, name=console_logger, /info
         endfor
        end
      else: message, 'invalid date expression syntax'
    endcase
  endfor

  n_failed_days = failed_days->count()

  if (n_failed_days gt 0L) then begin
    mg_log, 'failed days: %s', strjoin(failed_days->toArray(), ', '), $
            name=console_logger, /info
  endif else begin
    mg_log, 'no failed days', name=console_logger, /info
  endelse

  obj_destroy, failed_days
  mg_log, /quit
  exit, status=n_failed_days
end
