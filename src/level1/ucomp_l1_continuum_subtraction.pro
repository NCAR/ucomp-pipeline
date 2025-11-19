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
;     extension data, cuts `n_exts` in half
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : out, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     backgrounds created in this step
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_continuum_subtraction, file, $
                                    primary_header, $
                                    ext_data, ext_headers, $
                                    backgrounds, background_headers, $
                                    run=run, status=status
  compile_opt strictarr

  status = 0L

  subtract_continuum = run->line(file.wave_region, 'subtract_continuum')

  ; find extensions with matching wavelengths and opposite ONBAND
  n_extensions = n_elements(ext_headers)

  exptime          = fltarr(n_extensions)
  onband           = bytarr(n_extensions)
  wavelength       = fltarr(n_extensions)
  raw_exts         = strarr(n_extensions)
  master_flat_ext1 = strarr(n_extensions)
  master_flat_ext2 = strarr(n_extensions)

  ; group by EXPTIME, ONBAND, WAVELNG
  for e = 0L, n_extensions - 1L do begin
    exptime[e]    = ucomp_getpar(ext_headers[e], 'EXPTIME')
    onband[e]     = ucomp_getpar(ext_headers[e], 'ONBAND') eq 'tcam'
    wavelength[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
    raw_exts[e]   = ucomp_getpar(ext_headers[e], 'RAWEXTS')

    master_flat_ext1[e]   = strtrim(ucomp_getpar(ext_headers[e], 'MFLTEXT1'), 2)
    mfe2 = ucomp_getpar(ext_headers[e], 'MFLTEXT2', found=found)
    master_flat_ext2[e]   = found ? strtrim(mfe2, 2) : ''
  endfor

  ; because we have already averaged the file, we can assume there are only
  ; two extensions with the same wavelength, with opposite ONBAND values

  ; ID for each extension
  ext_ids = string(exptime, format='(%"%0.1f")') $
              + '-' + strtrim(fix(onband), 2) $
              + '-' + string(wavelength, format='(%"%0.3f")')

  ; ID for match
  match_ids = string(exptime, format='(%"%0.1f")') $
                + '-' + strtrim(fix(onband eq 0), 2) $   ; opposite ONBAND
                + '-' + string(wavelength, format='(%"%0.3f")')

  n_matches = mg_match(ext_ids, match_ids, b_matches=match_indices)
  if (n_matches ne n_extensions) then begin
    message, 'matches not found for all extensions'
    status = 1L
    goto, done
  endif

  dims = size(ext_data, /dimensions)
  type = size(ext_data, /type)

  combined_dims = [dims[0:3], dims[4] / 2L]
  background_dims = [dims[0:3], dims[4] / 2L]   ; only I
  combined_ext_data = make_array(dimension=combined_dims, type=type)
  backgrounds       = make_array(dimension=background_dims, type=type)
  ext_headers_array = ext_headers->toArray(/transpose)
  ext_headers->remove, /all
  background_headers = list()

  matched = bytarr(n_matches)
  keep_wavelengths = fltarr(dims[4] / 2L)
  i = 0L
  for m = 0L, n_matches - 1L do begin
    if (matched[m]) then continue

    ; combine index m and index match_indices[m]
    if (subtract_continuum) then begin
      if (onband[m]) then begin
        c0 = [-1.0, 1.0]
        c1 = [1.0, -1.0]
        b  = [m, match_indices[m]]
        msg0 = string(m + 1L, match_indices[m] + 1L, format='(%"- ext %d + ext %d")')
        msg1 = string(m + 1L, match_indices[m] + 1L, format='(%"+ ext %d - ext %d")')
      endif else begin
        c0 = [1.0, -1.0]
        c1 = [-1.0, 1.0]
        b  = [match_indices[m], m]
        msg0 = string(m + 1L, match_indices[m] + 1L, format='(%"+ ext %d - ext %d")')
        msg1 = string(m + 1L, match_indices[m] + 1L, format='(%"- ext %d + ext %d")')
      endelse
    endif else begin
      mg_log, 'skipping continuum subtraction for %s file', file.wave_region, $
              name=run.logger_name, /debug
      if (onband[m]) then begin
        c0 = [0.0, 1.0]
        c1 = [1.0, 0.0]
        b  = [m, match_indices[m]]
        msg0 = string(match_indices[m] + 1L, format='(%"+ ext %d")')
        msg1 = string(m + 1L, format='(%"+ ext %d")')
      endif else begin
        c0 = [1.0, 0.0]
        c1 = [0.0, 1.0]
        b  = [match_indices[m], m]
        msg0 = string(m + 1L, format='(%"+ ext %d")')
        msg1 = string(match_indices[m] + 1L, format='(%"+ ext %d")')
      endelse
    endelse

    mg_log, 'ext %d cam 0: %s', i + 1L, msg0, name=run.logger_name, /debug
    mg_log, 'ext %d cam 1: %s', i + 1L, msg1, name=run.logger_name, /debug

    ; note: in the following code, cam0 is not necessarily RCAM, cam1 is not
    ; necessarily TCAM
    cam0 = c0[0] * ext_data[*, *, *, 0, m] + c0[1] * ext_data[*, *, *, 0, match_indices[m]]
    cam1 = c1[0] * ext_data[*, *, *, 1, m] + c1[1] * ext_data[*, *, *, 1, match_indices[m]]
    combined_ext_data[*, *, *, 0, i] = cam0
    combined_ext_data[*, *, *, 1, i] = cam1
    backgrounds[*, *, *, 0, i] = ext_data[*, *, *, 0, b[0]]
    backgrounds[*, *, *, 1, i] = ext_data[*, *, *, 1, b[1]]
    keep_wavelengths[i] = wavelength[match_indices[m]]

    i += 1L

    header = reform(ucomp_combine_headers(ext_headers_array[*, [m, match_indices[m]]]))

    sxdelpar, header, 'ONBAND'

    ucomp_addpar, header, 'MFLTEXT1', master_flat_ext1[m] + ',' + master_flat_ext1[match_indices[m]]
    if (master_flat_ext2[m] ne '' and master_flat_ext2[match_indices[m]] ne '') then begin
      ucomp_addpar, header, 'MFLTEXT2', master_flat_ext2[m] + ',' + master_flat_ext2[match_indices[m]]
    endif
    ucomp_addpar, header, 'RAWEXTS', raw_exts[m] + ',' + raw_exts[match_indices[m]]

    average_flat_median = (ucomp_getpar(ext_headers_array[*, m], 'FLATDN') $
                            + ucomp_getpar(ext_headers_array[*, match_indices[m]], 'FLATDN')) / 2.0
    ucomp_addpar, header, 'FLATDN', average_flat_median, format='(F0.2)'

    average_sky_transmission = (ucomp_getpar(ext_headers_array[*, m], 'SKYTRANS') $
                            + ucomp_getpar(ext_headers_array[*, match_indices[m]], 'SKYTRANS')) / 2.0
    ucomp_addpar, header, 'SKYTRANS', average_sky_transmission, format='(F0.5)'

    ext_headers->add, header
    background_headers->add, header

    matched[m] = 1B
    matched[match_indices[m]] = 1B
  endfor

  ext_data = combined_ext_data

  ucomp_addpar, primary_header, 'CONTSUB', boolean(subtract_continuum), $
                comment='whether the continuum was subtracted', $
                after='DISTORTF'

  file.n_extensions = n_elements(ext_headers)
  file.wavelengths = keep_wavelengths
  file.onband_indices = !null

  done:
end
