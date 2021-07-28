; docformat = 'rst'

;+
; Define structure containing information about the geometry of a UCoMP image.
;-
pro ucomp_geometry__define
  compile_opt strictarr
 
   !null = {ucomp_geometry, $
            occulter_x: 0.0, $
            occulter_y: 0.0, $
            occulter_r: 0.0, $
            post_angle: 0.0}
end
