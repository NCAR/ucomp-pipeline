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

  ok = bytarr(n_files)
  for f = 0L, n_files - 1L do begin
    ok[f] = file_test(filepath(files[f].l1_basename, root=l1_dir), /regular)
  endfor

  ok_indices = where(ok gt 0L, n_ok_files, /null)
  ok_files = files[ok_indices]

  if (n_ok_files eq 0L) then begin
    mg_log, 'no OK files to average', name=run.logger_name, /warn
    goto, done
  endif

  sgs_keywords = ['SGSSCINT', $
                  'SGSDIMV', $
                  'SGSDIMS', $
                  'SGSSUMV', $
                  'SGSSUMS', $
                  'SGSRAV', $
                  'SGSRAS', $
                  'SGSDECV', $
                  'SGSDECS', $
                  'SGSLOOP', $
                  'SGSRAZR', $
                  'SGSDECZR']
  n_sgs_keywords = n_elements(sgs_keywords)
  sgs_values = fltarr(n_sgs_keywords) + !values.f_nan
  sgs_counts = lonarr(n_sgs_keywords)

  temp_bases = ['RACK', 'LCVR1', 'LCVR2', 'LCVR3', 'LNB1', 'MOD', 'LNB2', $
                'LCVR4', 'LCVR5', 'BASE']
  temp_keywords = ['T_' + temp_bases, $
                   'TU_' + temp_bases, $
                   'T_C0ARR', $
                   'T_C0PCB', $
                   'T_C1ARR', $
                   'T_C1PCB']
  n_temp_keywords = n_elements(temp_keywords)
  temp_values = fltarr(n_temp_keywords) + !values.f_nan
  temp_counts = lonarr(n_temp_keywords)

  ; first pass of files: get list of wavelengths
  all_wavelengths = list()
  for f = 0L, n_ok_files - 1L do begin
    mg_log, 'listing %d/%d %s', $
            f + 1L, n_ok_files, ok_files[f].l1_basename, $
            name=run.logger_name, /info

    ucomp_read_l1_data, filepath(ok_files[f].l1_basename, root=l1_dir), $
                        primary_header=primary_header, $
                        ext_headers=ext_headers
    for e = 0L, n_elements(ext_headers) - 1L do begin
      wavelength = string(ucomp_getpar(ext_headers[e], 'WAVELNG'), format='(F0.2)')
      all_wavelengths->add, wavelength
    endfor
    for t = 0L, n_temp_keywords - 1L do begin
      temp = ucomp_getpar(primary_header, temp_keywords[t], found=found)
      if (found && (n_elements(temp) gt 0L)) then begin
        temp_counts[t] += 1L
        temp_values[t] += temp
      endif
    endfor
    obj_destroy, ext_headers
  endfor

  all_wavelengths_array = all_wavelengths->toArray()
  obj_destroy, all_wavelengths

  for t = 0L, n_temp_keywords - 1L do begin
    if (temp_counts[t] gt 0L) then temp_values[t] /= temp_counts[t]
    ucomp_addpar, primary_header, temp_keywords[t], temp_values[t]
  endfor

  if (n_elements(all_wavelengths_array) eq 0L) then begin
    all_wavelengths = all_wavelengths_array
    n_unique_wavelengths = 0L
  endif else begin
    all_wavelengths = all_wavelengths_array[sort(all_wavelengths_array)]
    all_wavelengths = all_wavelengths[uniq(all_wavelengths)]
    n_unique_wavelengths = n_elements(all_wavelengths)
  endelse

  ucomp_read_l1_data, filepath(ok_files[0].l1_basename, root=l1_dir), $
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

    wavelength_data = make_array(dimension=[dims[0:2], n_ok_files], $
                                 type=size(ext_data, /type)) + !values.f_nan
    for f = 0L, n_ok_files - 1L do begin
      ucomp_read_l1_data, filepath(ok_files[f].l1_basename, root=l1_dir), $
                          primary_header=primary_header, $
                          ext_data=ext_data, $
                          ext_headers=ext_headers, $
                          ; TODO: average backgrounds too
                          ;background_data=background_data, $
                          ;background_headers=background_headers, $
                          n_wavelengths=n_wavelengths

      file_wavelengths = strarr(n_wavelengths)
      for e = 0L, n_wavelengths - 1L do begin
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

    ; TODO: need to average SGS values also
    ;   How should they be averaged?
    ;     - SGS values are by extension in the level 0 file
    ;     - should level 1 files average them to the primary header?
    ;     - if so, average files could just average primary header
    ;     - if not, produce SGS averages of each wavelength?

    ucomp_addpar, primary_header, 'DATE-OBS', ok_files[0].date_obs
    ucomp_addpar, primary_header, 'DATE-END', ok_files[-1].date_obs, $
                  comment='UTC Date time when obs ended', $
                  after='DATE-OBS'
    ucomp_addpar, primary_header, 'NUM_WAVE', n_unique_wavelengths
    ucomp_addpar, primary_header, 'NUMFILES', n_ok_files

    if (size(wavelength_data, /n_dimensions) gt 3L) then begin
      case _method of
        'mean': averaged_data[*, *, *, w] = mean(wavelength_data, dimension=4, /nan)
        'median': averaged_data[*, *, *, w] = median(wavelength_data, dimension=4)
        else:
      endcase
    endif else averaged_data[*, *, *, w] = wavelength_data
  endfor

  ucomp_write_fits_file, output_filename, $
                         primary_header, $
                         averaged_data, $
                         averaged_headers

  ucomp_write_iquv_image, averaged_data, $
                          file_basename(output_filename), $
                          ok_files[0].wave_region, $
                          float(all_wavelengths), $
                          /daily, $
                          run=run

  obj_destroy, averaged_headers

  done:
end
