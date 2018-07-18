; docformat = 'rst'

;+
; Lock/unlock a raw directory.
;
; :Returns:
;   1 if lock/unlock successful, 0 if not
;
; :Params:
;   date : in, required, type=string
;     day of year to process, in `YYYYMMDD` format
;
; :Keywords:
;   lock : in, optional, type=boolean
;     set to try to obtain a lock on the `date` dir in the raw
;     directory
;   unlock : in, optional, type=boolean
;     set to unlock a `date` dir in the raw directory
;   processed : in, optional, type=boolean
;     set to set a lock indicating the directory has been processed
;   n_concurrent : in, out, optional, type=long
;     incremented if a directory was locked, not available or processed; this
;     should give a number of concurrent production pipeline processes running
;   run : in, required, type=object
;     UCoMP pipeline run object
;
; :Author:
;   MLSO Software Team
;-
function ucomp_state, date, $
                      lock=lock, $
                      unlock=unlock, $
                      processed=processed, $
                      n_concurrent=n_concurrent, $
                      run=run
  compile_opt strictarr, logical_predicate
  on_error, 2

  if (n_elements(n_concurrent) eq 0L) then n_concurrent = 0L

  raw_dir = filepath(date, root=run.raw_basedir)
  lock_file = filepath('.lock', root=raw_dir)
  processed_file = filepath('.processed', root=raw_dir)

  available = ~file_test(lock_file) && ~file_test(processed_file)

  if (keyword_set(lock)) then begin
    if (available) then begin
      n_concurrent += 1L
      openw, lun, lock_file, /get_lun
      free_lun, lun
    endif
    return, available
  endif

  if (keyword_set(unlock)) then begin
    locked = file_test(lock_file)
    if (locked) then begin
      n_concurrent -= 1L
      file_delete, lock_file
    endif
    return, locked
  endif

  if (keyword_set(processed)) then begin
    openw, lun, processed_file, /get_lun
    free_lun, lun
    return, 1B
  endif

  ; this was just a test call, increment if lock_file was present
  if (file_test(lock_file)) then n_concurrent += 1L

  return, available
end
