; docformat = 'rst'

;+
; Average similar dark extensions in a dark file.
;
; :Params:
;   primary_header : in, required, type=strarr
;     primary header for the flat file
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol, n_cameras, n)"
;     data to average where n is the number of extensions on input, and the
;     number of unique types of flats in the file on exit
;   ext_headers : in, required, type=list
;     list of extension headers, `strarr` variables
;
; :Keywords:
;   n_extensions : out, optional, type=long
;     set to a named variable to retrieve the new number of extensions after
;     averaging
;   exptime : out, optional, type=fltarr(n_extensions)
;     exposure times for the new averaged extensions
;   gain_mode : out, optional, type=bytarr(n_extensions)
;     gain modes for the new averaged extensions
;   nuc : out, optional, type=lonarr(n_extensions)
;     set to a named variable to retreive the "NUC" value for the averaged
;     extensions
;-
pro ucomp_average_darkfile, primary_header, ext_data, ext_headers, $
                            n_extensions=n_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode, $
                            nuc=averaged_nuc, $
                            run=run
  compile_opt strictarr

  n_extensions = n_elements(ext_headers)

  exptime    = fltarr(n_extensions)
  gain_mode  = bytarr(n_extensions) + (ucomp_getpar(primary_header, 'GAIN') eq 'high')

  rcam_nuc = ucomp_getpar(primary_header, 'RCAMNUC')
  tcam_nuc = ucomp_getpar(primary_header, 'TCAMNUC')
  if (rcam_nuc ne tcam_nuc) then begin
    ; TODO: fail here
  endif

  ; group by EXPTIME
  for e = 0L, n_extensions - 1L do begin
    exptime[e] = ucomp_getpar(ext_headers[e], 'EXPTIME')
  endfor

  ext_ids = string(exptime, format='(%"%0.1f")') + '-' + strtrim(fix(gain_mode), 2)

  group_indices = mg_groupby(ext_ids, $
                             n_groups=n_groups, $
                             group_starts=group_starts)

  dims = size(ext_data, /dimensions)
  type = size(ext_data, /type)
  averaged_dims = dims
  if (n_elements(dims) ge 5) then averaged_dims[-1] = n_groups
  averaged_ext_data = make_array(dimension=averaged_dims, type=4)

  ext_headers_array = ext_headers->toArray(/transpose)
  ext_headers->remove, /all

  averaged_exptime    = fltarr(n_groups)
  averaged_gain_mode  = bytarr(n_groups)
  nuc_values          = run->epoch('nuc_values')
  averaged_nuc        = lonarr(n_groups) + ucomp_nuc2index(rcam_nuc, values=nuc_values)
  extensions          = strarr(n_groups)

  for g = 0L, n_groups - 1L do begin
    count = group_starts[g + 1] - group_starts[g]
    gi = group_indices[group_starts[g]:group_starts[g+1] - 1]

    d = ext_data[*, *, *, *, gi]
    averaged_ext_data[*, *, *, *, g] = size(d, /n_dimensions) lt 5 ? d : mean(d, dimension=5, /nan)

    averaged_exptime[g]    = exptime[gi[0]]
    averaged_gain_mode[g]  = gain_mode[gi[0]]

    extensions[g] = strjoin(strtrim(gi + 1L, 2), ',')

    ; grab first header of a group to use as header for the entire group
    averaged_header = ucomp_combine_headers(ext_headers_array[*, gi])
    ucomp_addpar, averaged_header, 'RAWFILE', '', comment='raw dark file'
    ucomp_addpar, averaged_header, 'RAWEXTS', extensions[g], after='RAWFILE', $
                  comment='extension(s) used from RAWFILE'
    ext_headers->add, averaged_header
  endfor

  n_extensions = n_groups
  ext_data = reform(averaged_ext_data, averaged_dims)
end
