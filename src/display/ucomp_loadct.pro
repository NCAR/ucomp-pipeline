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
;   rgb_table : out, optional, type="bytarr(n_colors, 3)"
;     set to a named variable to retrieve the RGB color table values instead
;     of setting the color table
;   band_color : in, optional, type=bytarr(3)
;     color of band
;   band_location : in, optional, type=byte
;     index in the color table to place center of band
;   band_width : in, optional, type=integer
;     width of band
;-
pro ucomp_loadct, name, n_colors=n_colors, rgb_table=rgb_table, $
                  band_color=band_color, $
                  band_location=band_location, $
                  band_width=band_width
  compile_opt strictarr
  on_error, 2

  red   = [255B,   0B,   0B]
  black = [  0B,   0B,   0B]
  blue  = [  0B,   0B, 255B]
  pink  = [255B, 105B, 180B]
  cyan  = [  0B, 255B, 255B]
  white = [255B, 255B, 255B]

  case strlowcase(name) of
    'intensity': begin
        loadct, 0, /silent, ncolors=n_colors, rgb_table=rgb_table
      end
    'enhanced_intensity': begin
        ; used color table 3 previously
        loadct, 0, /silent, ncolors=n_colors, rgb_table=rgb_table
      end
    'background': begin
        loadct, 0, /silent, ncolors=n_colors, rgb_table=rgb_table
      end
    'quv': begin
        ; rgb_table = mg_makect(cyan, black, pink, ncolors=n_colors)
        loadct, 0, /silent, ncolors=n_colors, rgb_table=rgb_table
        ;loadct, 73, /silent, ncolors=n_colors, rgb_table=rgb_table
      end
    'linpol': begin
        loadct, 0, /silent, ncolors=n_colors, rgb_table=rgb_table
      end
    'azimuth': begin
        loadct, 4, /silent, ncolors=n_colors, rgb_table=rgb_table
      end
    'radial_azimuth': begin
        loadct, 6, /silent, ncolors=n_colors, rgb_table=rgb_table
        ; shift the used part of the color table so that black is in the middle
        ; and green is on the ends, i.e., by half the number of colors in the
        ; color table
        _n_colors = n_elements(n_colors) eq 0L ? 256L : n_colors
        rgb_table[0:_n_colors - 1L, *] = shift(rgb_table[0:_n_colors - 1L, *], $
                                               _n_colors / 2, 0)
      end
    'density': begin
        mpl_filename = filepath('mpl.tbl', $
                                subdir=['..', '..', 'resource', 'colortables'], $
                                root=mg_src_root())
        loadct, 16, /silent, file=mpl_filename, rgb_table=rgb_table, ncolors=n_colors
      end
    'doppler': begin
        rgb_table = mg_makect(blue, white, red, ncolors=n_colors)
      end
    'line_width': begin
        ; jet colortable
        mpl_filename = filepath('mpl.tbl', $
                                subdir=['..', '..', 'resource', 'colortables'], $
                                root=mg_src_root())
        loadct, 12, /silent, file=mpl_filename, rgb_table=rgb_table, ncolors=n_colors
      end
    'difference': begin
        rgb_table = mg_makect(cyan, black, pink, ncolors=n_colors)
      end
    else: message, string(name, format='(%"unknown colortable name: %s")')
  endcase

  if (n_elements(band_location) gt 0L) then begin
    _band_color = mg_default(band_color, bytarr(3) + 255B)
    _band_width = mg_default(band_wdith, 3L)
    start_index = band_location - _band_width / 2L
    band = rebin(reform(_band_color, 1, 3), _band_width, 3)
    rgb_table[start_index:start_index + _band_width - 1L, *] = band
  endif

  ; load the rgb_table if not just retrieving the table values
  if (~arg_present(rgb_table)) then ucomp_loadct_rgb, rgb_table
end
