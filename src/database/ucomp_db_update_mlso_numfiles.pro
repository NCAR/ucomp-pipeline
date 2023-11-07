; docformat = 'rst'

;+
; Update the num_ucomp field of the mlso_numfiles database table with the
; number of good level 1 files, of all wave regions.
;
; :Params:
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   db : in, required, type=object
;     `UCOMPdbMySQL` database object
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_db_update_mlso_numfiles, obsday_index, db, run=run
  compile_opt strictarr

  files = run->get_files(data_type='sci', count=n_total_fits_files)
  mg_log, 'checking %d total FITS files', n_total_fits_files, $
          name=run.logger_name, /info

  n_good_fits_files = 0L
  for f = 0L, n_total_fits_files - 1L do begin
    if (files[f].good) then n_good_fits_files += 1L
  endfor

  sql_cmd = 'update mlso_numfiles set num_ucomp=%d where day_id=%d'
  db->execute, sql_cmd, n_good_fits_files, obsday_index

  mg_log, 'adding %d good FITS files', n_good_fits_files, $
          name=run.logger_name, /info

  done:
end
