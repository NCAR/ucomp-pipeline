; docformat = 'rst'

;+
; Read the density ratio file produced by Chianti.
;
; :Returns:
;   ratios array `fltarr(n_densities, n_heights)`
;
; :Params:
;   density_filename : in, required, type=string
;     filename of density ratio, either `.sav` or `.nc`
;
; :Keywords:
;   heights : out, optional, type=fltarr(n_heights)
;     set to a named variable to retrieve the heights array
;   densities : out, optional, type=fltarr(n_densities)
;     set to a named variable to retrieve the densities array
;   chianti_version : out, optional, type=string
;     set to a named variable to retrieve the Chianti version that was used to
;     produce the file
;   inverted_ratio : out, optional, type=boolean
;     set to a named variable to retrieve whether the ratios are inverted
;-
function ucomp_read_density_ratio, density_filename, $
                                   heights=heights, $
                                   densities=densities, $
                                   chianti_version=chianti_version, $
                                   inverted_ratio=inverted_ratio
  compile_opt strictarr
  ; on_error, 2

  ext_pos = strpos(density_filename, '.', /reverse_search)
  ext = strmid(density_filename, ext_pos)

  case ext of
    '.nc' : begin
        heights = mg_nc_getdata(density_filename, 'h')
        densities = mg_nc_getdata(density_filename, 'den')
        ratios = mg_nc_getdata(density_filename, 'rat')
        chianti_version = mg_nc_getdata(density_filename, '.chianti_version')
        inverted_ratio = 0B
        return, ratios
      end
    '.sav' : begin
        restore, filename=density_filename
        heights = h
        densities = 10^den
        chianti_version = ''
        inverted_ratio = 1B
        return, transpose(ratio_array)
      end
    else: message, 'unknown density file extension'
  endcase
end


; main-level example program

density_basename = 'rat.sav'
density_filename = filepath(density_basename, $
                            subdir=['..', '..', 'resource', 'density'], $
                            root=mg_src_root())

morton_ratios = ucomp_read_density_ratio(density_filename, $
                                         heights=morton_heights, $
                                         densities=morton_densities, $
                                         chianti_version=morton_chianti_version, $
                                         inverted_ratio=morton_inverted_ratio)

density_basename = 'chianti_v10.1_pycelp_fe13_h99_d120_ratio.nc'
density_filename = filepath(density_basename, $
                            subdir=['..', '..', 'resource', 'density'], $
                            root=mg_src_root())
ratios = ucomp_read_density_ratio(density_filename, $
                                  heights=heights, $
                                  densities=densities, $
                                  chianti_version=chianti_version, $
                                  inverted_ratio=inverted_ratio)

end
