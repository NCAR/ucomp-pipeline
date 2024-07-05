; docformat = 'rst'

;+
; Check flat median is in nominal range.
;
; :Returns:
;   1B if the flat median is not in the nominal range.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_flat_thresholds, file, $
                                        primary_header, ext_data, ext_headers, $
                                        run=run
  compile_opt strictarr

  ; only check flats
  is_flat = strtrim(ucomp_getpar(ext_headers[0], 'DATATYPE'), 2) eq 'flat'
  if (~is_flat) then return, 0UL

  rcam_onband_flat_range  = run->line(file.wave_region, $
                                      'rcam_onband_flat_range', $
                                      found=ron_found)
  rcam_offband_flat_range = run->line(file.wave_region, $
                                      'rcam_offband_flat_range', $
                                      found=roff_found)
  tcam_onband_flat_range  = run->line(file.wave_region, $
                                      'tcam_onband_flat_range', $
                                      found=ton_found)
  tcam_offband_flat_range = run->line(file.wave_region, $
                                      'tcam_offband_flat_range', $
                                      found=toff_found)

  if (~ron_found || ~roff_found || ~ton_found || ~toff_found) then begin
    return, 0UL
  endif

  dims = size(ext_data, /dimensions)
  annulus = ucomp_annulus(375, 600, dimensions=dims[0:1])
  post_mask = ucomp_post_mask(dims[0:1], 180.0)
  mask = annulus and post_mask
  mask_indices = where(mask)

  n_polstates = dims[2]
  n_cameras = dims[3]

  medians = fltarr(n_polstates, n_cameras)

  for f = 0L, n_elements(ext_headers) - 1L do begin
    for c = 0L, n_cameras - 1L do begin
      for p = 0L, n_polstates - 1L do begin
        im = reform(ext_data[*, *, p, c, f])
        medians[p, c] = median(im[mask_indices])
      endfor
    endfor

    ; should be just two values
    means = mean(medians, 1)

    onband = strtrim(ucomp_getpar(ext_headers[f]), 2)
    if (strlowcase(onband) eq 'rcam') then begin
      if (means[0] lt rcam_onband_flat_range[0]) then return, 1UL
      if (means[0] gt rcam_onband_flat_range[1]) then return, 1UL
      if (means[1] lt tcam_offband_flat_range[0]) then return, 1UL
      if (means[1] gt tcam_offband_flat_range[1]) then return, 1UL
    endif else begin
      if (means[0] lt rcam_offband_flat_range[0]) then return, 1UL
      if (means[0] gt rcam_offband_flat_range[1]) then return, 1UL
      if (means[1] lt tcam_onband_flat_range[0]) then return, 1UL
      if (means[1] gt tcam_onband_flat_range[1]) then return, 1UL
    endelse
  endfor

  return, 0UL
end
