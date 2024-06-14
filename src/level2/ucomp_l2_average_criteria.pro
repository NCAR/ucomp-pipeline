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
;   program_name : in, required, type=string
;     program name, different programs might have differing averaging criteria
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of files returned
;   max_length : in, required, type=float
;     maximum length of time between first and last file [secs]
;-
function ucomp_l2_average_criteria, program_files, $
                                    program_name, $
                                    count=count, $
                                    max_length=max_length
  compile_opt strictarr

  n_files = n_elements(program_files)

  ; don't do anything if there is only a single file
  if (n_files lt 2L) then begin
    count = n_files
    return, program_files
  endif

  ; waves uses entire program right now
  if (program_name eq 'waves') then begin
    return, program_files
  endif

  ; find times of the files
  times = fltarr(n_files)
  for f = 0L, n_files - 1L do times[f] = program_files[f].obsday_hours

  ; convert from hours to seconds
  times *= 60.0 * 60.0

  lengths = times - times[0]
  average_indices = where(lengths le max_length, count, /null)

  return, program_files[average_indices]
end
