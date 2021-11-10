; docformat = 'rst'

;+
; Perform off-band (continuum) subtraction.
;
; After `UCOMP_L1_AVERAGE_DATA`, there should be only a single match for each
; extension.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_continuum_subtraction, file, primary_header, ext_data, ext_headers, $
                                    run=run, status=status
  compile_opt strictarr

  status = 0L

  ; find extensions with matching wavelengths and opposite ONBAND
  n_extensions = n_elements(ext_headers)

  exptime    = fltarr(n_extensions)
  onband     = bytarr(n_extensions)
  wavelength = fltarr(n_extensions)
  raw_exts   = strarr(n_extensions)

  ; group by EXPTIME, ONBAND, WAVELNG
  for e = 0L, n_extensions - 1L do begin
    exptime[e]    = ucomp_getpar(ext_headers[e], 'EXPTIME')
    onband[e]     = ucomp_getpar(ext_headers[e], 'ONBAND') eq 'tcam'
    wavelength[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
    raw_exts[e]   = ucomp_getpar(ext_headers[e], 'RAWEXTS')
  endfor

  ; because we have already averaged the file, we can assume there are only
  ; two extensions with the same wavelength, with opposite ONBAND values

  ; ID for each extension
  ext_ids = string(exptime, format='(%"%0.1f")') $
              + '-' + strtrim(fix(onband), 2) $
              + '-' + string(wavelength, format='(%"%0.2f")')

  ; ID for match
  match_ids = string(exptime, format='(%"%0.1f")') $
                + '-' + strtrim(fix(onband eq 0), 2) $   ; opposite ONBAND
                + '-' + string(wavelength, format='(%"%0.2f")')

  n_matches = mg_match(ext_ids, match_ids, b_matches=match_indices)
  if (n_matches ne n_extensions) then begin
    message, 'matches not found for all extensions'
    status = 1L
    goto, done
  endif

  dims = size(ext_data, /dimensions)
  type = size(ext_data, /type)

  combined_dims = [dims[0:3], dims[4] / 2L]
  combined_ext_data = make_array(dimension=combined_dims, type=type)
  ext_headers_array = ext_headers->toArray(/transpose)
  ext_headers->remove, /all

  matched = bytarr(n_matches)
  i = 0L
  for m = 0L, n_matches - 1L do begin
    if (matched[m]) then continue

    ; combine index m and index match_indices[m]
    if (run->line(file.wave_region, 'subtract_continuum')) then begin
      if (onband[m]) then begin
        c0 = [-1.0, 1.0]
        c1 = [1.0, -1.0]
      endif else begin
        c0 = [1.0, -1.0]
        c1 = [-1.0, 1.0]
      endelse
    endif else begin
      mg_log, 'skipping continuum subtraction for %s file', file.wave_region, $
              name=run.logger_name, /debug
      if (onband[m]) then begin
        c0 = [0.0, 1.0]
        c1 = [1.0, 0.0]
      endif else begin
        c0 = [1.0, 0.0]
        c1 = [0.0, 1.0]
      endelse
    endelse

    mg_log, 'ext %d cam 0: %d ext %d + %d ext %d', $
            i + 1L, c0[0], m, c0[1], match_indices[m], $
            name=run.logger_name, /debug
    mg_log, 'ext %d cam 1: %d ext %d + %d ext %d', $
            i + 1L, c1[0], m, c1[1], match_indices[m], $
            name=run.logger_name, /debug

    ; note: in the following code, cam0 is not necessarily RCAM, cam1 is not
    ; necessarily TCAM
    cam0 = c0[0] * ext_data[*, *, *, 0, m] + c0[1] * ext_data[*, *, *, 0, match_indices[m]]
    cam1 = c1[0] * ext_data[*, *, *, 1, m] + c1[1] * ext_data[*, *, *, 1, match_indices[m]]
    combined_ext_data[*, *, *, 0, i] = cam0
    combined_ext_data[*, *, *, 1, i] = cam1

    i += 1L

    header = reform(ext_headers_array[*, m])
    sxdelpar, header, 'ONBAND'
    ucomp_addpar, header, 'RAWEXTS', raw_exts[m] + ',' + raw_exts[match_indices[m]]
    ext_headers->add, header

    matched[m] = 1B
    matched[match_indices[m]] = 1B
  endfor

  ext_data = combined_ext_data

  file.n_extensions = n_elements(ext_headers)
  file.wavelength = wavelength[match_indices]
  file.onband_indices = !null

  done:
end
