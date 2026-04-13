; docformat = 'rst'

;+
; Print and plot the time difference between waves files for a given day.
;
; :Params:
;   l0_dir : in, required, type=str
;     path to a directory of level 0 files
;-
pro ucomp_waves_timedifference, l0_dir
  compile_opt strictarr

  files = file_search(filepath('*.fts', root=l0_dir), count=n_files)
  primary_dateobs = strarr(n_files)
  datebeg = strarr(n_files)
  waves = bytarr(n_files)
  for f = 0L, n_files - 1L do begin
    primary_header = headfits(files[f], exten=0)
    obs_plan = ucomp_getpar(primary_header, 'OBS_PLAN')
    waves[f] = strpos(strlowcase(obs_plan), 'wave') ge 0
    primary_dateobs[f] = ucomp_getpar(primary_header, 'DATE-OBS')

    header = headfits(files[f], exten=1)
    datebeg[f] = ucomp_getpar(header, 'DATE-BEG')
  endfor

  waves_indices = where(waves, n_waves)

  total_differences = fltarr(2, n_waves - 1)

  primary_jds = ucomp_dateobs2julday(primary_dateobs[waves_indices], /milliseconds)
  primary_differences = (primary_jds[1:*] - primary_jds[0:-1]) * 24.0D * 60.0D * 60.0D
  total_differences[0, *] = primary_differences

  jds = ucomp_dateobs2julday(datebeg[waves_indices], /milliseconds)
  differences = (jds[1:*] - jds[0:-1]) * 24.0D * 60.0D * 60.0D
  total_differences[1, *] = differences

  print, total_differences, format='(F0.2, " ", F0.2)'

  window, xsize=800, ysize=300, title='DATE-OBS differences in waves program', /free
  mg_rangeplot, findgen(n_waves - 1L), primary_differences, $
                xstyle=9, ystyle=8, yrange=[33.5, 33.9], $
                color='f000000'x, background='ffffff'x, $
                clip_color='0000ff'x, clip_psym=4, clip_symsize=1.0, xtitle='Image index', ytitle='Time difference [secs]'

  window, xsize=800, ysize=300, title='DATE-BEG differences in waves program', /free
  mg_rangeplot, findgen(n_waves - 1L), differences, $
                xstyle=9, ystyle=8, yrange=[33.5, 33.9], $
                color='f000000'x, background='ffffff'x, $
                clip_color='0000ff'x, clip_psym=4, clip_symsize=1.0, xtitle='Image index', ytitle='Time difference [secs]'
end


; main-level example program

; l0_dir = '/path/to/Data/UCoMP/incoming/20240409'
l0_dir = '/hao/dawn/Data/UCoMP/incoming/20240409'
ucomp_waves_timedifference, l0_dir

end
