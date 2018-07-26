; docformat = 'rst'


function ucomp_verify_dates_expandrange, start_date, end_date, count=n_days
  compile_opt strictarr

  start_parts = ucomp_decompose_date(start_date)
  start_jd = julday(start_parts[1], start_parts[2], start_parts[0], 0, 0, 0.0D)
  end_parts = ucomp_decompose_date(end_date)
  end_jd = julday(end_parts[1], end_parts[2], end_parts[0], 0, 0, 0.0D)

  n_days = long(end_jd - start_jd) + 1L
  days = strarr(n_days)

  for d = 0L, n_days - 1L do begin
    caldat, start_jd + d, month, day, year
    days[d] = string(year, month, day, format='(%"%04d%02d%02d")')
  endfor

  return, days
end


pro ucomp_verify_dates, date_expression, config_filename=config_filename
  compile_opt strictarr
  on_error, 2

  mg_log, name='ucomp/verify', logger=logger
  logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'

  ranges = strsplit(date_expression, ',', /extract, count=n_ranges)

  failed_days = list()

  divider = string(bytarr(35) + (byte('-'))[0])

  for r = 0L, n_ranges - 1L do begin
    endpts = strsplit(ranges[r], '-', /extract, count=n_endpts)
    case n_endpts of
      0: ; missing range expression, just skip
      1: begin
          ucomp_verify, endpts[0], config_filename, status=status
          if (status ne 0L) then failed_days->add, endpts[0]
          mg_log, name='ucomp/verify', logger=logger
          logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'
          mg_log, divider, name='ucomp/verify', /info
        end
      2: begin
          dates = ucomp_verify_dates_expandrange(endpts[0], endpts[1], $
                                                 count=n_dates)
          for d = 0L, n_dates - 1L do begin
            ucomp_verify, dates[d], config_filename=config_filename, status=status
            if (status ne 0L) then failed_days->add, dates[d]

            mg_log, name='ucomp/verify', logger=logger
            logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'
            mg_log, divider, name='ucomp/verify', /info 
         endfor
        end
      else: message, 'invalid date expression syntax'
    endcase
  endfor

  n_failed_days = failed_days->count()
  mg_log, name='ucomp/verify', logger=logger
  logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'
  if (n_failed_days gt 0L) then begin
    mg_log, 'failed days: %s', strjoin(failed_days->toArray(), ', '), $
            name='ucomp/verify', /info
  endif else begin
    mg_log, 'no failed days', name='ucomp/verify', /info
  endelse

  obj_destroy, failed_days
  mg_log, /quit
  exit, status=n_failed_days
end
