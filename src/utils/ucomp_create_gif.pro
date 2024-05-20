; docformat = 'rst'

;+
; Create a GIF of image data.
;
; :Params:
;   data : in, required, type=2-d numerical data
;     data to create the GIF of
;   output_filename : in, required, type=string
;     filename of output FITS file
;
; :Keywords:
;   title : in, optional, type=string
;     title to use, if present
;   show_range : in, optional, type=boolean
;     annotate GIF with display min/max, exponent, and gamma
;   show_angles : in, optional, type=boolean
;     annotate GIF with angles around occulter and field stop
;   colortable : in, optional, type=string, default=b/w
;     color table name
;   display_minimum : in, optional, type=float
;     set the display minimum, defaults to minimum of data
;   display_maximum : in, optional, type=float
;     set the display maximum, defaults to maximum of data
;   display_exponent : in, optional, type=float
;     set the display exponent
;   display_gamma : in, optional, type=float
;     set the display gamma
;-
pro ucomp_create_gif, data, output_filename, $
                      title=title, $
                      show_range=show_range, $
                      show_angles=show_angles, $
                      colortable=colortable, $
                      display_minimum=display_minimum, $
                      display_maximum=display_maximum, $
                      display_exponent=display_exponent, $
                      display_gamma=display_gamma
  compile_opt strictarr

  dims = size(data, /dimensions)

  _colortable = mg_default(colortable, 'b/w')
  _display_min = mg_default(display_min, min(data))
  _display_max = mg_default(display_max, max(data))
  _display_exponent = mg_default(display_exponent, 1.0)
  _display_gamma = mg_default(display_gamma, 1.0)

  n_annotation_colors = 1L
  top = 255L - n_annotation_colors

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'

  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get

  device, set_resolution=dims, $
          z_buffering=0, $
          decomposed=0, $
          set_pixel_depth=8, $
          set_colors=256

  ucomp_loadct, _colortable, n_colors=top + 1L
  white = 255
  tvlct, 255, 255, 255, white
  tvlct, r, g, b, /get

  ; display image
  tv, bytscl(data^_display_exponent, $
             min=_display_min, $
             max=_display_max, $
             top=top, $
             /nan)

  ; annotation
  line_height = 10L
  top_margin = 15L
  left_margin = 15L
  right_margin = 15L
  bottom_margin = 15L

  charsize = 1.25

  if (n_elements(title) gt 0L) then begin
    xyouts, left_margin, dims[1] - top_margin - line_height, /device, $
            title, $
            color=white, charsize=charsize
  endif

  if (keyword_set(show_range)) then begin
    xyouts, left_margin, bottom_margin, /device, $
            string(_display_min, _display_max, _display_exponent, _display_gamma, $
                   format='(%"min/max: %0.1f/%0.1f, exp: %0.2f, gamma: %0.2f")'), $
            color=white, charsize=charsize
  endif

  ; save image to output
  write_gif, output_filename, tvrd(), r, g, b

  ; restore original graphics settings
  device, decomposed=original_decomposed
  tvlct, original_rgb
  set_plot, original_device
end
