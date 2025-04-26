; docformat = 'rst'

;+
; Insert an array of density files into the ucomp_file table.
;-
pro ucomp_db_density_insert, density_basenames, run=run
  compile_opt strictarr

  l3_dir = filepath('', $
                    subdir=[run.date, 'level3'], $
                    root=run->config('processing/basedir'))

  ; connect to the database
  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        logger_name=run.logger_name, $
                        log_statements=run->config('database/log_statements'), $
                        status=status)
  if (status ne 0) then goto, done

  ; get the observing day index for the date
  obsday_index = ucomp_db_obsday_insert(run.date, db, $
                                        status=status, $
                                        logger_name=run.logger_name)

  ; insert a software entry, if needed
  sw_index = ucomp_db_sw_insert(db, $
                                status=status, $
                                logger_name=run.logger_name)

  ; get index for level 3 data files
  q = 'select * from ucomp_level where level=''L3'''
  level_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id

  ; get index for intensity files
  q = 'select * from mlso_producttype where producttype=''%s'''
  producttype_results = db->query(q, 'density', status=status)
  if (status ne 0L) then goto, done
  producttype_index = producttype_results.producttype_id

  ; get index for FITS files
  q = 'select * from mlso_filetype where filetype=''fits'''
  filetype_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  filetype_index = filetype_results.filetype_id

  fields = [{name: 'file_name', type: '''%s'''}, $

            {name: 'date_obs', type: '''%s'''}, $
            {name: 'obsday_id', type: '%d'}, $
            {name: 'obsday_hours', type: '%f'}, $
            {name: 'carrington_rotation', type: '%d'}, $

            {name: 'level_id', type: '%d'}, $
            {name: 'producttype_id', type: '%d'}, $
            {name: 'filetype_id', type: '%d'}, $

            {name: 'quality', type: '%d'}, $
            {name: 'gbu', type: '%d'}, $

            {name: 'ucomp_sw_id', type: '%d'}]
  sql_cmd_fmt = string(strjoin(fields.name, ', '), $
                       strjoin(fields.type, ', '), $
                       format='(%"insert into ucomp_file (%s) values (%s)")')

  for f = 0L, n_elements(density_basenames) - 1L do begin
    mg_log, 'ingesting %s', density_basenames[f], name=logger_name, /info

    density_filename = filepath(density_basenames[f], root=l3_dir)
    primary_header = headfits(density_filename)
    date_obs = ucomp_getpar(primary_header, 'DATE-OBS')

    date_parts = strsplit(date_obs, '-T', /extract)
    time_parts = strmid(strsplit(date_parts[3], ':', /extract), 0, 2)

    ut_date = strjoin(date_parts[0:2])
    ut_time = strjoin(time_parts)
    ucomp_ut2hst, ut_date, ut_time, hst_date=hst_date, hst_time=hst_time

    hours = ucomp_decompose_time(ut_time, /float)
    sun, date_parts[0], date_parts[1], date_parts[2], hours, $
         carrington=carrington_rotation

    hrs = [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0]
    obsday_hours = total(float(ucomp_decompose_time(hst_time)) * hrs)

    db->execute, sql_cmd_fmt, $
                 density_basenames[f], $

                 date_obs, $
                 obsday_index, $
                 obsday_hours, $
                 carrington_rotation, $

                 level_index, $
                 producttype_index, $
                 filetype_index, $

                 0UL, $
                 0UL, $

                 sw_index, $
                 status=status, $
                 error_message=error_message, $
                 sql_statement=sql_cmd

    if (status ne 0L) then goto, done
  endfor

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end


; main-level example program

date = '20240409'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

density_basenames = ['20240409.180747-180009.ucomp.1074-1079.density.fts', $
                     '20240409.210752-210322.ucomp.1074-1079.density.fts', $
                     '20240409.214658-214229.ucomp.1074-1079.density.fts']
ucomp_db_density_insert, density_basenames, run=run

obj_destroy, run

end
