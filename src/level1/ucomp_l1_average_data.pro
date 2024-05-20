; docformat = 'rst'

;+
; Average extension data in science file with same wavelength, exposure time,
; and ONBAND status.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol, n_camera, n)"
;     extension data, set to a named variable to average the data and reduce `n`
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;   backgrounds : type=undefined
;     not used in this step
;   background_headers : in, required, type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_average_data, file, $
                           primary_header, $
                           ext_data, ext_headers, $
                           backgrounds, background_headers, $
                           run=run, status=status
  compile_opt strictarr

  status = 0L

  n_extensions = n_elements(ext_headers)

  exptime     = fltarr(n_extensions)
  onband      = bytarr(n_extensions)
  continuum   = strarr(n_extensions)
  wavelengths = fltarr(n_extensions)

  ; group by EXPTIME, ONBAND, WAVELNG
  for e = 0L, n_extensions - 1L do begin
    exptime[e]     = ucomp_getpar(ext_headers[e], 'EXPTIME')
    onband[e]      = ucomp_getpar(ext_headers[e], 'ONBAND') eq 'tcam'
    continuum[e]   = ucomp_getpar(ext_headers[e], 'CONTIN')
    wavelengths[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
  endfor

  ext_ids = string(exptime, format='(%"%0.1f")') $
              + '-' + strtrim(fix(onband), 2) $
              + '-' + strtrim(continuum, 2) $
              + '-' + string(wavelengths, format='(%"%0.3f")')

  group_indices = mg_groupby(ext_ids, $
                             n_groups=n_groups, $
                             group_starts=group_starts)

  dims = size(ext_data, /dimensions)
  type = size(ext_data, /type)
  averaged_dims = dims
  if (n_elements(dims) ge 5) then averaged_dims[-1] = n_groups
  averaged_ext_data = make_array(dimension=averaged_dims, type=type)

  ext_headers_array = ext_headers->toArray(/transpose)
  ext_headers->remove, /all

  averaged_exptime     = fltarr(n_groups)
  averaged_onband      = bytarr(n_groups)
  averaged_wavelengths = fltarr(n_groups)
  extensions           = strarr(n_groups)

  for g = 0L, n_groups - 1L do begin
    count = group_starts[g + 1] - group_starts[g]
    gi = group_indices[group_starts[g]:group_starts[g+1] - 1]

    d = ext_data[*, *, *, *, gi]
    averaged_ext_data[*, *, *, *, g] = size(d, /n_dimensions) lt 5 $
                                         ? d $
                                         : mean(d, dimension=5, /nan)

    averaged_exptime[g]     = exptime[gi[0]]
    averaged_onband[g]      = onband[gi[0]]
    averaged_wavelengths[g] = wavelengths[gi[0]]

    extensions[g] = strjoin(strtrim(gi + 1L, 2), ',')

    ; grab first header of a group to use as header for the entire group
    averaged_header = ucomp_combine_headers(ext_headers_array[*, gi])
    ucomp_addpar, averaged_header, 'RAWFILE', $
                  file_basename(file.raw_filename), $
                  comment='raw file'
    ucomp_addpar, averaged_header, 'RAWEXTS', extensions[g], after='RAWFILE', $
                  comment='extension(s) used from RAWFILE'
    ext_headers->add, averaged_header
  endfor

  if (n_groups ne n_extensions) then begin
    mg_log, 'reduced file from %d to %d exts', n_extensions, n_groups, $
            name=run.logger_name, /debug
  endif

  file.n_extensions   = n_groups
  file.wavelengths    = averaged_wavelengths
  file.onband_indices = averaged_onband

  ext_data = reform(averaged_ext_data, averaged_dims)

  for p = 0L, averaged_dims[2] - 1L do begin
    for c = 0L, averaged_dims[3] - 1L do begin
      for e = 0L, n_groups - 1L do begin
        !null = where(finite(ext_data[*, *, p, c, e]) eq 1, n_non_nan)
        if (n_non_nan eq 0L) then begin
          status = 1L
          mg_log, 'polstate %d, camera %d, ext %d all NaNs', p, c, e, $
                  name=run.logger_name, /warn
        endif
      endfor
    endfor
  endfor
end
