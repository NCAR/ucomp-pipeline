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
    if (files[f].ok) then return, files[f]
  endfor

  count = 0L
  return, !null
end


;+
; Choose representative science file(s) from an array of L0 FITS files and
; enter them into the ucomp_sci database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
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
pro ucomp_db_sci_insert, l0_files, obsday_index, sw_index, db, $
                         run=run
  compile_opt strictarr

  if (n_elements(l0_files) eq 0L) then begin
    mg_log, 'no science file to insert, skipping', name=run.logger_name, /info
    goto, done
  endif

  ; choose science file -- right now, just the first file
  science_files = ucomp_db_sci_insert_select(l0_files, count=n_files)
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
                        n_extensions=n_extensions

    center_indices = file->get_center_wavelength_indices()
    center_data = ext_data[*, *, *, center_indices[0]]

    intensity = center_data[*, *, 0]
    intensity108 = ucomp_annulus_gridmeans(intensity, 1.08, sun_pixels)
    intensity13 = ucomp_annulus_gridmeans(intensity, 1.3, sun_pixels)

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'wave_region', type: '''%s'''}, $
              {name: 'r108i', type: '''%s'''}, $
              {name: 'r13i', type: '''%s'''}, $
              {name: 'ucomp_sw_id', type: '%d'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_sci (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file.l1_basename, $
                 file.date_obs, $
                 obsday_index, $
                 file.wave_region, $

                 db->escape_string(intensity108), $
                 db->escape_string(intensity13), $

                 sw_index, $

                 status=status
  endfor

  done:
end
