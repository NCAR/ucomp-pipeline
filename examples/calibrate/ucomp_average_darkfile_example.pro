; main-level example file

basename = '20210611.010332.47.ucomp.l0.fts'
;basename = '20210601.192244.64.ucomp.l0.fts'
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
