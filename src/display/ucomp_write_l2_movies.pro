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

  ffmpeg = run->config('externals/ffmpeg')
  if (n_elements(ffmpeg) eq 0L) then begin
    mg_log, 'ffmpeg not specified, skipping movie creation', $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'creating level 2 mp4s for %s nm', wave_region, $
          name=run.logger_name, /info

  types = ['peak_intensity', 'enhanced_peak_intensity', 'velocity', $
           'line_width', $   ; dynamics
           'linear_polarization', 'radial_azimuth']   ; polarization
  for t = 0L, n_elements(types) - 1L do begin
    ucomp_write_l2_mp4, wave_region, types[t], run=run
  endfor

  done:
end
