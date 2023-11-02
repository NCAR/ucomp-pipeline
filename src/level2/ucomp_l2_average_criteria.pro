; docformat = 'rst'

;+
; Create a subset of all the files in a program to average based on the
; averaging criteria. The current criteria:
;
;   - find gaps larger than `MAX_GAP`
;   - return files before the first gap
;
; :Returns:
;   array of UCoMP file objects
;
; :Params:
;   program_files : in, required, type=objarr
;     UCoMP files in the program that could potentially be averaged
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of files returned
;   max_gap : in, required, type=float
;     maximum gap allowed between files [secs]
;-
function ucomp_l2_average_criteria, program_files, count=count, max_gap=max_gap
  compile_opt strictarr

  n_files = n_elements(program_files)

  ; don't do anything if there is only a single file
  if (n_files lt 2L) then begin
    count = n_files
    return, program_files
  endif

  ; find times of the files
  times = fltarr(n_files)
  for f = 0L, n_files - 1L do times[f] = program_files[f].obsday_hours

  ; convert from hours to seconds
  times *= 60.0 * 60.0

  ; find gaps
  gaps = times[1:*] - times[0:-2]
  gap_indices = where(gaps gt max_gap, n_gaps)

  ; use first cluster of files
  count = n_gaps eq 0L ? n_files : gap_indices[0] + 1L
  return, program_files[0:count - 1L]
end
