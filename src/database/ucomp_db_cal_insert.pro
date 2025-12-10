; docformat = 'rst'


;+
; Insert an array of L0 FITS files into the ucomp_cal database table.
;
; :Params:
;   files : in, required, type=objarr
;     array of `UCOMP_FILE` objects
;   type : in, required, type=string
;     type of cal file, i.e., 'dark', 'flat', or 'cal'
;   wave_region : in, required, type=string
;     wave region for the given flat files
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   sw_index : in, required, type=integer
;     index into the ucomp_sw database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_cal_insert, files, type, $
                         obsday_index, sw_index, wave_region, $
                         database=db, $
                         logger_name=logger_name, run=run
  compile_opt strictarr

  type_name = n_elements(wave_region) eq 0L $
    ? string(type, format='%s files') $
    : string(wave_region, type, format='%s nm %s files')

  n_files = n_elements(files)
  if (n_files eq 0L) then begin
    mg_log, 'no %s files to insert into ucomp_cal', type_name, $
            name=logger_name, /info
    goto, done
  endif else begin
    mg_log, 'inserting %d %s files into ucomp_cal', n_files, type_name, $
            name=logger_name, /info
  endelse

  ; get index for raw (level 0) data files
  q = 'select * from ucomp_level where level=''L0'''
  level_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id

  if (type eq 'flat') then begin
    l1_dir = filepath('level1', $
                      subdir=run.date, $
                      root=run->config('processing/basedir'))
    master_darkcorrected_flat_basename = string(run.date, wave_region, $
                                                format='(%"%s.ucomp.%s.flat.fts")')
    master_darkcorrected_flat_filename = filepath(master_darkcorrected_flat_basename, $
                                                  root=l1_dir)
    if (file_test(master_darkcorrected_flat_filename)) then begin
      ucomp_read_master_flats, master_darkcorrected_flat_filename, $
                               flats=master_flats, $
                               raw_filenames=raw_filenames, $
                               onband=onband
  
      field_mask = ucomp_field_mask([run->epoch('nx'), run->epoch('ny')], $
                                    run->epoch('field_radius'))
      field_indices = where(field_mask eq 1)
    endif
  endif

  fields = [{name: 'file_name', type: '''%s'''}, $
            {name: 'date_obs', type: '''%s'''}, $
            {name: 'obsday_id', type: '%d'}, $
            {name: 'wave_region', type: '''%s'''}, $
            {name: 'type', type: '''%s'''}, $
            {name: 'quality', type: '%d'}, $
            {name: 'n_points', type: '%d'}, $

            {name: 'level_id', type: '%d'}, $
            {name: 'exptime', type: '%f'}, $
            {name: 'gain_mode', type: '''%s'''}, $
            {name: 'nd', type: '%d'}, $
            {name: 'cover', type: '%d'}, $
            {name: 'darkshutter', type: '%d'}, $
            {name: 'opal', type: '%d'}, $
            {name: 'occulter', type: '%d'}, $
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

            {name: 'darkcorrected_rcam_median_linecenter', type: '%s'}, $
            {name: 'darkcorrected_rcam_median_continuum', type: '%s'}, $
            {name: 'darkcorrected_tcam_median_linecenter', type: '%s'}, $
            {name: 'darkcorrected_tcam_median_continuum', type: '%s'}, $

            {name: 'occltrid', type: '''%s'''}, $
            {name: 'ucomp_sw_id', type: '%d'}]
  sql_cmd = string(strjoin(fields.name, ', '), $
                   strjoin(fields.type, ', '), $
                   format='(%"insert into ucomp_cal (%s) values (%s)")')

  for f = 0L, n_files - 1L do begin
    file = files[f]

    mg_log, '%d/%d: ingesting %s', f + 1, n_files, file_basename(file.raw_filename), $
            name=logger_name, /info

    if ((n_elements(master_flats) gt 0L) && (type eq 'flat')) then begin
      ; lookup raw filename
      file_matching_indices = where(file_basename(file.raw_filename) eq raw_filenames, $
                                    n_file_matching)
      if (n_file_matching ne 2L) then begin
        mg_log, 'did not find exactly two center wavelength flats for file', $
                name=logger_name, /warn
      endif
      onband_values = onband[file_matching_indices]
      for i = 0L, n_file_matching - 1L do begin
        rcam = reform(master_flats[*, *, 0, file_matching_indices[i]])
        tcam = reform(master_flats[*, *, 1, file_matching_indices[i]])

        ; mask corners
        rcam = rcam[field_indices]
        tcam = tcam[field_indices]

        ; onband=0 (RCAM onband) and onband=1 (TCAM onband)
        if (onband[file_matching_indices[i]] eq 0L) then begin
          darkcorrected_rcam_median_linecenter = median(rcam)
          darkcorrected_tcam_median_continuum = median(tcam)
        endif else begin
          darkcorrected_tcam_median_linecenter = median(tcam)
          darkcorrected_rcam_median_continuum = median(rcam)
        endelse
      endfor
    endif

    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 file.wave_region, $
                 file.data_type, $
                 file.quality_bitmask, $
                 file.n_unique_wavelengths, $

                 level_index, $
                 file.exptime, $
                 file.gain_mode, $
                 file.nd, $
                 file.cover_in, $
                 file.darkshutter_in, $
                 file.opal_in, $
                 file.occulter_in, $
                 file.polangle, $
                 file.retangle, $
                 file.caloptic_in, $

                 file.dark_id, $
                 file.rcamnuc, $
                 file.tcamnuc, $

                 ucomp_db_float(file.rcam_roughness, format='%0.6f'), $
                 ucomp_db_float(file.tcam_roughness, format='%0.6f'), $

                 ucomp_db_float(file.rcam_median_continuum, format='%0.3f'), $
                 ucomp_db_float(file.rcam_median_linecenter, format='%0.3f'), $
                 ucomp_db_float(file.tcam_median_continuum, format='%0.3f'), $
                 ucomp_db_float(file.tcam_median_linecenter, format='%0.3f'), $

                 ucomp_db_float(darkcorrected_rcam_median_linecenter, format='%0.3f'), $
                 ucomp_db_float(darkcorrected_rcam_median_continuum, format='%0.3f'), $
                 ucomp_db_float(darkcorrected_tcam_median_linecenter, format='%0.3f'), $
                 ucomp_db_float(darkcorrected_tcam_median_continuum, format='%0.3f'), $

                 file.occultrid, $
                 sw_index, $

                 status=status
  endfor

  done:
end
