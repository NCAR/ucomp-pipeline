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
pro ucomp_write_movies, wave_region, run=run
  compile_opt strictarr

  ; intensity images
  ucomp_write_intensity_mp4, wave_region, run=run

  ; IQUV images
  ucomp_write_iquv_mp4, wave_region, run=run
end
