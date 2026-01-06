; docformat = 'rst'

;+
; Check median dark values by camera are in a nominal range.
;
; :Returns:
;   `0UL` if `file` passed this test, `1UL` if not
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header for the given file
;   ext_data : in, required, type="fltarr(nx, ny, n_polstates, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     list of extension headers, each a `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_dark_values, file, $
                                    primary_header, $
                                    ext_data, $
                                    ext_headers, $
                                    run=run
  compile_opt strictarr

  ; only check darks
  is_dark = strtrim(ucomp_getpar(ext_headers[0], 'DATATYPE'), 2) eq 'dark'
  if (~is_dark) then return, 0UL

  quality_rcam_dark_range = run->epoch('quality_rcam_dark_range')
  quality_tcam_dark_range = run->epoch('quality_tcam_dark_range')

  numsum = ucomp_getpar(ext_headers[0], 'NUMSUM')

  dims = size(ext_data, /dimensions)

  r_outer = run->epoch('field_radius')
  field_mask = ucomp_field_mask(dims[0:1], r_outer)
  field_mask_indices = where(field_mask, /null)

  rcam_test_data = ext_data[*, *, *, 0, *]
  tcam_test_data = ext_data[*, *, *, 1, *]
  n_dims = size(rcam_test_data, /n_dimensions)
  while (n_dims gt 2) do begin
    rcam_test_data = mean(rcam_test_data, dimension=3)
    tcam_test_data = mean(tcam_test_data, dimension=3)
    n_dims = size(rcam_test_data, /n_dimensions)
  endwhile

  rcam_median = median(rcam_test_data[field_mask_indices]) / numsum
  tcam_median = median(tcam_test_data[field_mask_indices]) / numsum

  fail = 0B

  if ((rcam_median lt quality_rcam_dark_range[0])) then begin
    mg_log, 'RCAM median < %0.1f', quality_rcam_dark_range[0], $
            name=run.logger_name, /warn
    fail = 1B
  endif

  if ((rcam_median gt quality_rcam_dark_range[1])) then begin
    mg_log, 'RCAM median > %0.1f', quality_rcam_dark_range[1], $
            name=run.logger_name, /warn
    fail = 1B
  endif

  if ((tcam_median lt quality_tcam_dark_range[0])) then begin
    mg_log, 'TCAM median < %0.1f', quality_tcam_dark_range[0], $
            name=run.logger_name, /warn
    fail = 1B
  endif

  if ((tcam_median gt quality_tcam_dark_range[1])) then begin
    mg_log, 'TCAM median > %0.1f', quality_tcam_dark_range[1], $
            name=run.logger_name, /warn
    fail = 1B
  endif

  if (fail) then return, 1UL

  return, 0UL
end
