; docformat = 'rst'

;+
; Write movies of level 1 images.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_l1_movies, wave_region, run=run
  compile_opt strictarr

  ffmpeg = run->config('externals/ffmpeg')
  if (n_elements(ffmpeg) eq 0L) then begin
    mg_log, 'ffmpeg not specified, skipping movie creation', $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'creating level 1 mp4s for %s nm', wave_region, $
          name=run.logger_name, /info

  ; intensity images
  ucomp_write_intensity_mp4, wave_region, run=run
  ucomp_write_intensity_mp4, wave_region, run=run, /enhanced

  ; IQUV images
  ucomp_write_iquv_mp4, wave_region, run=run

  done:
end
