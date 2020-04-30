; docformat = 'rst'

;+
; Create an averaged dark for each file and put this into a file.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_make_darks, run=run
  compile_opt strictarr

  mg_log, 'making darks...', name=run.logger_name, /info

  ; query run object for all the dark files
  dark_files = run->get_files(data_type='dark', count=n_dark_files)

  if (n_dark_files eq 0L) then goto, done

  dark_times = fltarr(n_dark_files)

  datetime = strmid(file_basename((dark_files[0]).raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)
  averaged_dark_images = fltarr(nx, ny, n_dark_files)

  for d = 0L, n_dark_files - 1L do begin
    dark_file = dark_files[d]
    mg_log, '%d/%d: processing %s', $
            d + 1, n_dark_files, file_basename(dark_file.raw_filename), $
            name=run.logger_name, /debug

    ; TODO: read dark_file and fill in dark_times and averaged_dark_images
  endfor

  ; TODO: write dark FITS file in the process_basedir/level

  done:
end
