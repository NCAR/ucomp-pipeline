; docformat = 'rst'

;+
; Write  mp4s for some level 2 images for a given wave region.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, i.e., "1074"
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_l2_movies, wave_region, run=run
  compile_opt strictarr

  mg_log, 'creating level 2 mp4s for %s nm', wave_region, $
          name=run.logger_name, /info

  types = ['peakint', 'enh-peakint', 'velocity', 'linewidth', 'linpol', 'radazi']
  for t = 0L, n_elements(types) - 1L do begin
    ucomp_write_l2_mp4, wave_region, types[t], run=run
  endfor
end
