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

  _method = mg_default(method, 'mean')

  n_files = n_elements(files)

  l1_dir = filepath('', $
                    subdir=[run.date, 'level1'], $
                    root=run->config('processing/basedir'))

  ; first pass of files: get list of wavelengths
  all_wavelengths = list()
  for f = 0L, n_files - 1L do begin
    mg_log, 'listing %d/%d %s', $
            f + 1L, n_files, files[f].l1_basename, $
            name=run.logger_name, /info

    ucomp_read_l1_data, filepath(files[f].l1_basename, root=l1_dir), $
                        ext_headers=ext_headers
    for e = 0L, n_elements(ext_headers) - 1L do begin
      wavelength = string(ucomp_getpar(ext_headers[e], 'WAVELNG'), format='(F0.2)')
      all_wavelengths->add, wavelength
    endfor
    obj_destroy, ext_headers
  endfor
  all_wavelengths_array = all_wavelengths->toArray()
  obj_destroy, all_wavelengths

  all_wavelengths = all_wavelengths_array[sort(all_wavelengths_array)]
  all_wavelengths = all_wavelengths[uniq(all_wavelengths)]
  n_unique_wavelengths = n_elements(all_wavelengths)

  ucomp_read_l1_data, filepath(files[0].l1_basename, root=l1_dir), $
                      primary_data=primary_data, $
                      primary_header=primary_header, $
                      ext_data=ext_data

  dims = size(ext_data, /dimensions)
  averaged_data = make_array(dimension=[dims[0:2], n_unique_wavelengths], $
                             type=size(ext_data, /type)) + !values.f_nan

  averaged_headers = list()

  ; second pass of files: compute total and number of extensions for each
  ; wavelength
  for w = 0L, n_unique_wavelengths - 1L do begin
    mg_log, 'averaging %d/%d: %0.2f nm', $
            w + 1L, $
            n_unique_wavelengths, $
            all_wavelengths[w], $
            name=run.logger_name, $
            /info

    wavelength_data = make_array(dimension=[dims[0:2], n_files], $
                                 type=size(ext_data, /type)) + !values.f_nan
    for f = 0L, n_files - 1L do begin
      ucomp_read_l1_data, filepath(files[f].l1_basename, root=l1_dir), $
                          primary_header=primary_header, $
                          ext_data=ext_data, $
                          ext_headers=ext_headers, $
                          n_extensions=n_extensions

      file_wavelengths = strarr(n_extensions)
      for e = 0L, n_extensions - 1L do begin
        file_wavelengths[e] = string(ucomp_getpar(ext_headers[e], 'WAVELNG'), $
                                     format='(F0.2)')
      endfor

      matching_indices = where(file_wavelengths eq all_wavelengths[w], n_matches)
      case n_matches of
        0L:
        1L: begin
            wavelength_data[*, *, *, f] = ext_data[*, *, *, matching_indices[0]]
            if (f eq 0L) then begin
              averaged_headers->add, ext_headers[matching_indices[0]]
            endif
          end
        else: begin
            wavelength_data[*, *, *, f] = mean(ext_data[*, *, *, matching_indices], $
                                               dimension=4)
            if (f eq 0L) then begin
              averaged_headers->add, ext_headers[matching_indices[0]]
            endif
          end
      endcase

      obj_destroy, ext_headers
    endfor

    ; TODO: need to average temperatures, SGS values also
    ; TODO: add start-end-number of files for average
    case _method of
      'mean': averaged_data[*, *, *, w] = mean(wavelength_data, dimension=4, /nan)
      'median': averaged_data[*, *, *, w] = median(wavelength_data, dimension=4)
      else:
    endcase
  endfor

  ucomp_write_fits_file, output_filename, $
                         primary_header, $
                         averaged_data, $
                         averaged_headers

  obj_destroy, averaged_headers

  done:
end
