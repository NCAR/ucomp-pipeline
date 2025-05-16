; docformat = 'rst'

;+
; Check whether any extensions have a datatype that does not match the others.
;
; :Returns:
;   1B if any extensions don't have a matching datatype
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
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
function ucomp_quality_saturated, file, $
                                  primary_header, $
                                  ext_data, $
                                  ext_headers, $
                                  run=run
  compile_opt strictarr

  n_dims = size(ext_data, /n_dimensions)

  saturated_threshold = 4094.0
  nonlinear_threshold = 3000.0

  rcam_indices = where(file.onband_indices eq 0L, n_rcam_indices)
  tcam_indices = where(file.onband_indices eq 1L, n_tcam_indices)

  if (n_dims gt 4L and n_rcam_indices gt 0L) then begin
    rcam_data = ext_data[*, *, *, *, rcam_indices]
    if (size(rcam_data, /n_dimensions) gt 4) then begin
      rcam_onband_maximums = max(rcam_data, dimension=5)
    endif else begin
      rcam_onband_maximums = rcam_data
    endelse

    nonlinear_mask = reform(long(rcam_data[*, *, *, 0, *] gt nonlinear_threshold))
    dims = size(nonlinear_mask, /dimensions)
    nonlinear_mask = reform(nonlinear_mask, dims[0] * dims[1], dims[2] * dims[3])
    file.max_n_rcam_nonlinear_pixels_by_frame = max(total(nonlinear_mask, 1))

    rcam_onband_maximums = max(rcam_onband_maximums, dimension=3)

    !null = where(rcam_onband_maximums[*, *, 0] gt saturated_threshold, n_rcam_onband_saturated_pixels)
    !null = where(rcam_onband_maximums[*, *, 1] gt saturated_threshold, n_tcam_bkg_saturated_pixels)
    !null = where(rcam_onband_maximums[*, *, 0] gt nonlinear_threshold, n_rcam_onband_nonlinear_pixels)
    !null = where(rcam_onband_maximums[*, *, 1] gt nonlinear_threshold, n_tcam_bkg_nonlinear_pixels)
  endif

  if (n_dims gt 4L and n_tcam_indices gt 0L) then begin
    tcam_data = ext_data[*, *, *, *, tcam_indices]
    if (size(tcam_data, /n_dimensions) gt 4) then begin
      tcam_onband_maximums = max(tcam_data, dimension=5)
    endif else begin
      tcam_onband_maximums = tcam_data
    endelse

    nonlinear_mask = reform(long(tcam_data[*, *, *, 1, *] gt nonlinear_threshold))
    dims = size(nonlinear_mask, /dimensions)
    nonlinear_mask = reform(nonlinear_mask, dims[0] * dims[1], dims[2] * dims[3])
    file.max_n_tcam_nonlinear_pixels_by_frame = max(total(nonlinear_mask, 1))

    tcam_onband_maximums = max(tcam_onband_maximums, dimension=3)

    !null = where(tcam_onband_maximums[*, *, 1] gt saturated_threshold, n_tcam_onband_saturated_pixels)
    !null = where(tcam_onband_maximums[*, *, 0] gt saturated_threshold, n_rcam_bkg_saturated_pixels)
    !null = where(tcam_onband_maximums[*, *, 1] gt nonlinear_threshold, n_tcam_onband_nonlinear_pixels)
    !null = where(tcam_onband_maximums[*, *, 0] gt nonlinear_threshold, n_rcam_bkg_nonlinear_pixels)
  endif

  file.n_rcam_onband_saturated_pixels = n_rcam_onband_saturated_pixels
  file.n_tcam_onband_saturated_pixels = n_tcam_onband_saturated_pixels
  file.n_rcam_bkg_saturated_pixels    = n_rcam_bkg_saturated_pixels
  file.n_tcam_bkg_saturated_pixels    = n_tcam_bkg_saturated_pixels
  file.n_rcam_onband_nonlinear_pixels = n_rcam_onband_nonlinear_pixels
  file.n_tcam_onband_nonlinear_pixels = n_tcam_onband_nonlinear_pixels
  file.n_rcam_bkg_nonlinear_pixels    = n_rcam_bkg_nonlinear_pixels
  file.n_tcam_bkg_nonlinear_pixels    = n_tcam_bkg_nonlinear_pixels

  ; TODO: always pass while we collect statistics
  return, 0UL
end
