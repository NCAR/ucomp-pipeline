; docformat = 'rst'

;+
; Read GBU file.
;
; :Returns:
;   array of structures with fields `basename` and `code`, of the form
;   `{basename: '', code: 0L}`
;
; :Params:
;   filename : in, required, type=string
;     filename of GBU file to read
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of files described in the
;     GBU file
;-
function ucomp_read_gbu, filename, count=count
  compile_opt strictarr

  n_lines = file_lines(filename)
  if (n_lines eq 0L) then begin
    count = 0L
    return, !null
  endif

  lines = strarr(n_lines)
  openr, lun, filename, /get_lun
  readf, lun, lines
  free_lun, lun

  n_header_lines = 1L
  empty_lines_indices = where(strmatch(lines, ''), n_empty_lines)
  files_start_index = n_header_lines
  files_end_index = empty_lines_indices[0] - 1L

  if (files_end_index lt files_start_index) then begin
    count = 0L
    return, !null
  endif else begin
    count = files_end_index - files_start_index + 1L
    gbu = replicate({basename: '', code: 0L}, count)
    for f = files_start_index, files_end_index do begin
      print, f, lines[f], format='(%"lines[%d] = %s")'
      tokens = strsplit(lines[f], /extract)
      gbu[f - files_start_index].basename = tokens[0]
      gbu[f - files_start_index].code = long(tokens[1])
    endfor
  endelse

  return, gbu
end
