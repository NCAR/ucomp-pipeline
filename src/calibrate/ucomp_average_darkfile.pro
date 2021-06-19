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
pro ucomp_average_darkfile, primary_header, ext_data, ext_headers, $
                            n_extensions=n_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode
  compile_opt strictarr

  n_extensions = n_elements(ext_headers)

  exptime    = fltarr(n_extensions)
  gain_mode  = bytarr(n_extensions) + (ucomp_getpar(primary_header, 'GAIN') eq 'high')

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
  new_dims = dims
  if (n_elements(dims) ge 5) then new_dims[-1] = n_groups
  new_ext_data = make_array(dimension=new_dims, type=type)

  ext_headers_array = ext_headers->toArray(/transpose)
  ext_headers->remove, /all

  averaged_exptime    = fltarr(n_groups)
  averaged_gain_mode  = bytarr(n_groups)
  extensions          = strarr(n_groups)

  i = 0L
  for g = 0L, n_groups - 1L do begin
    count = group_starts[g + 1] - group_starts[g]
    gi = group_indices[group_starts[g]:group_starts[g+1] - 1]

    d = ext_data[*, *, *, *, gi]
    new_ext_data[*, *, *, *, g] = size(d, /n_dimensions) lt 5 ? d : mean(d, dimension=5)

    averaged_exptime[g]    = exptime[gi[0]]
    averaged_gain_mode[g]  = gain_mode[gi[0]]

    extensions[g] = strjoin(strtrim(gi + 1L, 2), ',')

    ; grab first header of a group to use as header for the entire group
    averaged_header = ext_headers_array[*, gi[0]]
    ucomp_addpar, averaged_header, 'RAWFILE', '', comment='raw dark file'
    ucomp_addpar, averaged_header, 'RAWEXTS', extensions[g], after='RAWFILE', $
                  comment='extensions used from RAWFILE'
    ext_headers->add, averaged_header
  
    i += count
  endfor
  
  n_extensions = n_groups
  ext_data = reform(new_ext_data, new_dims)
end


; main-level example file

;basename = '20210611.010332.47.ucomp.l0.fts'
basename = '20210601.192244.64.ucomp.l0.fts'
;root = '/hao/dawn/Data/UCoMP/incoming/20210610'
root = '/hao/dawn/Data/UCoMP/incoming/20210601'
filename = filepath(basename, root=root)
ucomp_read_raw_data, filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     n_extensions=n_extensions
ext_data = float(ext_data)
help, ext_data, ext_headers
ucomp_average_darkfile, primary_header, ext_data, ext_headers, $
                        n_extensions=n_extensions, $
                        exptime=averaged_exptime, $
                        gain_mode=averaged_gain_mode
help, ext_data, ext_headers, n_extensions
help, averaged_exptime
print, averaged_exptime
help, averaged_gain_mode
print, averaged_gain_mode

end
