; docformat = 'rst'


pro ucomp_extract_headertags_processfile, file, dir, tagnames, headertags, $
                                          error=error, $
                                          by_extension=by_extension, $
                                          month=month, day=day, year=year
  compile_opt strictarr

  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    if (size(fcb, /type) eq 8) then fits_close, fcb
    if (obj_valid(tags)) then obj_destroy, tags
    return
  endif

  hour = long(strmid(file, 9, 2))
  min  = long(strmid(file, 11, 2))
  sec  = long(strmid(file, 13, 2))

  fits_open, filepath(file, root=dir), fcb

  if (size(fcb, /type) ne 8) then return

  if (keyword_set(by_extension)) then begin
    e_start = 1L
    e_end = fcb.nextend
  endif else begin
    e_start = 0L
    e_end = 0L
  endelse

  for e = e_start, e_end do begin
    fits_read, fcb, data, header, /header_only, exten_no=e
    tags = hash('date', julday(month, day, year, hour, min, sec))
    tags['dt'] = strmid(file, 0, 15)
    for t = 0L, n_elements(tagnames) - 1L do begin
      value = sxpar(header, tagnames[t])
      tags[tagnames[t]] = value
    endfor
    headertags->add, tags->toStruct()
    obj_destroy, tags
  endfor

  fits_close, fcb
end


;+
; Utility routine to pull out header information from raw or L1 data files.
;
; :Examples:
;   For example, to pull the OVRLPANG FITS keyword from the primary header of
;   all the L1 output files in 2016, do::
;
;     root = '/export/data1/Data/CoMP/process'
;     results = comp_extract_headertags(root, 'OVRLPANG', '20160101')
;
; :Uses:
;   fits_open, fits_read, fits_close, sxpar
;
; :Returns:
;   array of structures with fields given by the `tagnames` plus a "date"
;
; :Params:
;   root_dir : in, required, type=string
;     directory containing date directories
;   tagnames : in, required, type=string/strarr
;     FITS keyword(s) to be extracted from the files; use `BY_EXTENSION` to
;     specify that it should be pulled from every extension of the file,
;     otherwise it will be pulled from the primary header
;
; :Keywords:
;   start_date : in, optional, type=string
;   end_date : in, optional, type=string
;   interactive : in, optional, type=boolean
;-
function ucomp_extract_headertags, root_dir, tagnames, $
                                   start_date=start_date, end_date=end_date, $
                                   types=types, by_extension=by_extension, $
                                   wave_region=wave_region, background=background, $
                                   interactive=interactive
  compile_opt strictarr
  on_error, 2

  pattern = '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
  path = filepath(pattern, root=root_dir)
  date_dirs = file_search(path, count=n_date_dirs, /test_directory)

  if (n_date_dirs eq 0L) then begin
    message, 'no date directories found in ' + root_dir
  endif

  date_dirs = file_basename(date_dirs)
  date_dirs = date_dirs[sort(date_dirs)]

  if (n_elements(start_date) eq 0L) then begin
    start_index = 0L
  endif else begin
    start_index = value_locate(date_dirs, start_date) > 0
    if (date_dirs[start_index] ne start_date) then ++start_index
  endelse
  if (start_index ge n_elements(date_dirs)) then begin
    message, 'start date is after all date directories'
  endif

  if (n_elements(end_date) eq 0L) then begin
    end_index = n_elements(date_dirs) - 1L
  endif else begin
    end_index = value_locate(date_dirs, end_date)
  endelse
  if (end_index lt 0L) then begin
    message, 'end date is before all date directories'
  endif

  if (end_index lt start_index) then begin
    message, 'end date before start date'
  endif

  date_dirs = date_dirs[start_index:end_index]

  headertags = list()

  for d = 0L, n_elements(date_dirs) - 1L do begin
    dir = filepath('level1', subdir=date_dirs[d], root=root_dir)
    if (~file_test(dir, /directory)) then begin
      dir = filepath(date_dirs[d], root=root_dir)
    endif

    pattern = '*'
    path = filepath(pattern, root=dir)
    files = file_search(path, count=n_files)
    files = file_basename(files)

    l0_re = '^' + date_dirs[d] + '\.[[:digit:]]{6}\.fts'
    l0_files_check = stregex(files, l0_re, /boolean)

    l1_re = '^[[:digit:]]{8}\.[[:digit:]]{6}\.ucomp\.' $
           + (n_elements(wave_region) eq 0L ? '.*' : wave_region) $
           + '(\.l1\.p[[:digit:]]+)?' $
           + '\.fts(\.gz)?'
    l1_files_check = stregex(files, l1_re, /boolean)

    ind = where(l0_files_check or l1_files_check, n_files)

    if (n_files eq 0L) then begin
      print, date_dirs[d], format='(%"skipping %s, no files")'
      continue
    endif
    files = files[ind]

    year  = long(strmid(date_dirs[d], 0, 4))
    month = long(strmid(date_dirs[d], 4, 2))
    day   = long(strmid(date_dirs[d], 6, 2))

    p = mg_progress(files, title=date_dirs[d], hide=~keyword_set(interactive))
    foreach file, p, f do begin
      ucomp_extract_headertags_processfile, file, dir, tagnames, headertags, $
                                            error=error, $
                                            by_extension=by_extension, $
                                            month=month, day=day, year=year
    endforeach
    obj_destroy, p
  endfor

  htags = headertags->toArray()
  obj_destroy, headertags
  return, htags
end


; main-level example program

wave_regions = ['1074']
root = '/hao/dawn/Data/UCoMP/process'

start_date = '20220101'
end_date = '20220108'
tag_names = ['POST_ANG', 'SOLAR_P0']
name = 'post'

for w = 0L, n_elements(wave_regions) - 1L do begin
  results = ucomp_extract_headertags(root, tag_names, $
                                     start_date=start_date, $
                                     end_date=end_date, $
                                     wave_region=wave_regions[w], $
                                     /interactive)

  if (n_elements(results) gt 0L) then begin
    write_csv, string(name, wave_regions, format='ucomp.%s.%s.csv'), $
               results.date, results.dt, results.(2), results.(3), $
               header=['date', 'datetime', tag_names]
  endif
endfor

end
