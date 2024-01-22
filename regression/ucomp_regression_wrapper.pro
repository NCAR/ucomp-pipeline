; docformat = 'rst'

;+
; Run the UCoMP pipeline; this is full processing (or reprocessing) for a day
; not the quicklook/realtime processing and test against previous results.
;
; Exits with a status to indicate whether the regression test passed (status 0)
; or failed (status non-zero). A non-zero status is a bitmask with 1 for extra
; file in results, 2 for missing file in results, and 4 for a difference in a
; file in the results.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_regression_wrapper, date, config_filename
  compile_opt strictarr

  status = 0L

  ; error handler
  catch, error
  if (error ne 0) then begin
    catch, /cancel
    mg_log, /last_error, name=logger_name, /critical
    goto, done
  endif

  ; run the end-of-day pipeline
  ucomp_reprocess_wrapper, date, config_filename

  ; setup for regression testing
  mode = 'regress'
  logger_name = string(mode, format='(%"ucomp/%s")')

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, 'config file %s not found', config_fullpath, $
            name=logger_name, /critical
    goto, done
  endif

  run = ucomp_run(date, mode, config_fullpath, /reprocess)
  if (~obj_valid(run)) then begin
    mg_log, 'cannot create run object', name=logger_name, /critical
    goto, done
  endif

  mg_log, 'starting regression comparisons for %d...', date, name=run.logger_name, /info

  results_dir = filepath(date, root=run->config('processing/basedir'))
  results = file_search(results_dir, '*', count=n_results)
  results = strmid(results, strlen(results_dir) + 1L)

  standards_dir = filepath(date, root=run->config('regression/standards_basedir'))
  standards = file_search(standards_dir, '*', count=n_standards)
  standards = strmid(standards, strlen(standards_dir) + 1L)

  n_matches = mg_match(results, standards, $
                       a_matches=result_matches, b_matches=standard_matches)

  if (n_results gt 0L) then begin
    extra_in_results = mg_complement(result_matches, n_results, $
                                     count=n_extra_in_results)
    if (n_extra_in_results gt 0L) then begin
      status or= 1L
      mg_log, '%d extra file%s in results', $
              n_extra_in_results, n_extra_in_results gt 1L ? 's' : '', $
              name=run.logger_name, /warn
    endif
    for f = 0L, n_extra_in_results - 1L do begin
      mg_log, '%s in results, but not standards', $
              results[extra_in_results[f]], name=run.logger_name, /warn
    endfor
  endif

  mg_log, 'after checking results, status %d', status, name=run.logger_name, /info

  if (n_standards gt 0L) then begin
    missing_in_results = mg_complement(standard_matches, n_standards, $
                                       count=n_missing_in_results)
    if (n_missing_in_results gt 0L) then begin
      status or= 2L
      mg_log, '%d missing file%s in results', $
              n_missing_in_results, n_missing_in_results gt 1L ? 's' : '', $
              name=run.logger_name, /warn
    endif
    for f = 0L, n_missing_in_results - 1L do begin
      mg_log, '%s in standards, but not in results', $
              standards[missing_in_results[f]], name=run.logger_name, /warn
    endfor
  endif

  mg_log, 'after checking standards, status %d', status, name=run.logger_name, /info

  ; compare matches
  for m = 0L, n_elements(result_matches) - 1L do begin
    result_path = filepath(results[result_matches[m]], root=results_dir)
    standard_path = filepath(standards[standard_matches[m]], root=standards_dir)
    mg_log, 'comparing %s...', results[result_matches[m]], $
            name=run.logger_name, /info

    result_is_dir = file_test(result_path, /directory)
    standard_is_dir = file_test(standard_path, /directory)
    if (result_is_dir && standard_is_dir) then continue
    if (result_is_dir && ~standard_is_dir) then begin
      status or= 4L
      mg_log, 'result %s is a directory, but standard is not', $
              results[result_matches[m]], $
              name=run.logger_name, /warn
    endif
    if (~result_is_dir && standard_is_dir) then begin
      status or= 4L
      mg_log, 'result %s is a directory, but standard is not', $
              results[result_matches[m]], $
              name=run.logger_name, /warn
    endif

    case 1 of
      stregex(results[result_matches[m]], '.*\.fts(\.gz)?', /boolean): begin
          ucomp_compare_fits, result_path, standard_path, run.logger_name, status=compare_status
          if (compare_status ne 0L) then begin
            mg_log, 'FITS file %s does not match standard', $
                    file_basename(result_path), $
                    name=run.logger_name, /warn
            status or= 4L
          end
        end
      stregex(results[result_matches[m]], '.*(\.txt|\.log|\.cfg|\.olog|\.tarlist)', /boolean): begin
          ucomp_compare_text, result_path, standard_path, run.logger_name, status=compare_status
          if (compare_status ne 0L) then begin
            mg_log, 'text file %s does not match standard', $
                    file_basename(result_path), $
                    name=run.logger_name, /warn
            status or= 4L
          endif
        end
      stregex(results[result_matches[m]], '.*(\.tar\.gz|\.tgz|\.zip)', /boolean): begin
          mg_log, 'not checking tarball %s', $
                  file_basename(result_path), $
                  name=run.logger_name, /info
        end
      else: begin
          ucomp_compare_binary, result_path, standard_path, run.logger_name, status=compare_status
          if (compare_status ne 0L) then begin
            mg_log, 'binary file %s does not match standard', $
                    file_basename(result_path), $
                    name=run.logger_name, /warn
            status or= 4L
          endif
        end
    endcase
  endfor

  mg_log, 'exiting with status %d', status, name=run.logger_name, /info

  ; cleanup and quit
  done:

  mg_log, 'done', name=run.logger_name, /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  exit, /no_confirm, status=status
end


; main-level example

date = '20210725'
config_filename = filepath('ucomp.regression.cfg', $
                           subdir=['..', 'config'], $
                           root=mg_src_root())
ucomp_regression_wrapper, date, config_filename

end
