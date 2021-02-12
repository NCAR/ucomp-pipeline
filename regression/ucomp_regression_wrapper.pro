;+
; Run the UCoMP pipeline; this is full processing (or reprocessing) for a day
; not the quicklook/realtime processing and test against previous results.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_regression_wrapper, date, config_filename
  compile_opt strictarr

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

  run = ucomp_run(date, mode, config_fullpath)
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
      mg_log, '%d extra file%s in results', $
              n_extra_in_results, n_extra_in_results gt 1L ? 's' : '', $
              name=run.logger_name, /warn
    endif
    for f = 0L, n_extra_in_results - 1L do begin
      mg_log, '%s in results, but not standards', $
              results[extra_in_results[f]], name=run.logger_name, /warn
    endfor
  endif

  if (n_standards gt 0L) then begin
    missing_in_results = mg_complement(standard_matches, n_standards, $
                                       count=n_missing_in_results)
    if (n_missing_in_results gt 0L) then begin
      mg_log, '%d missing file%s in results', $
              n_missing_in_results, n_missing_in_results gt 1L ? 's' : '', $
              name=run.logger_name, /warn
    endif
    for f = 0L, n_missing_in_results - 1L do begin
      mg_log, '%s in standards, but not in results', $
              standards[missing_in_results[f]], name=run.logger_name, /warn
    endfor
  endif

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
      mg_log, 'result %s is a directory, but standard is not', $
              results[result_matches[m]], $
              name=run.logger_name, /warn
    endif
    if (~result_is_dir && standard_is_dir) then begin
      mg_log, 'result %s is a directory, but standard is not', $
              results[result_matches[m]], $
              name=run.logger_name, /warn
    endif

    if (stregex(results[result_matches[m]], '.*\.fts(\.gz)?', /boolean)) then begin
      ucomp_compare_fits, result_path, standard_path, run.logger_name
    endif else begin
      ucomp_compare_text, result_path, standard_path, run.logger_name
    endelse
  endfor

  ; cleanup and quit
  done:

  mg_log, 'done', name=run.logger_name, /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit
end
