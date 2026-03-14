; docformat = 'rst'

;+
; Find all the files in the `ucomp_file` database table in the `process`
; directory.
;-
pro ucomp_check_dawn, run, db
  compile_opt strictarr

  level_dirs = hash('L1', 'level1', 'L2', 'level2', 'L3', 'level3')
  processing_dir = run->config('processing/basedir')
  archive_dir = run->config('results/web_basedir')

  sql_query = 'select file_name, gbu, wave_region, ucomp_level.level, mlso_numfiles.obs_day from ucomp_file join ucomp_level on ucomp_file.level_id=ucomp_level.level_id join mlso_numfiles on ucomp_file.obsday_id=mlso_numfiles.day_id;'
  processed_files = db->query(sql_query, count=n_processed_files)
  n_missing_processed_files = 0L
  n_missing_archive_files = 0L
  openw, lun, 'ucomp.missing.log', /get_lun
  for f = 0L, n_processed_files - 1L do begin
    if (f mod 1000 eq 0) then print, f, n_processed_files, format='%06d/%06d'
    file = processed_files[f]
    date = file.obs_day.replace('-', '')
    level = level_dirs[file.level]
    if (stregex(file.file_name, '.*\.l1\..*\.(mean|median|sigma)\..*', /boolean)) then begin
      level = 'level2'
    endif
    path = filepath(file.file_name, subdir=[date, level], root=processing_dir)
    if (~file_test(path, /regular)) then begin
      print, file.file_name, format='%s not found [processing]'
      printf, lun, file.file_name, format='%s not found [processing]'
      n_missing_processed_files += 1L
    endif
    path = filepath(file.file_name, subdir=ucomp_decompose_date(date), root=archive_dir)
    is_published = file.wave_region eq '1074' $
      || file.wave_region eq '1079' $
      || file.wave_region eq '789' $
      || file.wave_region eq '706' $
      || file.wave_region eq '637'
    if (is_published && (level ne 'level1') && (file.gbu eq 0) && ~file_test(path, /regular)) then begin
      print, file.file_name, level, format='%s not found [%s] [archive]'
      printf, lun, file.file_name, format='%s not found [archive]'
      n_missing_archive_files += 1L
    endif
  endfor
  free_lun, lun

  print, n_missing_processed_files, format='%d missing processed files'
  print, n_missing_archive_files, format='%d missing archive files'


  raw_dir = run->config('raw/basedir')

  sql_query = 'select file_name, mlso_numfiles.obs_day from ucomp_raw join mlso_numfiles on ucomp_raw.obsday_id=mlso_numfiles.day_id;'
  raw_files = db->query(sql_query, count=n_raw_files)
  n_missing_raw_files = 0L
  for f = 0L, n_raw_files - 1L do begin
    if (f mod 1000 eq 0) then print, f, n_raw_files, format='%06d/%06d'

    file = raw_files[f]
    date = file.obs_day.replace('-', '')
    path = filepath(file.file_name, subdir=[date], root=raw_dir)
    if (~file_test(path, /regular)) then begin
      print, file.file_name, format='%s not found'
      n_missing_raw_files += 1L
    endif
  endfor

  print, n_missing_raw_files, format='%d missing raw files'

  obj_destroy, level_dirs
end


; main-level example program

config_basename = 'ucomp.reprocess.cfg'
config_filename = filepath(config_basename, $
    subdir=['..', '..', 'ucomp-config'], $
    root=mg_src_root())

run = ucomp_run('20210715', 'test', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_check_dawn, run, db

obj_destroy, [run, db]

end
