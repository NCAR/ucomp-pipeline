; docformat = 'rst'

;+
; Insert an array of mean/median and quick invert files into the ucomp_file
; database table.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, e.g., '1074'
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   sw_index : in, required, type=integer
;     index into the ucomp_sw database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_db_l2_average_insert, wave_region, obsday_index, sw_index, db, run=run
  compile_opt strictarr

  ; get index for level 1 data files
  q = 'select * from ucomp_level where level=''%s'''
  level_results = db->query(q, 'L2', status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id

  ; get index for FITS files
  q = 'select * from mlso_filetype where filetype=''fits'''
  filetype_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  filetype_index = filetype_results.filetype_id

  fields = [{name: 'file_name', type: '''%s'''}, $
            {name: 'date_obs', type: '''%s'''}, $
            {name: 'obsday_id', type: '%d'}, $
            {name: 'carrington_rotation', type: '%d'}, $

            {name: 'level_id', type: '%d'}, $
            {name: 'producttype_id', type: '%d'}, $
            {name: 'filetype_id', type: '%d'}, $

            {name: 'obs_plan', type: '''%s'''}, $
            {name: 'obs_id', type: '''%s'''}, $

            {name: 'quality', type: '%d'}, $
            {name: 'median_background', type: '%s'}, $
            {name: 'vcrosstalk_metric', type: '%s'}, $
            {name: 'wind_speed', type: '%s'}, $
            {name: 'wind_direction', type: '%s'}, $

            {name: 'wave_region', type: '%d'}, $
            {name: 'ntunes', type: '%d'}, $

            {name: 'ucomp_sw_id', type: '%d'}]
  sql_cmd = string(strjoin(fields.name, ', '), $
                   strjoin(fields.type, ', '), $
                   format='(%"insert into ucomp_file (%s) values (%s)")')

  l2_dirname = filepath('', $
                        subdir=[run.date, 'level2'], $
                        root=run->config('processing/basedir'))

  types = [{product_type: 'mean', $
            product_description: 'UCoMP mean', $
            glob_basename: '*.ucomp.%s.*.mean.fts'}, $
           {product_type: 'median', $
            product_description: 'UCoMP median', $
            glob_basename: '*.ucomp.%s.*.median.fts'}, $
           {product_type: 'quick-invert', $
            product_description: 'UCoMP level 2 quick invert', $
            glob_basename: '*.ucomp.%s.*.quick_invert.fts'}]

  for t = 0L, n_elements(types) - 1L do begin
    q = 'select * from mlso_producttype where producttype=''%s'' and description like ''%s'''
    producttype_results = db->query(q, $
                                    types[t].product_type, $
                                    types[t].product_description, $
                                    status=status)
    if (status ne 0L) then goto, done
    producttype_index = producttype_results.producttype_id

    glob_basename = string(wave_region, format=types[t].glob_basename)
    glob_filename = filepath(glob_basename, root=l2_dirname)
    files = file_search(glob_filename, count=n_files)

    for f = 0L, n_files - 1L do begin
      mg_log, '%s', file_basename(files[f]), name=run.logger_name, /info

      fits_open, files[f], fcb
      fits_read, fcb, primary_data, primary_header, exten_no=0
      fits_close, fcb

      date_obs = ucomp_getpar(primary_header, 'DATE-OBS')
      n_wavelengths = ucomp_getpar(primary_header, 'NUMWAVE')
      carrington_rotation = ucomp_getpar(primary_header, 'CAR_ROT')
      obs_plan = ucomp_getpar(primary_header, 'OBS_PLAN')
      obs_id = ucomp_getpar(primary_header, 'OBS_ID')

      db->execute, sql_cmd, $
                   file_basename(files[f]), $
                   date_obs,$
                   obsday_index, $
                   carrington_rotation, $
                   level_index, $
                   producttype_index, $
                   filetype_index, $
                   obs_plan, $
                   obs_id, $
                   0, $
                   'NULL', $
                   'NULL', $
                   'NULL', $
                   'NULL', $
                   long(wave_region), $
                   n_wavelengths, $
                   sw_index, $
                   status=status, $
                   error_message=error_message, $
                   sql_statement=output_sql_cmd
      if (status ne 0L) then goto, done
    endfor
  endfor

  done:
end


; main-level example

date = '20220310'
wave_region = '1074'
mode = 'test'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, mode, config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      status=status, $
                      log_statements=run->config('database/log_statements'))
help, status
sw_index = ucomp_db_sw_insert(db, $
                              status=status, $
                              logger_name=run.logger_name)
help, status
obsday_index = ucomp_db_obsday_insert(date, db, $
                                      status=status, $
                                      logger_name=run.logger_name)
help, status

ucomp_db_l2_average_insert, wave_region, obsday_index, sw_index, db, run=run

obj_destroy, run

end
