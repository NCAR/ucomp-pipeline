; docformat = 'rst'

pro ucomp_loadct_rgb, rgb
  compile_opt strictarr
  common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  r_orig = bindgen(256)
  g_orig = bindgen(256)
  b_orig = bindgen(256)

  r_orig[0] = rgb[*, 0]
  g_orig[0] = rgb[*, 1]
  b_orig[0] = rgb[*, 2]

  r_curr = r_orig
  g_curr = g_orig
  b_curr = b_orig

  tvlct, rgb
end


;+
; Loads the given color table.
;
; :Params:
;   name : in, required, type=string
;     name of color table to load: b/w
;
; :Keywords:
;   n_colors : in, optional, type=integer
;     number of colors needed, defaults to 256
;   rgb : out, optional, type="bytarr(256, 3)"
;     set to a named variable to retrieve the color table values, instead of
;     loading them into the current color table
;-
pro ucomp_loadct, name, n_colors=n_colors
  compile_opt strictarr
  on_error, 2

  red   = [255B,   0B,   0B]
  black = [  0B,   0B,   0B]
  blue  = [  0B,   0B, 255B]
  pink  = [255B, 105B, 180B]
  cyan  = [  0B, 255B, 255B]

  case strlowcase(name) of
    'intensity': loadct, 0, /silent, ncolors=n_colors
    'quv': ucomp_loadct_rgb, mg_makect(cyan, black, pink, ncolors=n_colors)
    else: message, string(name, format='(%"unknown colortable name: %s")')
  endcase
end
