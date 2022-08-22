; docformat = 'run'

function ucomp_quality_dark_values, file, $
                                    primary_header, $
                                    ext_data, $
                                    ext_headers, $
                                    run=run
  compile_opt strictarr

  is_dark = strtrim(ucomp_getpar(ext_headers[0], 'DATATYPE'), 2) eq 'dark'
  if (~is_dark) then return, 0UL

  quality_rcam_dark_range = run->epoch('quality_rcam_dark_range')
  quality_tcam_dark_range = run->epoch('quality_tcam_dark_range')

  dims = size(ext_data, /dimensions)

  r_outer = run->epoch('field_radius')
  field_mask = ucomp_field_mask(dims[0], dims[1], r_outer)
  field_mask_indices = where(field_mask, /null)

  rcam_mean = mean(mean(reform(ext_data[*, *, *, 0, *]), dimension=3), dimension=3)
  tcam_mean = mean(mean(reform(ext_data[*, *, *, 0, *]), dimension=3), dimension=3)

  rcam_median = median(rcam_mean[field_mask_indices])
  tcam_median = median(tcam_mean[field_mask_indices])

  if (rcam_median lt quality_rcam_dark_range[0] $
        || rcam_median gt quality_rcam_dark_range[1]) then begin
    return, 1UL
  endif

  if (tcam_median lt quality_tcam_dark_range[0] $
        || tcam_median gt quality_tcam_dark_range[1]) then begin
    return, 1UL
  endif

  return, 0UL
end
