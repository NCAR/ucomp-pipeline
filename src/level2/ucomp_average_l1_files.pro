; docformat = 'rst'

;+
; Average an array of files.
;
; :Params:
;   files : in, required, type=objarr
;     UCoMP file objects for files to average
;   output_filename : in, required, type=string
;     filename of average file
;
; :Keywords:
;   method : in, optional, type=string, default=mean
;     averaging method: "mean" or "median"
;   run : in, optional, type=string
;     UCoMP run object
;-
pro ucomp_average_l1_files, files, output_filename, method=method, run=run
  compile_opt idl2

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    mg_log, /last_error, name=run.logger_name
    goto, done
  endif

  n_files = n_elements(files)

  l1_dir = filepath('', $
                    subdir=[run.date, 'level1'], $
                    root=run->config('processing/basedir'))

  ; first pass of files: get list of wavelengths
  all_wavelengths = list()
  for f = 0L, n_files - 1L do begin
    ucomp_read_l1_data, filepath(files[f].l1_basename, root=l1_dir), $
                        ext_headers=ext_headers
    for e = 0L, n_elements(ext_headers) - 1L do begin
      wavelength = ucomp_getpar(ext_headers[e], 'WAVELNG')
      mg_log, '%02d/%d [ext %d] %s: %0.3f nm', $
              f + 1L, n_files, e, files[f].l1_basename, wavelength, $
              name=run.logger_name, /debug
      all_wavelengths->add, wavelength
    endfor
    obj_destroy, ext_headers
  endfor
  all_wavelengths_array = all_wavelengths->toArray()
  obj_destroy, all_wavelengths

  all_wavelengths = sort(all_wavelengths_array)
  all_wavelengths = all_wavelengths[uniq(all_wavelengths)]
  n_unique_wavelengths = n_elements(all_wavelengths)

  ucomp_read_l1_data, filepath(files[0].l1_basename, root=l1_dir), $
                      primary_data=primary_data, $
                      primary_header=primary_header, $
                      ext_data=ext_data

  dims = size(ext_data, /dimensions)
  all_data = make_array(dimension=[dims[0:2], n_unique_wavelengths], $
                        type=size(ext_data, /type)) + !values.f_nan
  n_extensions_by_wavelength = lonarr([dims[0:2], n_unique_wavelengths])

  ; second pass of files: compute total and number of extensions for each
  ; wavelength

  for f = 0L, n_files - 1L do begin
    ucomp_read_l1_data, filepath(files[f].l1_basename, root=l1_dir), $
                        primary_data=primary_data, $
                        primary_header=primary_header, $
                        ext_data=ext_data, $
                        ext_headers=ext_headers, $
                        n_extensions=n_extensions

    if (f eq 0) then template_header = ext_headers[0]

    for e = 0L, n_extensions - 1L do begin
      wavelength = ucomp_getpar(ext_headers[e], 'WAVELNG')
      ; TODO: need to average temperatures
      wavelength_match_indices = where(wavelength eq all_wavelengths, n_matches)
      all_data[0, 0, 0, wavelength_match_indices[0]] += ext_data[*, *, *, e]
      n_extensions_by_wavelength[*, *, *, wavelength_match_indices[0]] += 1L
     endfor

     obj_destroy, ext_headers
  endfor

  _method = mg_default(method, 'mean')
  case _method of
    'mean': averaged_data = all_data / n_extensions_by_wavelength ;averaged_data = mean(all_data, dimension=5, /nan)
    'median': message, 'median averaging method not implemented';averaged_data = median(all_data, dimension=5)
    else: message, string(_method, format='(%"unknown averaging method %s")')
  endcase

  ext_headers = list()

  for e = 0L, n_unique_wavelengths - 1L do begin
    ucomp_addpar, template_header, 'WAVELNG', all_wavelengths[e]
    ext_headers->add, template_header
  endfor

  ucomp_write_fits_file, output_filename, primary_header, averaged_data, ext_headers

  obj_destroy, ext_headers

  done:
end
