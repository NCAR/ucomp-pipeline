; docformat = 'rst'

;+
; Insert an array of L0 FITS files into the ucomp_cal database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_cal_insert, l0_files, obsday_index, sw_index, db, logger_name=logger_name
  compile_opt strictarr

  n_files = n_elements(l0_files)
  mg_log, 'inserting %d files into ucomp_cal', n_files, name=logger_name, /info

  ; get index for OK quality data files
  q = 'select * from ucomp_quality where quality=''OK'''
  quality_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  quality_index = quality_results.quality_id	

  ; get index for raw (level 0) data files
  q = 'select * from ucomp_level where level=''L0'''
  level_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id	

  for f = 0L, n_files - 1L do begin
    file = l0_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'wave_region', type: '''%s'''}, $
              {name: 'type', type: '''%s'''}, $
              {name: 'n_points', type: '%d'}, $

              {name: 'level_id', type: '%d'}, $
              {name: 'exptime', type: '%f'}, $
              {name: 'nd', type: '%d'}, $
              {name: 'cover', type: '%d'}, $
              {name: 'darkshutter', type: '%d'}, $
              {name: 'opal', type: '%d'}, $
              {name: 'polangle', type: '%f'}, $
              {name: 'retangle', type: '%f'}, $
              {name: 'caloptic', type: '%d'}, $

              {name: 'dark_id', type: '''%s'''}, $
              {name: 'rcamnuc', type: '''%s'''}, $
              {name: 'tcamnuc', type: '''%s'''}, $

              {name: 'rcam_roughness', type: '%s'}, $
              {name: 'tcam_roughness', type: '%s'}, $
              {name: 'rcam_median_continuum', type: '%s'}, $
              {name: 'rcam_median_linecenter', type: '%s'}, $
              {name: 'tcam_median_continuum', type: '%s'}, $
              {name: 'tcam_median_linecenter', type: '%s'}, $

              {name: 'occltrid', type: '''%s'''}, $
              {name: 'ucomp_sw_id', type: '%d'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_cal (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 file.wave_region, $
                 file.data_type, $
                 file.n_unique_wavelengths, $

                 level_index, $
                 file.exptime, $
                 file.nd, $
                 file.cover_in, $
                 file.darkshutter_in, $
                 file.opal_in, $
                 file.polangle, $
                 file.retangle, $
                 file.caloptic_in, $

                 file.dark_id, $
                 file.rcamnuc, $
                 file.tcamnuc, $

                 ucomp_db_float(file.rcam_roughness, format='%0.6f'), $
                 ucomp_db_float(file.tcam_roughness, format='%0.6f'), $
                 ucomp_db_float(file.rcam_median_continuum), $
                 ucomp_db_float(file.rcam_median_linecenter), $
                 ucomp_db_float(file.tcam_median_continuum), $
                 ucomp_db_float(file.tcam_median_linecenter), $

                 file.occultrid, $
                 sw_index, $

                 status=status
  endfor

  done:
end
