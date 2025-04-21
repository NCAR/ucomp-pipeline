; docformat = 'rst'

;+
; Average an array of files.
;
; :Params:
;   l1_filenames : in, required, type=strarr
;     UCoMP L1 filenames for files to average
;   output_filenames : in, optional, type=strarr(3)
;     filenames of average files (mean, median, sigma); if not present, do not
;     write the output file; must be in the order mean, median, sigma
;
; :Keywords:
;   mean_averaged_data : type, optional, type="fltarr(nx, ny, n_pol_state, n_wavelength)"
;     set to a named variable to retrieve the mean averaged data
;   median_averaged_data : type, optional, type="fltarr(nx, ny, n_pol_state, n_wavelength)"
;     set to a named variable to retrieve the median averaged data
;   sigma_data : type, optional, type="fltarr(nx, ny, n_pol_state, n_wavelength)"
;     set to a named variable to retrieve the standard deviation data
;   run : in, optional, type=object
;     UCoMP run object, only needed to produce display images
;-
pro ucomp_average_l1_files, l1_filenames, $
                            output_filenames, $
                            mean_averaged_data=mean_averaged_data, $
                            median_averaged_data=median_averaged_data, $
                            sigma_data=sigma_data, $
                            logger_name=logger_name, $
                            min_average_files=min_average_files, $
                            run=run
  compile_opt idl2

  catch, error
  if (error ne 0) then begin
    catch, /cancel
    mg_log, /last_error, name=logger_name
    goto, done
  endif

  n_files = n_elements(l1_filenames)

  ok = bytarr(n_files)
  for f = 0L, n_files - 1L do begin
    ok[f] = file_test(l1_filenames[f], /regular)
  endfor

  ok_indices = where(ok gt 0L, n_ok_files, /null)
  ok_files = l1_filenames[ok_indices]

  if (n_ok_files eq 0L) then begin
    mg_log, 'no OK files to average', name=logger_name, /warn
    goto, done
  endif

  _min_average_files = n_elements(min_average_files) eq 0L ? 1L : min_average_files
  if (n_ok_files lt _min_average_files) then begin
    mg_log, 'not enough OK files to average (%d < %d)', $
            n_ok_files, min_average_files, $
            name=logger_name, /warn
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
                   'TU_C0ARR', $
                   'TU_C0PCB', $
                   'TU_C1ARR', $
                   'TU_C1PCB']
  n_temp_keywords = n_elements(temp_keywords)
  temp_values = fltarr(n_temp_keywords) + !values.f_nan
  temp_counts = lonarr(n_temp_keywords)

  ; first pass of files: get list of wavelengths
  all_wavelengths = list()
  for f = 0L, n_ok_files - 1L do begin
    mg_log, 'listing %d/%d %s', $
            f + 1L, n_ok_files, file_basename(ok_files[f]), $
            name=logger_name, /debug

    ucomp_read_l1_data, ok_files[f], $
                        primary_header=primary_header, $
                        ext_headers=ext_headers
    for e = 0L, n_elements(ext_headers) - 1L do begin
      wavelength = string(ucomp_getpar(ext_headers[e], 'WAVELNG'), format='(F0.3)')
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

  ucomp_read_l1_data, ok_files[0], $
                      primary_data=primary_data, $
                      primary_header=primary_header, $
                      ext_data=ext_data

  dims = size(ext_data, /dimensions)
  mean_averaged_data = make_array(dimension=[dims[0:2], n_unique_wavelengths], $
                                  type=size(ext_data, /type)) + !values.f_nan
  mean_averaged_background = make_array(dimension=[dims[0:1], n_unique_wavelengths], $
                                        type=size(ext_data, /type)) + !values.f_nan

  median_averaged_data = mean_averaged_data
  median_averaged_background = mean_averaged_background
  sigma_data = mean_averaged_data
  sigma_background = mean_averaged_background
  sum2_data = mean_averaged_data
  sum2_background = mean_averaged_background

  averaged_headers = list()
  averaged_background_headers = list()

  ; second pass of files: compute total and number of extensions for each
  ; wavelength
  for w = 0L, n_unique_wavelengths - 1L do begin
    mg_log, 'averaging %d/%d: %0.3f nm', $
            w + 1L, $
            n_unique_wavelengths, $
            all_wavelengths[w], $
            name=logger_name, $
            /info

    mean_wavelength_data = make_array(dimension=[dims[0:2], n_ok_files], $
                                      type=size(ext_data, /type)) + !values.f_nan
    median_wavelength_data = make_array(dimension=[dims[0:2], n_ok_files], $
                                        type=size(ext_data, /type)) + !values.f_nan
    sum2_wavelength_data = make_array(dimension=[dims[0:2], n_ok_files], $
                                      type=size(ext_data, /type)) + !values.f_nan
    mean_background_data = make_array(dimension=[dims[0:1], n_ok_files], $
                                      type=size(ext_data, /type)) + !values.f_nan
    median_background_data = make_array(dimension=[dims[0:1], n_ok_files], $
                                        type=size(ext_data, /type)) + !values.f_nan
    sum2_background_data = make_array(dimension=[dims[0:1], n_ok_files], $
                                      type=size(ext_data, /type)) + !values.f_nan
    for f = 0L, n_ok_files - 1L do begin
      ucomp_read_l1_data, ok_files[f], $
                          primary_header=primary_header, $
                          ext_data=ext_data, $
                          ext_headers=ext_headers, $
                          background_data=ext_background_data, $
                          background_headers=background_headers, $
                          n_wavelengths=n_wavelengths

      file_wavelengths = strarr(n_wavelengths)
      for e = 0L, n_wavelengths - 1L do begin
        file_wavelengths[e] = string(ucomp_getpar(ext_headers[e], 'WAVELNG'), $
                                     format='(F0.3)')
      endfor

      matching_indices = where(file_wavelengths eq all_wavelengths[w], n_matches)
      case n_matches of
        0L:
        1L: begin
            mean_wavelength_data[*, *, *, f] = ext_data[*, *, *, matching_indices[0]]
            median_wavelength_data[*, *, *, f] = ext_data[*, *, *, matching_indices[0]]
            sum2_wavelength_data[*, *, *, f] = (ext_data[*, *, *, matching_indices[0]])^2
            mean_background_data[*, *, f] = ext_background_data[*, *, matching_indices[0]]
            median_background_data[*, *, f] = ext_background_data[*, *, matching_indices[0]]
            sum2_background_data[*, *, f] = (ext_background_data[*, *, matching_indices[0]])^2
            if (f eq 0L) then begin
              averaged_headers->add, ext_headers[matching_indices[0]]
              averaged_background_headers->add, background_headers[matching_indices[0]]
            endif
          end
        else: begin
            mean_wavelength_data[*, *, *, f] = mean(ext_data[*, *, *, matching_indices], $
                                               dimension=4, /nan)
            median_wavelength_data[*, *, *, f] = median(ext_data[*, *, *, matching_indices], $
                                                dimension=4)
            sum2_wavelength_data[*, *, *, f] = total((ext_data[*, *, *, matching_indices])^2, $
                                                     4, /nan, /preserve_type)
            mean_background_data[*, *, f] = mean(ext_background_data[*, *, matching_indices], $
                                            dimension=3, /nan)
            median_background_data[*, *, f] = median(ext_background_data[*, *, matching_indices], $
                                            dimension=3)
            sum2_background_data[*, *, f] = total((ext_background_data[*, *, matching_indices])^2, $
                                                  3, /nan, /preserve_type)
            if (f eq 0L) then begin
              averaged_headers->add, ext_headers[matching_indices[0]]
              averaged_background_headers->add, background_headers[matching_indices[0]]
            endif
          end
      endcase

      obj_destroy, [ext_headers, background_headers]
    endfor

    ; TODO: need to average SGS values also
    ;   How should they be averaged?
    ;     - SGS values are by extension in the level 0 file
    ;     - should level 1 files average them to the primary header?
    ;     - if so, average files could just average primary header
    ;     - if not, produce SGS averages of each wavelength?

    first_primary_header = headfits(ok_files[0])
    last_primary_header = headfits(ok_files[-1])

    ucomp_addpar, primary_header, 'DATE-OBS', $
                  ucomp_getpar(first_primary_header, 'DATE-OBS')
    ucomp_addpar, primary_header, 'DATE-END', $
                  ucomp_getpar(last_primary_header, 'DATE-END'), $
                  comment='[UT] date/time when obs ended', $
                  after='DATE-OBS'
    ucomp_addpar, primary_header, 'NUMWAVE', n_unique_wavelengths
    ucomp_addpar, primary_header, 'NUMFILES', n_ok_files, $
                  comment='number of level 1 files averaged', $
                  after='NUMBEAM'

    if (size(mean_wavelength_data, /n_dimensions) gt 3L) then begin
      mean_averaged_data[*, *, *, w] = mean(mean_wavelength_data, dimension=4, /nan)
      mean_averaged_background[*, *, w] = mean(mean_background_data, dimension=3, /nan)
      median_averaged_data[*, *, *, w] = median(median_wavelength_data, dimension=4)
      median_averaged_background[*, *, w] = median(median_background_data, dimension=3)
      sigma_data[*, *, *, w] = mean(mean_wavelength_data, dimension=4, /nan)
      sigma_background[*, *, w] = mean(mean_background_data, dimension=3, /nan)
      sum2_data[*, *, *, w] = total(sum2_wavelength_data, 4, /nan, /preserve_type)
      sum2_background[*, *, w] = total(sum2_background_data, 3, /nan, /preserve_type)
    endif else begin
      mean_averaged_data[*, *, *, w] = mean_wavelength_data
      mean_averaged_background[*, *, w] = mean_background_data
      median_averaged_data[*, *, *, w] = median_wavelength_data
      median_averaged_background[*, *, w] = median_background_data
      sum2_data[*, *, *, w] = sum2_wavelength_data
      sum2_background[*, *, w] = sum2_background_data
    endelse
  endfor

  sigma_data = sqrt(sum2_data / double(n_ok_files) - mean_averaged_data^2)
  sigma_background = sqrt(sum2_background / double(n_ok_files) - mean_averaged_background^2)

  n_methods = n_elements(output_filenames)
  for m = 0, n_methods - 1L do begin
    output_filename = output_filenames[m]
    case m of
      0: begin
          averaged_data = mean_averaged_data
          averaged_background = mean_background_data
        end
      1: begin
          averaged_data = median_averaged_data
          averaged_background = median_background_data
        end
      2: begin
          averaged_data = sigma_data
          averaged_background = sigma_background
        end
    endcase

    mg_log, 'writing %s...', file_basename(output_filenames[m]), name=logger_name, /info
    ucomp_write_fits_file, output_filenames[0], $
                          primary_header, $
                          averaged_data, $
                          averaged_headers, $
                          averaged_background, $
                          averaged_background_headers

    wave_region = ucomp_getpar(primary_header, 'FILTER')
    occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

    if (obj_valid(run)) then begin
      ucomp_write_iquv_image, averaged_data, $
                              file_basename(output_filenames[m]), $
                              wave_region, $
                              float(all_wavelengths), $
                              occulter_radius=occulter_radius, $
                              /daily, sigma=m eq 2, $
                              run=run
  
      post_angle = ucomp_getpar(primary_header, 'POST_ANG')
      p_angle = ucomp_getpar(primary_header, 'SOLAR_P0')
      ucomp_write_all_iquv_image, averaged_data, $
                                  file_basename(output_filenames[m]), $
                                  wave_region, $
                                  float(all_wavelengths), $
                                  occulter_radius, $
                                  post_angle, $
                                  p_angle, $
                                  /daily, sigma=m eq 2, $
                                  run=run
    endif
  endfor

  obj_destroy, [averaged_headers, averaged_background_headers]

  done:
end
