; docformat = 'rst'

;+
; Apply a linear function to a segment of the camera table.
;
; :Returns:
;   a segment of the camera table, from `start_value` to `end_value`, i.e.,
;   `fltarr(end_value - start_value + 1)`
;
; :Params:
;   start_index : in, required, type=long
;     start index of the table segment
;   end_index : in, required, type=long
;     end index of the table segment
;   coeffs : in, required, type=fltarr(2)
;     coefficients of the linear function in increasing degree, i.e., constant
;     term first, then degree 1 term
;-
function ucomp_read_cameras_linear, start_index, end_index, coeffs
  compile_opt strictarr

  segment_table = findgen(end_index - start_index + 1L) + start_index
  segment_table = coeffs[0] + coeffs[1] * segment_table
  return, segment_table
end


;+
; Read the given cameras configuration file and return an array of structures
; with fields `name` and `table` corresponding to the cameras defined.
;
; :Returns:
;   `replicate({name: '', table: fltarr(n_dn_values)}, n_cameras)`
;
; :Params:
;   filename : in, required, type=string
;     filename of the camera configuration file
;-
function ucomp_read_cameras, filename
  compile_opt strictarr
  on_error, 2

  if (~file_test(filename, /regular)) then message, 'file not found: ' + filename

  config = mg_read_config(filename)

  sections = config->sections(count=n_sections)

  numsum = 16L
  n_dn_values = 2L^16 / numsum

  cameras = replicate({name: '', table: fltarr(n_dn_values)}, n_sections)

  for s = 0L, n_sections - 1L do begin
    cameras[s].name = sections[s]
    camera_table = findgen(n_dn_values)

    segment = 1L
    segment_name = string(segment, format='segment%d')
    while (config->has_option(segment_name, section=sections[s])) do begin
      segment_value = config->get(segment_name, section=sections[s])

      tokens = strsplit(segment_value, ',', /extract)

      range_tokens = strsplit(strtrim(tokens[0], 2), '-', /extract, /preserve_null)
      start_value = strtrim(range_tokens[0], 2)
      start_value = (start_value eq '') ? 0L : long(start_value)
      end_value = strtrim(range_tokens[1], 2)
      end_value = (end_value eq '') ? (n_dn_values - 1L) : long(end_value)

      function_tokens = strsplit(strtrim(tokens[1], 2), /extract)
      function_coeffs = float(function_tokens[1:*])
      case strlowcase(function_tokens[0]) of
        'linear': segment_table = ucomp_read_cameras_linear(start_value, end_value, function_coeffs)
        else: message, 'unknown function type: ' + function_tokens[0]
      endcase
      camera_table[start_value:end_value] = segment_table

      segment += 1L
      segment_name = string(segment, format='segment%d')
    endwhile
    cameras[s].table = camera_table
  endfor

  obj_destroy, config

  return, cameras
end


; main-level example program

filename = filepath('cameras.cfg', $
                    subdir=['..', '..', 'resource', 'cameras'], $
                    root=mg_src_root())

cameras = ucomp_read_cameras(filename)

for c = 0L, n_elements(cameras) - 1L do begin
  window, xsize=1000, ysize=400, /free, title=cameras[c].name
  plot, cameras[c].table, xstyle=9, ystyle=9, yrange=[0.0, 6000.0]
endfor

end
