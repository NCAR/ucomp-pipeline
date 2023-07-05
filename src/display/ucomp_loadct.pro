; docformat = 'rst'

;+
; Load a color table specified by `rgb` into the current color table as well as
; into the `colors` common block, current and original colors.
;
; :Params:
;   rgb : in, required, type="bytarr(n_colors, 3)"
;     color table
;-
pro ucomp_loadct_rgb, rgb
  compile_opt strictarr
  common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

  dims = size(rgb, /dimensions)
  n_colors = dims[0]

  r_orig = bindgen(n_colors)
  g_orig = bindgen(n_colors)
  b_orig = bindgen(n_colors)

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
;     name of color table to load, e.g., "intensity", "azimuth", etc.
;
; :Keywords:
;   n_colors : in, optional, type=integer, default=256
;     number of colors needed
;-
pro ucomp_loadct, name, n_colors=n_colors
  compile_opt strictarr
  on_error, 2

  red   = [255B,   0B,   0B]
  black = [  0B,   0B,   0B]
  blue  = [  0B,   0B, 255B]
  pink  = [255B, 105B, 180B]
  cyan  = [  0B, 255B, 255B]
  white = [255B, 255B, 255B]

  case strlowcase(name) of
    'intensity': loadct, 0, /silent, ncolors=n_colors
    'enhanced_intensity': loadct, 0, /silent, ncolors=n_colors   ; used 3 before
    'quv': ucomp_loadct_rgb, mg_makect(cyan, black, pink, ncolors=n_colors)
    'linpol': loadct, 0, /silent, ncolors=n_colors
    'azimuth': loadct, 4, /silent, ncolors=n_colors
    'radial_azimuth': begin
        loadct, 6, /silent, ncolors=n_colors
        ; shift the used part of the color table so that black is in the middle
        ; and green is on the ends, i.e., by half the number of colors in the
        ; color table
        _n_colors = n_elements(n_colors) eq 0L ? 256L : n_colors
        tvlct, rgb, /get
        rgb[0:_n_colors - 1L, *] = shift(rgb[0:_n_colors - 1L, *], _n_colors / 2, 0)
        ucomp_loadct_rgb, rgb
      end
    'doppler': ucomp_loadct_rgb, mg_makect(blue, white, red, ncolors=n_colors)
    'line_width': loadct, 4, /silent, ncolors=n_colors
    'difference': ucomp_loadct_rgb, mg_makect(cyan, black, pink, ncolors=n_colors)
    else: message, string(name, format='(%"unknown colortable name: %s")')
  endcase
end
