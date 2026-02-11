; docformat = 'rst'

;+
; Insert an array of L1 or L2 FITS files into the ucomp_file database table.
;
; :Params:
;   files : in, required, type=objarr
;     array of `UCOMP_FILE` objects
;   level : in, required, type=string
;     level, e.g., 'L1' or 'L2'
;   product_type : in, required, type=string
;     product type, e.g., 'IQUV', 'dynamics', 'L2 file', 'mean', 'median'
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   sw_index : in, required, type=integer
;     index into ucomp_sw database table
;   db : in, required, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, optional, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_file_insert, files, level, product_type, $
                          obsday_index, sw_index, db, $
                          logger_name=logger_name
  compile_opt strictarr

  n_files = n_elements(files)

  if (level eq 'L1') then begin
    file_type = string(level, product_type, format='%s %s')
  endif else file_type = level

  if (n_files eq 0L) then begin
    mg_log, 'no %s files for ucomp_file', file_type, $
            name=logger_name, /info
    goto, done
  endif else begin
    mg_log, 'inserting up to %d %s nm %s files', $
            n_files, files[0].wave_region, file_type, $
            name=logger_name, /info
  endelse

  ; get index for level 1 data files
  q = 'select * from ucomp_level where level=''%s'''
  level_results = db->query(q, level, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id

  ; get index for intensity files
  q = 'select * from mlso_producttype where producttype=''%s'' and description like ''UCoMP%%'''
  producttype_results = db->query(q, product_type, status=status)
  if (status ne 0L) then goto, done
  producttype_index = producttype_results.producttype_id

  ; get index for FITS files
  q = 'select * from mlso_filetype where filetype=''fits'''
  filetype_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  filetype_index = filetype_results.filetype_id

  fields = [{name: 'file_name', type: '''%s'''}, $
            {name: 'filesize', type: '%d'}, $
            {name: 'l0_file_name', type: '''%s'''}, $
            {name: 'date_obs', type: '''%s'''}, $
            {name: 'obsday_id', type: '%d'}, $
            {name: 'obsday_hours', type: '%f'}, $
            {name: 'carrington_rotation', type: '%d'}, $

            {name: 'level_id', type: '%d'}, $
            {name: 'producttype_id', type: '%d'}, $
            {name: 'filetype_id', type: '%d'}, $

            {name: 'obs_plan', type: '''%s'''}, $
            {name: 'obs_id', type: '''%s'''}, $

            {name: 'quality', type: '%d'}, $
            {name: 'gbu', type: '%d'}, $

            {name: 'n_rcam_onband_saturated_pixels', type: '%d'}, $
            {name: 'n_tcam_onband_saturated_pixels', type: '%d'}, $
            {name: 'n_rcam_bkg_saturated_pixels', type: '%d'}, $
            {name: 'n_tcam_bkg_saturated_pixels', type: '%d'}, $
            {name: 'n_rcam_onband_nonlinear_pixels', type: '%d'}, $
            {name: 'n_tcam_onband_nonlinear_pixels', type: '%d'}, $
            {name: 'n_rcam_bkg_nonlinear_pixels', type: '%d'}, $
            {name: 'n_tcam_bkg_nonlinear_pixels', type: '%d'}, $

            {name: 'max_n_rcam_nonlinear_pixels_by_frame', type: '%d'}, $
            {name: 'max_n_tcam_nonlinear_pixels_by_frame', type: '%d'}, $

            {name: 'median_background', type: '%s'}, $
            {name: 'vcrosstalk_metric', type: '%s'}, $
            {name: 'wind_speed', type: '%s'}, $
            {name: 'wind_direction', type: '%s'}, $

            {name: 'wave_region', type: '%d'}, $
            {name: 'ntunes', type: '%d'}, $

            {name: 'ucomp_sw_id', type: '%d'}]
  sql_cmd_fmt = string(strjoin(fields.name, ', '), $
                       strjoin(fields.type, ', '), $
                       format='(%"insert into ucomp_file (%s) values (%s)")')

  for f = 0L, n_files - 1L do begin
    file = files[f]

    if (~file.wrote_l1) then begin
      mg_log, 'skipping %s', file.l1_basename, name=logger_name, /debug
      continue
    endif

    if (strlowcase(product_type) eq 'iquv') then begin
      filename = file.l1_basename
    endif else if (strlowcase(product_type) eq 'intensity') then begin
      filename = file.l1_intensity_basename
    endif else if (strlowcase(product_type) eq 'l2 file') then begin
      if (~file.wrote_l2) then begin
        mg_log, 'skipping %s', file.l2_basename, name=logger_name, /debug
        continue
      endif
      filename = file.l2_basename
    endif else begin
      mg_log, 'unknown product_type: %s', product_type, name=logger_name, /warn
      continue
    endelse

    mg_log, 'ingesting %s', file.l1_basename, name=logger_name, /info

    db->execute, sql_cmd_fmt, $
                 filename, $
                 mg_filesize(file.l1_filename), $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 file.obsday_hours, $
                 long(file.carrington_rotation), $
                 level_index, $
                 producttype_index, $
                 filetype_index, $
                 file.obs_plan_name, $
                 file.obs_id_name, $

                 file.quality_bitmask, $
                 file.gbu, $

                 file.n_rcam_onband_saturated_pixels, $
                 file.n_tcam_onband_saturated_pixels, $
                 file.n_rcam_bkg_saturated_pixels, $
                 file.n_tcam_bkg_saturated_pixels, $
                 file.n_rcam_onband_nonlinear_pixels, $
                 file.n_tcam_onband_nonlinear_pixels, $
                 file.n_rcam_bkg_nonlinear_pixels, $
                 file.n_tcam_bkg_nonlinear_pixels, $

                 file.max_n_rcam_nonlinear_pixels_by_frame, $
                 file.max_n_tcam_nonlinear_pixels_by_frame, $

                 ucomp_db_float(file.median_background, format='%0.4f'), $
                 ucomp_db_float(file.vcrosstalk_metric, $
                                valid_range=[0.0, 999.0], $
                                format='%0.4f'), $
                 ucomp_db_float(file.wind_speed, format='%0.3f'), $
                 ucomp_db_float(file.wind_direction, format='%0.3f'), $
                 long(file.wave_region), $
                 file.n_unique_wavelengths, $
                 sw_index, $
                 status=status, $
                 error_message=error_message, $
                 sql_statement=sql_cmd
    if (status ne 0L) then goto, done
  endfor

  done:
end
