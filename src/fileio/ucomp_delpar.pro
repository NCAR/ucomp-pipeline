; docformat = 'rst'

;+
; Remove keywords, sections
;
; :Params:
;   header : in, required, type=strarr
;     FITS header
;   name : in, required, type=string/strarr
;     FITS keyword(s) to remove
;
; :Keywords:
;   section : in, optional, type=boolean
;     set to remove entire section(s) of FITS keyword, sections are defined by
;     a title of the form "COMMENT --- Title ---" and continue until the end of
;     the header or the next title
;   history, in, optional, type=boolean
;     set to remove the HISTORY lines of the header
;-
pro ucomp_delpar, header, name, section=section, history=history
  compile_opt strictarr

  if (keyword_set(history)) then begin
    mask = strmatch(header, 'HISTORY *') or strmatch(header, 'HISTORY')
    non_history_indices = where(mask eq 0, /null, ncomplement=n_removed)
    header = header[non_history_indices]
    return
  endif

  if (keyword_set(section)) then begin
    for s = 0L, n_elements(name) - 1L do begin
      title_glob = string(name[s], format='COMMENT --- %s ---*')
      matching_title_indices = where(strmatch(header, title_glob), n_matching_titles)

      ; nothing to delete
      if (n_matching_titles eq 0L) then return

      all_titles_glob = 'COMMENT --- *'
      all_titles_indices = where(strmatch(header, all_titles_glob), n_all_titles)
      all_titles_matching_indices = where(matching_title_indices[0] eq all_titles_indices)

      if (all_titles_matching_indices[0] eq n_all_titles - 1L) then begin
        ; it was the last title, so delete from the section title until the end
        ; (but not the "END" on the last line)
        header = header[[lindgen(matching_title_indices[0]), n_elements(header) - 1]]
      endif else begin
        ; delete from the section title until the next section title
        header = [header[0:all_titles_indices[all_titles_matching_indices[0]] - 1], $
                  header[all_titles_indices[all_titles_matching_indices[0] + 1]:*]]
      endelse
    endfor
  endif else begin
    sxdelpar, header, name
  endelse
end


; main-level example program

date = '20220111'
basename = '20220111.192841.ucomp.1074.l2.fts'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

filename = filepath(basename, $
                    subdir=[date, 'level2'], $
                    root=run->config('processing/basedir'))
obj_destroy, run

fits_open, filename, fcb
fits_read, fcb, !null, header, exten_no=0
fits_close, fcb

print, header

end
