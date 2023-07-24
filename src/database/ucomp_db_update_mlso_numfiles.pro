; docformat = 'rst'

;+
; Update the num_ucomp field of the mlso_numfiles database table.
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

  sql_cmd = 'update mlso_numfiles set num_ucomp=%d where day_id=%d'
  db->execute, sql_cmd, n_total_fits_files, obsday_index

  done:
end
