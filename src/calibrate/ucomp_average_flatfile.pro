; docformat = 'rst'

;+
; Average similar flat extensions in a flat file.
;
; :Params:
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
;-
pro ucomp_average_flatfile, ext_data, ext_headers, n_extensions=n_extensions
  compile_opt strictarr

  n_extensions = n_elements(ext_headers)

  exptime    = fltarr(n_extensions)
  onband     = bytarr(n_extensions)
  wavelength = fltarr(n_extensions)

  ; group by EXPTIME, ONBAND, WAVELNG
  for e = 0L, n_extensions - 1L do begin
    exptime[e]    = ucomp_getpar(ext_headers[e], 'EXPTIME')
    onband[e]     = ucomp_getpar(ext_headers[e], 'ONBAND') eq 'rcam'
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
  new_dims = dims
  new_dims[-1] = n_groups
  new_ext_data = make_array(dimension=new_dims, type=type)

  ext_headers_array = ext_headers->toArray()
  ext_headers->remove, /all

  i = 0L
  for g = 0L, n_groups - 1L do begin
    count = group_starts[g + 1] - group_starts[g]

    d = ext_data[*, *, *, *, group_indices[group_starts[g]:group_starts[g+1] - 1]]
    new_ext_data[*, *, *, *, g] =  size(d, /n_dimensions) lt 5 ? d : mean(d, dimension=5)

    new_header = ext_headers_array[*, group_indices[group_starts[g]]]
    ; TODO: modify new_header
    ext_headers->add, new_header

    i += count
  endfor

  n_extensions = n_groups
  ext_data = new_ext_data
end


; main-level example file

;basename = '20210611.004555.70.ucomp.1083.l0.fts'
basename = '20210611.003802.17.ucomp.789.l0.fts'
root = '/hao/dawn/Data/UCoMP/incoming/20210610'
filename = filepath(basename, root=root)
ucomp_read_raw_data, filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     n_extensions=n_extensions
ext_data = float(ext_data)
help, ext_data, ext_headers
ucomp_average_flatfile, ext_data, ext_headers
help, ext_data, ext_headers

end
