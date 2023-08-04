; docformat = 'rst'

;+
; Select files to put into the database.
;
; :Returns:
;   `objarr` of UCoMP file objects
;
; :Params:
;   files : in, required, type=objarr
;     `objarr` of UCoMP file objects
;
; :Keywords:
;   count : out, optional, type=integer
;     set to a named variable to retrieve the number of files returned
;-
function ucomp_db_sci_insert_select, files, count=count
  compile_opt strictarr

  n_files = n_elements(files)
  count = 1L
  for f = 0L, n_files - 1L do begin
    if (files[f].wrote_l1 and files[f].good) then return, files[f]
  endfor

  count = 0L
  return, !null
end


;+
; Choose representative science file(s) from an array of L0 FITS files and
; enter them into the ucomp_sci database table.
;
; :Params:
;   files : in, required, type=objarr
;     array of `UCOMP_FILE` objects
;   wave_region : in, required, type=string
;     wave region for science files
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   sw_index : in, required, type=integer
;     index into ucomp_sw database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_db_sci_insert, files, wave_region, $
                         obsday_index, sw_index, db, $
                         run=run
  compile_opt strictarr

  if (n_elements(files) eq 0L) then begin
    mg_log, 'no science file to insert, skipping', name=run.logger_name, /info
    goto, done
  endif

  ; choose science file -- right now, just the first file
  science_files = ucomp_db_sci_insert_select(files, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no appropriate files for ucomp_sci', name=run.logger_name, /info
    goto, done
  endif else begin
    mg_log, 'inserting %d files into ucomp_sci', n_files, $
            name=run.logger_name, /info
  endelse

  process_basedir = run->config('processing/basedir')
  process_dir = filepath(run.date, root=process_basedir)

  for f = 0L, n_files - 1L do begin
    file = science_files[f]


    file->getProperty, ut_date=ut_date, ut_time=ut_time
    hrs = [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0]
    ut_date_parts = ucomp_decompose_date(ut_date)
    fhour = total(ucomp_decompose_time(ut_time) * hrs)

    sun, ut_date_parts[0], ut_date_parts[1], ut_date_parts[2], fhour, sd=rsun
    sun_pixels = rsun / run->line(file.wave_region, 'plate_scale')

    mg_log, 'ingesting %s', file.l1_basename, name=run.logger_name, /info
    filename = filepath(file.l1_basename, $
                        subdir='level1', $
                        root=process_dir)
    ucomp_read_l1_data, filename, $
                        primary_data=primary_data, $
                        primary_header=primary_header, $
                        ext_data=ext_data, $
                        ext_headers=ext_headers, $
                        n_wavelengths=n_wavelengths

    center_indices = file->get_center_wavelength_indices()
    if (n_elements(center_indices) eq 0L) then begin
      mg_log, '%s does not contain center wavelength', file.l1_basename, $
              name=run.logger_name, /warn
      goto, done
    endif
    center_data = ext_data[*, *, *, center_indices[0]]

    intensity    = center_data[*, *, 0]
    q            = center_data[*, *, 1]
    u            = center_data[*, *, 2]

    dims = size(intensity, /dimensions)
    annulus = ucomp_annulus(1.1, 2.0, dimensions=dims)
    annulus_indices = where(annulus gt 0.0)
    total_i = total(intensity[annulus_indices])
    total_q = total(q[annulus_indices])
    total_u = total(u[annulus_indices])

    i_profile = ucomp_radial_profile(intensity, sun_pixels, $
                                     standard_deviation=i_profile_stddev)
    q_profile = ucomp_radial_profile(q, sun_pixels, $
                                     standard_deviation=q_profile_stddev)
    u_profile = ucomp_radial_profile(u, sun_pixels, $
                                     standard_deviation=u_profile_stddev)

    intensity108 = ucomp_annulus_gridmeans(intensity, 1.08, sun_pixels)
    intensity13  = ucomp_annulus_gridmeans(intensity, 1.3, sun_pixels)

    linearpol    = sqrt(q^2 + u^2)
    linearpol108 = ucomp_annulus_gridmeans(linearpol, 1.08, sun_pixels)
    linearpol13  = ucomp_annulus_gridmeans(linearpol, 1.3, sun_pixels)

    azimuth = ucomp_azimuth(q, u, radial_azimuth=radial_azimuth)
    radial_azimuth108 = ucomp_annulus_gridmeans(radial_azimuth, 1.08, sun_pixels)
    radial_azimuth13  = ucomp_annulus_gridmeans(radial_azimuth, 1.3, sun_pixels)

    !null = ucomp_doppler(file, ext_data, velocity=velocity, run=run)
    velocity_type = n_elements(velocity) eq 0L ? '%s' : '''%s'''
    if (n_elements(velocity) ne 0L) then begin
      velocity108 = ucomp_annulus_gridmeans(velocity, 1.08, sun_pixels)
      velocity13  = ucomp_annulus_gridmeans(velocity, 1.3, sun_pixels)
    endif

    float_fmt = '%0.3f'

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'wave_region', type: '''%s'''}, $
              {name: 'totali', type: '%s'}, $
              {name: 'totalq', type: '%s'}, $
              {name: 'totalu', type: '%s'}, $
              {name: 'intensity', type: '''%s'''}, $
              {name: 'intensity_stddev', type: '''%s'''}, $
              {name: 'q', type: '''%s'''}, $
              {name: 'q_stddev', type: '''%s'''}, $
              {name: 'u', type: '''%s'''}, $
              {name: 'u_stddev', type: '''%s'''}, $
              {name: 'r108i', type: '''%s'''}, $
              {name: 'r13i', type: '''%s'''}, $
              {name: 'r108l', type: '''%s'''}, $
              {name: 'r13l', type: '''%s'''}, $
              {name: 'r108radazi', type: '''%s'''}, $
              {name: 'r13radazi', type: '''%s'''}, $
              ; {name: 'r108doppler', type: velocity_type}, $
              ; {name: 'r13doppler', type: velocity_type}, $
              {name: 'ucomp_sw_id', type: '%d'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_sci (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file.l1_basename, $
                 file.date_obs, $
                 obsday_index, $
                 file.wave_region, $

                 ucomp_db_float(total_i, format=float_fmt), $
                 ucomp_db_float(total_q, format=float_fmt), $
                 ucomp_db_float(total_u, format=float_fmt), $

                 db->escape_string(i_profile), $
                 db->escape_string(i_profile_stddev), $
                 db->escape_string(q_profile), $
                 db->escape_string(q_profile_stddev), $
                 db->escape_string(u_profile), $
                 db->escape_string(u_profile_stddev), $

                 db->escape_string(intensity108), $
                 db->escape_string(intensity13), $
                 db->escape_string(linearpol108), $
                 db->escape_string(linearpol13), $
                 db->escape_string(radial_azimuth108), $
                 db->escape_string(radial_azimuth13), $
                 ; TODO: add once we upgrade database
                 ; db->escape_string(velocity108), $
                 ; db->escape_string(velocity13), $

                 sw_index, $

                 status=status
  endfor

  done:
end
