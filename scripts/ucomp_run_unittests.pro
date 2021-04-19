; docformat = 'rst'

;+
; Run the unit tests.
;
; :Params:
;   filename : in, optional, type=string
;     if present, output is sent to `filename`, otherwise sent to `stdout`
;
; :Keywords:
;   tests : in, optional, type=string/strarr, default='mglib_uts'
;     tests to run, defaults to all of them
;-
pro ucomp_run_unittests, filename, tests=tests
  compile_opt strictarr

  _tests = n_elements(tests) gt 0L ? test : 'ucomp_uts'

  mgunit, _tests, filename=filename, html=n_elements(filename) gt 0L, $
          ntest=ntest, npass=npass, nfail=nfail, nskip=nskip, $
          total_nlines=total_nlines, $
          covered_nlines=covered_nlines

  coverage_precentage = 100.0 * covered_nlines / total_nlines
  if (n_elements(filename) gt 0L) then begin
    print, ntest, npass, nfail, nskip, coverage_precentage, $
           format='(%"%d tests: %d passed, %d failed, %d skipped (%0.1f%%)")'
    print, filename, format='(%"Full results in %s")'
  endif
end
