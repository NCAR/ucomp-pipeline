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
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_average_data, file, primary_header, ext_data, ext_headers, run=run
  compile_opt strictarr

  n_extensions = n_elements(ext_headers)

  exptime    = fltarr(n_extensions)
  onband     = bytarr(n_extensions)
  wavelength = fltarr(n_extensions)

  ; group by EXPTIME, ONBAND, WAVELNG
  for e = 0L, n_extensions - 1L do begin
    exptime[e]    = ucomp_getpar(ext_headers[e], 'EXPTIME')
    onband[e]     = ucomp_getpar(ext_headers[e], 'ONBAND') eq 'tcam'
    wavelength[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
  endfor

  ext_ids = string(exptime, format='(%"%0.1f")') $
              + '-' + strtrim(fix(onband), 2) $
              + '-' + string(wavelength, format='(%"%0.2f")')
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

  averaged_exptime    = fltarr(n_groups)
  averaged_onband     = bytarr(n_groups)
  averaged_wavelength = fltarr(n_groups)
  extensions          = strarr(n_groups)

  for g = 0L, n_groups - 1L do begin
    count = group_starts[g + 1] - group_starts[g]
    gi = group_indices[group_starts[g]:group_starts[g+1] - 1]

    d = ext_data[*, *, *, *, gi]
    averaged_ext_data[*, *, *, *, g] =  size(d, /n_dimensions) lt 5 ? d : mean(d, dimension=5)

    averaged_exptime[g]    = exptime[gi[0]]
    averaged_onband[g]     = onband[gi[0]]
    averaged_wavelength[g] = wavelength[gi[0]]

    extensions[g] = strjoin(strtrim(gi + 1L, 2), ',')

    ; grab first header of a group to use as header for the entire group
    averaged_header = ext_headers_array[*, gi[0]]
    ucomp_addpar, averaged_header, 'RAWFILE', '', comment='raw file'
    ucomp_addpar, averaged_header, 'RAWEXTS', extensions[g], after='RAWFILE', $
                  comment='extensions used from RAWFILE'
    ext_headers->add, averaged_header
  endfor

  if (n_groups ne n_extensions) then begin
    mg_log, 'reduced file from %s to %d exts', n_extensions, n_groups, $
            name=run.logger_name, /debug
  endif

  n_extensions = n_groups
  file.n_extensions = n_extensions

  ext_data = reform(averaged_ext_data, averaged_dims)
end
