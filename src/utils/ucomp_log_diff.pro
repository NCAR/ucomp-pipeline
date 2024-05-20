; docformat = 'rst'

;+
; Read a machine/t1/t2 log file.
;
; :Returns:
;   `strarr` or `!null` if empty file
;
; :Params:
;   filename : in, required, type=string
;     filename of the log file to read
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of lines in the file
;-
function ucomp_log_diff_read, filename, count=count
  compile_opt strictarr

  count = file_lines(filename)

  if (count eq 0) then return, !null

  lines = strarr(count)
  openr, lun, filename, /get_lun
  readf, lun, lines
  free_lun, lun

  tokens = strsplit(lines[0], /extract, count=n_tokens)
  tarlist = n_tokens gt 2

  if (tarlist) then begin
    dts = lines
    for i = 0L, count - 1L do begin
      tokens = strsplit(lines[i], /extract, count=n_tokens)
      if (n_tokens ge 6) then begin
        dts[i] = file_basename(tokens[5], '.fts.gz')
      endif else begin
        dts[i] = lines[i]
      endelse
    endfor
  endif else begin
    dts = strmid(lines, 0, 15)
  endelse

  return, dts
end


;+
; Determine the differences between the files listed in machine/t1/t2 logs. This
; does not check the file sizes, but only the datetimes for the files listed.
;
; :Returns:
;   1 for a difference, 0 for no difference
;
; :Params:
;   filename1 : in, required, type=string
;     filename of first file to compare
;   filename2 : in, required, type=string
;     filename of second file to compare
;
; :Keywords:
;   only_file1 : out, optional, type=strarr
;     set to a named variable to retrieve the datetimes of files only in
;     `filename1` log
;   only_file2 : out, optional, type=strarr
;     set to a named variable to retrieve the datetimes of files only in
;     `filename2` log
;-
function ucomp_log_diff, filename1, filename2, $
                         only_file1=only_file1, only_file2=only_file2
  compile_opt strictarr

  diff = 0B

  dt1 = ucomp_log_diff_read(filename1, count=n_files1)
  dt2 = ucomp_log_diff_read(filename2, count=n_files2)

  i1 = 0L
  i2 = 0L

  only_file1 = []
  only_file2 = []

  while ((i1 lt n_files1 - 1L) && (i2 lt n_files2 - 1L)) do begin
    case 1 of
      dt1[i1] eq dt2[i2]: begin
          i1 += 1L
          i2 += 1L
        end
      dt1[i1] lt dt2[i2]: begin
          only_file1 = [only_file1, dt1[i1]]
          i1 += 1
          diff = 1B
        end
      dt1[i1] gt dt2[i2]: begin
          only_file2 = [only_file2, dt2[i2]]
          i2 += 1
          diff = 1B
        end
    endcase
  endwhile

  if (i1 lt n_files1 - 1L) then begin
    diff = 1B
    only_file1 = [only_file1, dt1[i1 + 1L:*]]
  endif

  if (i2 lt n_files2 - 1L) then begin
    diff = 1B
    only_file2 = [only_file2, dt2[i2 + 1L:*]]
  endif

  return, diff
end
