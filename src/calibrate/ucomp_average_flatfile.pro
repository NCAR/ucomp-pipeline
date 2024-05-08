; docformat = 'rst'

;+
; Average similar flat extensions in a flat file.
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
;     set to a named variable to retrieve the "EXPTIME" value for the averaged
;     extensions
;   gain_mode : out, optional, type=bytarr(n_extensions)
;     set to a named variable to retrieve the "GAIN" value for the averaged
;     extensions where "low" = 0 and "high" = 1
;   onband : out, optional, type=bytarr(n_extensions)
;     set to a named variable to retrieve the "ONBAND" value for the averaged
;     extensions where "rcam" = 0 and "tcam" = 1
;   wavelength : out, optional, type=fltarr(n_extensions)
;     set to a named variable to retrieve the "WAVELNG" value for the averaged
;     extensions
;-
pro ucomp_average_flatfile, primary_header, ext_data, ext_headers, $
                            n_extensions=n_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode, $
                            onband=averaged_onband, $
                            sgsdimv=averaged_sgsdimv, $
                            wavelength=averaged_wavelength
  compile_opt strictarr

  n_extensions = n_elements(ext_headers)

  exptime    = fltarr(n_extensions)
  gain_mode  = bytarr(n_extensions) + (ucomp_getpar(primary_header, 'GAIN') eq 'high')
  onband     = bytarr(n_extensions)
  sgsdimv    = fltarr(n_extensions)
  wavelength = fltarr(n_extensions)

  ; group by EXPTIME, ONBAND, WAVELNG
  for e = 0L, n_extensions - 1L do begin
    exptime[e]    = ucomp_getpar(ext_headers[e], 'EXPTIME')
    onband[e]     = ucomp_getpar(ext_headers[e], 'ONBAND') eq 'tcam'
    wavelength[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
    sgsdimv[e]    = ucomp_getpar(ext_headers[e], 'SGSDIMV')
  endfor

  ext_ids = string(exptime, format='(%"%0.1f")') $
              + '-' + strtrim(fix(onband), 2) $
              + '-' + string(wavelength, format='(%"%0.3f")')
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
  averaged_onband     = bytarr(n_groups)
  averaged_sgsdimv    = fltarr(n_groups)
  averaged_wavelength = fltarr(n_groups)
  extensions          = strarr(n_groups)

  for g = 0L, n_groups - 1L do begin
    count = group_starts[g + 1] - group_starts[g]
    gi = group_indices[group_starts[g]:group_starts[g+1] - 1]

    d = ext_data[*, *, *, *, gi]
    averaged_ext_data[*, *, *, *, g] =  size(d, /n_dimensions) lt 5 ? d : mean(d, dimension=5, /nan)

    averaged_exptime[g]    = exptime[gi[0]]
    averaged_gain_mode[g]  = gain_mode[gi[0]]
    averaged_onband[g]     = onband[gi[0]]
    averaged_wavelength[g] = wavelength[gi[0]]

    extensions[g] = strjoin(strtrim(gi + 1L, 2), ',')

    ; grab first header of a group to use as header for the entire group
    averaged_header = ucomp_combine_headers(ext_headers_array[*, gi])
    ucomp_addpar, averaged_header, 'RAWFILE', '', comment='raw flat file'
    ucomp_addpar, averaged_header, 'RAWEXTS', extensions[g], after='RAWFILE', $
                  comment='extension(s) used from RAWFILE'
    averaged_sgsdimv[g] = ucomp_getpar(averaged_header, 'SGSDIMV')
    ext_headers->add, averaged_header
  endfor

  n_extensions = n_groups

  ext_data = reform(averaged_ext_data, averaged_dims)
end


; main-level example file

basename = '20210611.004555.70.ucomp.1083.l0.fts'
;basename = '20210611.003802.17.ucomp.789.l0.fts'
;basename = '20210601.191956.56.ucomp.1083.l0.fts'
root = '/hao/dawn/Data/UCoMP/incoming/20210610'
;root = '/hao/dawn/Data/UCoMP/incoming/20210601'
filename = filepath(basename, root=root)
ucomp_read_raw_data, filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     n_extensions=n_extensions
ext_data = float(ext_data)
help, ext_data, ext_headers
ucomp_average_flatfile, primary_header, ext_data, ext_headers
help, ext_data, ext_headers

end
