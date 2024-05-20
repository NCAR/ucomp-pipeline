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
