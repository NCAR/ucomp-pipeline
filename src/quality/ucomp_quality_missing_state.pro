; docformat = 'rst'

;+
; Check whether required states (depending on whether flat or dark) are not all
; NaN from removing bad frames.
;
; :Returns:
;   1B if the file is missing a state
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
function ucomp_quality_missing_state, file, $
                                      primary_header, $
                                      ext_data, $
                                      ext_headers, $
                                      run=run
  compile_opt strictarr

  is_dark = strtrim(ucomp_getpar(ext_headers[0], 'DATATYPE'), 2) eq 'dark'
  is_flat = strtrim(ucomp_getpar(ext_headers[0], 'DATATYPE'), 2) eq 'flat'

  missing = 0B

  if (is_flat) then begin
    tmp_ext_data = ext_data
    tmp_ext_headers = list(ext_headers, /extract)
    ucomp_average_flatfile, primary_header, tmp_ext_data, tmp_ext_headers, $
                            n_extensions=n_averaged_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode, $
                            onband=averaged_onband, $
                            sgsdimv=averaged_sgsdimv, $
                            wavelength=averaged_wavelength
    obj_destroy, tmp_ext_headers

    for e = 0L, n_averaged_extensions - 1L do begin
      rcam = reform(mean(tmp_ext_data[*, *, *, 0, e], dimension=3, /nan))
      tcam = reform(mean(tmp_ext_data[*, *, *, 1, e], dimension=3, /nan))
      if (total(finite(rcam), /integer) eq 0L) then missing = 1B
      if (total(finite(tcam), /integer) eq 0L) then missing = 1B
    endfor
  endif

  if (is_dark) then begin
    tmp_ext_data = ext_data
    tmp_ext_headers = list(ext_headers, /extract)
    ucomp_average_darkfile, primary_header, ext_data, ext_headers, $
                            n_extensions=n_averaged_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode
    obj_destroy, tmp_ext_headers

    for e = 0L, n_averaged_extensions - 1L do begin
      rcam = reform(mean(tmp_ext_data[*, *, *, 0, e], dimension=3, /nan))
      tcam = reform(mean(tmp_ext_data[*, *, *, 1, e], dimension=3, /nan))
      if (total(finite(rcam), /integer) eq 0L) then missing = 1B
      if (total(finite(tcam), /integer) eq 0L) then missing = 1B
    endfor
  endif

  return, missing ? 1UL : 0UL
end
