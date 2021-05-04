; docformat = 'rst'

;+
; Insert an array of L0 FITS files into the ucomp_eng database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   database : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_eng_insert, l0_files, obsday_index, sw_index, db, logger_name=logger_name
  compile_opt strictarr

  n_files = n_elements(l0_files)
  mg_log, 'inserting %d files into ucomp_eng', n_files, name=logger_name, /info

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

    ; TODO: calculate these
    overlap_angle = 0.0
    post_angle = 0.0
    background = 0.0
    dmodswid = ''
    distortion = ''
    sky_pol_factor = 0.0
    sky_bias = 0.0

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'level_id', type: '%d'}, $

              {name: 'focus', type: '%f'}, $
              {name: 'o1focus', type: '%f'}, $

              {name: 'obs_id', type: '''%s'''}, $
              {name: 'obs_plan', type: '''%s'''}, $

              {name: 'cover', type: '%d'}, $
              {name: 'darkshutter', type: '%d'}, $
              {name: 'opal', type: '%d'}, $
              {name: 'polangle', type: '%f'}, $
              {name: 'retangle', type: '%f'}, $
              {name: 'caloptic', type: '%d'}, $

              {name: 'ixcnter1', type: '%f'}, $
              {name: 'iycnter1', type: '%f'}, $
              {name: 'iradius1', type: '%f'}, $
              {name: 'ixcnter2', type: '%f'}, $
              {name: 'iycnter2', type: '%f'}, $
              {name: 'iradius2', type: '%f'}, $

              {name: 'overlap_angle', type: '%f'}, $
              {name: 'post_angle', type: '%f'}, $

; wavelength       float (8, 3),
; ntunes           tinyint (2),
; pol_list         char (4),
; 
              {name: 'nextensions', type: '%d'}, $
; -- extract the rest from from first extension

              {name: 'exptime', type: '%f'}, $
              {name: 'nd', type: '%d'}, $
              {name: 'background', type: '%f'}, $

; bodytemp         float (9, 6),  --  temperature of filter body (deg C)
; basetemp         float (9, 6),  --  base plate temp (deg C)
; optrtemp         float (9, 6),  --  optical rail temp (deg C)
; lcvr4tmp         float (9, 6),  --  deg C

              {name: 'occltrid', type: '''%s'''}, $

              {name: 'dmodswid', type: '''%s'''}, $
              {name: 'distort', type: '''%s'''}, $

; bunit            varchar(12),
; bzero            float(6, 3),
; bscale           float(6, 3),
; labviewid        varchar(20),
; socketcamid      varchar(20),

              {name: 'sky_pol_factor', type: '%f'}, $
              {name: 'sky_bias', type: '%f'}, $

              {name: 'ucomp_sw_id', type: '%d'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_eng (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 level_index, $

                 file.focus, $
                 file.o1focus, $

                 file.obs_id, $
                 file.obs_plan, $

                 file.cover_in, $
                 file.darkshutter_in, $
                 file.opal_in, $
                 file.polangle, $
                 file.retangle, $
                 file.caloptic_in, $

                 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, $

                 overlap_angle, $
                 post_angle, $

                 file.n_extensions, $

                 file.exptime, $
                 file.nd, $
                 background, $

                 file.occultrid, $

                 dmodswid, $
                 distortion, $

                 sky_pol_factor, $
                 sky_bias, $

                 sw_index, $

                 status=status
  endfor

  done:
end
