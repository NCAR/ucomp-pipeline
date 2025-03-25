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
    if (files[f].good and files[f].wrote_l1) then begin
      published = run->config(files[f].wave_region + '/publish_l1', found=found)
      if (published) then n_good_fits_files += 1L
      mg_log, 'n_good_fits_files: %d', n_good_fits_files, $
              name=run.logger_name, /debug
    endif
  endfor

  sql_cmd = 'update mlso_numfiles set num_ucomp=%d where day_id=%d'
  db->execute, sql_cmd, n_good_fits_files, obsday_index

  mg_log, 'adding %d good FITS files', n_good_fits_files, $
          name=run.logger_name, /info

  done:
end


; main-level example program

date = '20250323'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)
published = run->config('1074' + '/publish_l1', found=found)
help, published, found
obj_destroy, run

end
